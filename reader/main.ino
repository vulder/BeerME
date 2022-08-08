#include <ESP8266WiFi.h>
#include <SPI.h>
#include <MFRC522.h>
#include <ESP8266HTTPClient.h>
#include <time.h>
#include <stdlib.h>

#define SERVER_PORT "8080"
#define SERVER_PROTOCOL "http"
#define SERVER_IP "192.168.20.162"
#ifndef STASSID
#define STASSID "lan"
#define STAPSK  "lan2022flo"
#endif

#define SS_PIN 15  //D2
#define RST_PIN 0 //D1

MFRC522 mfrc522(SS_PIN, RST_PIN);   // Create MFRC522 instance.
int statuss = 0;
int out = 0;

const char* ssid     = STASSID;
const char* password = STAPSK;

String baseUrl(){
  return String(SERVER_PROTOCOL)+"://"+SERVER_IP+":"+SERVER_PORT;
}

String drinkBeerUrl(String token) {
  return baseUrl() + "/tokens/"+token+"/beer";
}

void setup() {
  srand(time(NULL));   // Initialization, should only be called once.
  pinMode(LED_BUILTIN, OUTPUT);     // Initialize the LED_BUILTIN pin as an output
  Serial.begin(115200);

  // We start by connecting to a WiFi network

  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  /* Explicitly set the ESP8266 to be a WiFi-client, otherwise, it by default,
     would try to act as both a client and an access-point and could cause
     network-issues with your other WiFi-devices on your WiFi-network. */
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  
  SPI.begin();      // Initiate  SPI bus
  mfrc522.PCD_Init();   // Initiate MFRC522
}

void blink(int count) {
  blink(count, 100, 100);
}

void blink(int count, int ms) {
  blink(count, ms, ms);
}

void blink(int count, int onMillis, int offMillis) {
  if (count < 0) return;
  for(int i = 0; i < count; ++i){
    digitalWrite(LED_BUILTIN, LOW);
    delay(onMillis);
    digitalWrite(LED_BUILTIN, HIGH);
    delay(offMillis);
  }
}
void loop() {
   // Look for new cards
  if ( ! mfrc522.PICC_IsNewCardPresent()) 
  {
    return;
  }
  // Select one of the cards
  if ( ! mfrc522.PICC_ReadCardSerial()) 
  {
    return;
  }

  //Show UID on serial monitor
  Serial.println();
  Serial.print(" UID tag :");
  String content= "";
  byte letter;
  for (byte i = 0; i < mfrc522.uid.size; i++) 
  {
     Serial.print(mfrc522.uid.uidByte[i] < 0x10 ? "0" : "");
     Serial.print(mfrc522.uid.uidByte[i], HEX);
     content.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? "0" : ""));
     content.concat(String(mfrc522.uid.uidByte[i], HEX));
  }
  content.toUpperCase();
  Serial.println();

  if ((WiFi.status() == WL_CONNECTED)) {
    WiFiClient client;
    HTTPClient http;
  
    Serial.print("[HTTP] begin...\n");
    // configure traged server and url
    http.begin(client, drinkBeerUrl(content.substring(0))); //HTTP
    http.addHeader("Content-Type", "application/json");
  
    Serial.print("[HTTP] POST...\n");
    // start connection and send HTTP header and body
    int httpCode = http.POST("{\"id\":\""+content.substring(0)+"\"}");
  
    // httpCode will be negative on error
    if (httpCode > 0) {
      // HTTP header has been send and Server response header has been handled
      Serial.printf("[HTTP] POST... code: %d\n", httpCode);
  
      const String& payload = http.getString();
      Serial.println("received payload:\n<<");
      Serial.println(payload);
      Serial.println(">>");
      if (httpCode == HTTP_CODE_OK && payload.length()==14) {
        blink(2, 500);
      } else {
        blink(5, 100);
      }

      
    } else {
      Serial.printf("[HTTP] POST... failed, error: %s\n", http.errorToString(httpCode).c_str());
    }
  
    http.end();
  }
}

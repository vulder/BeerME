use actix_web::HttpResponse;
use actix_web::web::Json;
use serde::{Deserialize, Serialize};

use crate::constants::APPLICATION_JSON;

#[get("/beer")]
pub async fn beer() -> HttpResponse {
    HttpResponse::Ok()
        .content_type(APPLICATION_JSON)
        .json("{Foo:\"Bar\"}")
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Beer {
    pub message: String,
}

impl Beer {
    pub fn new(message: String) -> Self {
        Self {
            message,
        }
    }
}

#[derive(Debug, Deserialize, Serialize)]
pub struct RequestData {
    pub message: Option<String>,
}


impl RequestData {
    pub fn to_beer(&self) -> Option<Beer> {
        match &self.message {
            Some(message) => println!("Here {}", message),
            None => println!("nope"),
        }
        match &self.message {
            Some(message) => Some(Beer::new(message.to_string())),
            None => None,
        }
    }
}

#[post("/send_beer")]
pub async fn create(req: Json<RequestData>) -> HttpResponse {
    println!("Raw {}", req.message.clone().unwrap_or("empty".to_string()));
    println!("Got {}", req.to_beer().map(|x| {
        x.message
    }).unwrap_or("nothing".to_string()));
    HttpResponse::Ok()
        .content_type(APPLICATION_JSON)
        .json(req.to_beer())
}

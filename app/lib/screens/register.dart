import 'dart:convert';

import 'package:app/api.dart';
import 'package:app/dto/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:http/http.dart' as http;
import 'package:app/screens/register_form.dart';

class Register extends StatelessWidget {
  static var sanitize = (String token) {
    return token.replaceAll(RegExp(r'/^[A-Fa-f0-9]/'), "");
  };
  static var retrieveUserWidget = (String tokenId) {
    return FutureBuilder(
        future: Api.retrieveUser(sanitize(tokenId)),
        builder: (BuildContext context,
            AsyncSnapshot<http.Response> retrieveUserSnapshot) {
          if (retrieveUserSnapshot.hasData) {
            if (retrieveUserSnapshot.data?.statusCode == 404) {
              return RegistrationForm(tokenId);
            } else if (retrieveUserSnapshot.data?.statusCode == 200) {
              var user = UserDto.fromJson(
                  json.decode('${retrieveUserSnapshot.data?.body}'));

              return Column(children: [
                const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Hello ${user.first_name} ${user.last_name}'),
                )
              ]);
            } else {
              return Column(children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                      'User data retrieval API request failed due to unknown reason. Return code is ${retrieveUserSnapshot.data?.statusCode} and body content ${retrieveUserSnapshot.data?.body}'),
                )
              ]);
            }
          } else if (retrieveUserSnapshot.hasError) {
            return Column(children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                    'User data retrieval failed. Error: ${retrieveUserSnapshot.error}'),
              )
            ]);
          } else {
            return Column(children: const [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Retrieving user data ...'),
              )
            ]);
          }
        });
  };

  static FutureBuilder<NFCTag> readTagWidget = FutureBuilder<NFCTag>(
      future: FlutterNfcKit.poll(),
      builder: (BuildContext context, AsyncSnapshot<NFCTag> snapshot) {
        if (snapshot.hasData) {
          return retrieveUserWidget('${snapshot.data?.id}');
        } else if (snapshot.hasError) {
          return Column(children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child:
                  Text('User data retrieval failed. Error: ${snapshot.error}'),
            )
          ]);
        }

        return Column(children: const [
          Icon(
            Icons.sensors,
            size: 80,
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text("Hold token near phone ..."),
          )
        ]);
      });

  static FutureBuilder<NFCAvailability> handleNfcAvailabilityWidget =
      FutureBuilder<NFCAvailability>(
    future: FlutterNfcKit.nfcAvailability,
    builder: (BuildContext context,
        AsyncSnapshot<NFCAvailability> availabilitySnapshot) {
      if (availabilitySnapshot.hasData &&
          availabilitySnapshot.data == NFCAvailability.available) {
        return readTagWidget;
      } else if (availabilitySnapshot.hasData &&
          availabilitySnapshot.data != NFCAvailability.available) {
        return Column(children: const [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Error: NFC reader not available.'),
          )
        ]);
      } else {
        return Column(children: const [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Checking whether NFC feature is present...'),
          )
        ]);
      }
    },
  );

  Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [handleNfcAvailabilityWidget],
        ),
      ),
    );
  }
}

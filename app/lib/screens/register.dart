import 'dart:convert';

import 'package:app/api.dart';
import 'package:app/dto/user.dart';
import 'package:app/model/user.dart';
import 'package:app/service/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:http/http.dart' as http;
import 'package:app/screens/register_form.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<NFCAvailability>(
              future: FlutterNfcKit.nfcAvailability,
              builder: (BuildContext context,
                  AsyncSnapshot<NFCAvailability> availabilitySnapshot) {
                if (availabilitySnapshot.hasData &&
                    availabilitySnapshot.data == NFCAvailability.available) {
                  return FutureBuilder<NFCTag>(
                      future: FlutterNfcKit.poll(),
                      builder: (BuildContext context,
                          AsyncSnapshot<NFCTag> snapshot) {
                        if (snapshot.hasData) {
                          return FutureBuilder<WrappedResponse>(
                              future: UserService.retrieveUserAndUpdateState(
                                  context.read<UserModel>(),
                                  '${snapshot.data?.id}'),
                              builder: (BuildContext context,
                                  AsyncSnapshot<WrappedResponse>
                                      retrieveUserSnapshot) {
                                if (retrieveUserSnapshot.hasData) {
                                  if (retrieveUserSnapshot
                                          .data?.response.statusCode ==
                                      404) {
                                    return RegistrationForm(
                                        '${snapshot.data?.id}');
                                  } else if (retrieveUserSnapshot
                                          .data?.response.statusCode ==
                                      200) {
                                    var user =
                                        retrieveUserSnapshot.data?.entity;
                                    return Column(children: [
                                      const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 60,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Text(
                                            'Hello ${user.first_name} ${user.last_name}'),
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
                                            'User data retrieval API request failed due to unknown reason. Return code is ${retrieveUserSnapshot.data?.response.statusCode} and body content ${retrieveUserSnapshot.data?.response.body}'),
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
                        } else if (snapshot.hasError) {
                          return Column(children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 60,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                  'User data retrieval failed. Error: ${snapshot.error}'),
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
            )
          ],
        ),
      ),
    );
  }
}

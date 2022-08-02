import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/dto/user.dart';

class RegistrationComplete extends StatelessWidget {
  final Future<http.Response> registerRequest;

  RegistrationComplete(this.registerRequest);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Registraiton Confirmation"),
        ),
        body: FutureBuilder<http.Response>(
            future: this.registerRequest,
            builder:
                (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
              if (snapshot.hasData) {
                final UserDto user =
                    UserDto.fromJson(jsonDecode("${snapshot.data?.body}"));

                return Column(children: [
                  const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Hello ${user.first_name} ${user.last_name}'),
                  ),
                ]);
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
                        Text('Register user failed. Error: ${snapshot.error}'),
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
                    child: Text('Registering user ...'),
                  )
                ]);
              }
            }));
  }
}

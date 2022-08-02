import 'dart:convert';

import 'package:app/api.dart';
import 'package:flutter/material.dart';
import 'package:app/dto/user.dart';
import 'package:http/http.dart';

import 'package:app/screens/registration_complete.dart';

class RegistrationForm extends StatelessWidget {
  final String tokenId;

  RegistrationForm(this.tokenId);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var submitted = false;
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();

  String? validateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
                controller: firstName,
                decoration: const InputDecoration(
                  hintText: 'First Name',
                ),
                validator: validateText),
            TextFormField(
                controller: lastName,
                decoration: const InputDecoration(
                  hintText: 'Last Name',
                ),
                validator: validateText),
            TextFormField(
                controller: email,
                decoration: const InputDecoration(
                  hintText: 'E-Mail',
                ),
                validator: validateText),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationComplete(
                              Api.registerUser(CreateUserDto(
                                  first_name: firstName.text,
                                  last_name: lastName.text,
                                  email: email.text,
                                  token: tokenId)))),
                    );
                  }
                },
                child: const Text('Register'),
              ),
            ),
          ],
        ));
  }
}

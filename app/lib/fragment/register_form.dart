import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class SignUpFragment extends StatelessWidget {
  Function(Map<String, String> formData) onSubmit;

  SignUpFragment({Key? key, required this.onSubmit}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                    controller: _firstName,
                    decoration: const InputDecoration(
                      hintText: 'First Name',
                    ),
                    validator: validateText),
                TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(
                      hintText: 'Last Name',
                    ),
                    validator: validateText),
                TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(
                      hintText: 'E-Mail',
                    ),
                    validator: validateMail),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: submit,
                    child: const Text('Register'),
                  ),
                ),
              ],
            )));
  }

  submit() async {
    if (_formKey.currentState!.validate()) {
      var formData = {
        "first_name": _firstName.text,
        "last_name": _lastName.text,
        "email": _email.text
      };

      await onSubmit(formData);
    }
  }

  String? validateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }

    return null;
  }

  String? validateMail(String? value) {
    if (value == null || value.isEmpty || !EmailValidator.validate(value)) {
      return 'Please enter a valid mail';
    }

    return null;
  }
}

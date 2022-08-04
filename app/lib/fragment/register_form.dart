import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class SignUpFragment extends StatefulWidget {
  Function(Map<String, String> formData) onSubmit;

  SignUpFragment({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<SignUpFragment> createState() => _SignUpFragmentState();
}

class _SignUpFragmentState extends State<SignUpFragment> {
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(children: const [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(),
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('Sign-up in progress ...'),
        )
      ]);
    }

    return Center(
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
    setState(() => _isLoading = true);
    if (_formKey.currentState!.validate()) {
      var formData = {
        "first_name": _firstName.text,
        "last_name": _lastName.text,
        "email": _email.text
      };

      await widget.onSubmit(formData);
      setState(() => _isLoading = false);
    }
  }

  String? validateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  String? validateMail(String? value) {
    if (value == null || value.isEmpty || EmailValidator.validate(value)) {
      return 'Please enter a valid mail';
    }
    return null;
  }
}

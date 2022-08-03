import 'dart:convert';

import 'package:app/api.dart';
import 'package:app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:app/dto/user.dart';
import 'package:http/http.dart';

import 'package:provider/provider.dart';

class SignUpFragment extends StatefulWidget {
  String tokenId;

  SignUpFragment({Key? key, required this.tokenId}) : super(key: key);

  @override
  State<SignUpFragment> createState() => _SignUpFragmentState();
}

enum Status { none, loading, success, failed }

class _SignUpFragmentState extends State<SignUpFragment> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();

  Status status = Status.none;
  UserDto? user;

  String? validateText(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case Status.loading:
        return Column(children: const [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Sign-up user in progress ...'),
          )
        ]);
      case Status.success:
        return Column(children: [
          const Icon(
            Icons.check,
            color: Colors.green,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Hello ${user?.first_name} ${user?.last_name}'),
          ),
        ]);
      case Status.failed:
        return Column(children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Failed to register user'),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                  child: Row(
                    children: const [Icon(Icons.refresh), Text('Retry')],
                  ),
                  onPressed: () => setState(() {})))
        ]);
      case Status.none:
        return Center(
            child: Form(
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
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => status = Status.loading);
                            var response = await Api.registerUser(CreateUserDto(
                                first_name: firstName.text,
                                last_name: lastName.text,
                                email: email.text,
                                token: widget.tokenId));
                            setState(() {
                              if (response.statusCode == 201) {
                                status = Status.success;
                                user =
                                    UserDto.fromJson(jsonDecode(response.body));
                                context.read<UserModel>().id = "${user?.uuid}";
                              } else {
                                status = Status.failed;
                              }
                            });
                          }
                        },
                        child: const Text('Register'),
                      ),
                    ),
                  ],
                )));
    }
  }
}

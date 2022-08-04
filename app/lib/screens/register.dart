import 'dart:convert';

import 'package:app/api.dart';
import 'package:app/dto/user.dart';
import 'package:app/fragment/read_tag.dart';
import 'package:app/fragment/register_form.dart';
import 'package:app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _hasError = false;
  bool _userNotFound = false;
  String? _tokenId;

  @override
  void initState() {
    super.initState();
    retrieveUser(context.read<UserModel>());
  }

  @override
  Widget build(BuildContext context) {
    if (_tokenId == null) {
      return ReadTagIdFragment(
          onSuccess: (NFCTag? tag) => setState(() {
                _tokenId = tag?.id;
                retrieveUser(context.read<UserModel>());
              }));
    }

    if (_userNotFound) {
      return SignUpFragment(
        onSubmit: (formData) =>
            registerUser(formData, context.read<UserModel>()),
      );
    }

    if (_hasError) {
      return Column(children: [
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 60,
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('User data retrieval failed.'),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton(
                child: Row(
                  children: const [Icon(Icons.refresh), Text('Refresh')],
                ),
                onPressed: () => setState(() {})))
      ]);
    }

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

  _sanitizeToken(String? token) {
    return token?.replaceAll(RegExp(r'/^[A-Fa-f0-9]/'), "");
  }

  retrieveUser(final UserModel model) async {
    if (_tokenId == null) {
      return;
    }

    try {
      var response = await Api.retrieveUser(_sanitizeToken(_tokenId));
      if (response.statusCode == 200) {
        setState(() {
          var user = UserDto.fromJson(jsonDecode(response.body));
          model.id = user.uuid;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _userNotFound = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  registerUser(
      final Map<String, String> formData, final UserModel model) async {
    try {
      var response = await Api.registerUser(_sanitizeToken(_tokenId));
      if (response.statusCode == 200) {
        setState(() {
          var user = UserDto.fromJson(jsonDecode(response.body));
          model.id = user.uuid;
        });
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }
}

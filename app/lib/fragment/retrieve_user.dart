import 'dart:convert';

import 'package:app/api.dart';
import 'package:app/dto/user.dart';
import 'package:app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RetreiveUserFragment extends StatefulWidget {
  final Widget failedChild;

  const RetreiveUserFragment({Key? key, required this.failedChild})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RetreiveUserFragmentState();
}

class _RetreiveUserFragmentState extends State<RetreiveUserFragment> {
  @override
  Widget build(BuildContext context) {
    var model = context.read<UserModel>();

    return FutureBuilder<int>(
        future: retrieveUserAndUpdateState(model),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == 404) {
              return widget.failedChild;
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
                      'User data retrieval API request failed with status code ${snapshot.data}.'),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                        child: Row(
                          children: const [
                            Icon(Icons.refresh),
                            Text('Refresh')
                          ],
                        ),
                        onPressed: () => setState(() {})))
              ]);
            }
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
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                      child: Row(
                        children: const [Icon(Icons.refresh), Text('Retry')],
                      ),
                      onPressed: () => setState(() {})))
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
  }

  _sanitizeToken(String token) {
    return token.replaceAll(RegExp(r'/^[A-Fa-f0-9]/'), "");
  }

  Future<int> retrieveUserAndUpdateState(final UserModel model) async {
    var response = await Api.retrieveUser(_sanitizeToken(model.tokenId));
    if (response.statusCode == 200) {
      var user = UserDto.fromJson(jsonDecode(response.body));

      setState(() {
        model.id = user.uuid;
      });
    }

    return response.statusCode;
  }
}

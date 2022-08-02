import 'package:flutter/cupertino.dart';

class UserModel extends ChangeNotifier {
  String _id = "";

  String get id => _id;

  set id(String value) {
    _id = value;
    notifyListeners();
  }

  bool hasValidId() => _id != "";
}

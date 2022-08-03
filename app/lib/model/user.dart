import 'package:flutter/cupertino.dart';

class UserModel extends ChangeNotifier {
  String _id = "";

  String get id => _id;

  set id(String value) {
    _id = value;
    notifyListeners();
  }

  resetId() {
    _id = "";
    notifyListeners();
  }

  bool hasId() => _id != "";
}

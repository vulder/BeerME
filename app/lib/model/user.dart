import 'package:flutter/cupertino.dart';

class UserModel extends ChangeNotifier {
  String _id = "";
  String _tokenId = "";

  String get id => _id;
  String get tokenId => _tokenId;

  set id(String value) {
    _id = value;
    notifyListeners();
  }

  set tokenId(String value) {
    _tokenId = value;
    notifyListeners();
  }

  bool hasValidId() => _id != "";
}

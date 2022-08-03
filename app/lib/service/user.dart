import 'dart:convert';

import 'package:app/api.dart';
import 'package:app/dto/user.dart';
import 'package:app/model/user.dart';
import 'package:http/http.dart';

class UserService {
  static _sanitizeToken(String token) {
    return token.replaceAll(RegExp(r'/^[A-Fa-f0-9]/'), "");
  }

  static Future<WrappedResponse<UserDto>> retrieveUserAndUpdateState(
      final UserModel model) async {
    var response = await Api.retrieveUser(_sanitizeToken(model.tokenId));
    var user = null;
    if (response.statusCode == 200) {
      user = UserDto.fromJson(jsonDecode(response.body));
      model.id = user.uuid;
    }

    return WrappedResponse(response, user);
  }

  static Future<WrappedResponse<UserDto>> registerUserAndUpdateState(
      final UserModel model, final CreateUserDto newUser) async {
    var response = await Api.registerUser(newUser);
    var user = null;
    if (response.statusCode == 200) {
      user = UserDto.fromJson(jsonDecode(response.body));
      model.id = user.uuid;
    }

    return WrappedResponse(response, user);
  }
}

class WrappedResponse<T> {
  final Response _response;
  final T? _entity;

  WrappedResponse(final this._response, final this._entity);

  Response get response => _response;
  T? get entity => _entity;
}

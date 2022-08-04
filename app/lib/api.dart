import 'dart:convert';

import 'package:http/http.dart';
import 'package:app/dto/user.dart';

class Api {
  static String host = "192.168.1.177:8080";

  static Future<Response> registerUser(final CreateUserDto user) {
    return post(
      Uri.http(host, '/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user),
    );
  }

  static Future<Response> retrieveUser(final String tokenId) {
    return get(Uri.http(host, "/tokens/${tokenId}/user"))
        .timeout(const Duration(seconds: 10));
  }

  static Future<Response> retrieveStatistics(final String userId) {
    return get(Uri.http(host, "/users/${userId}/beers/summary"))
        .timeout(const Duration(seconds: 10));
  }
}

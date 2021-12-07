import 'package:flutter/material.dart';

class User {
  final String id;
  final String email;
  final String token;
  final String phone;
  final String username;

  User(
      {@required this.id,
      @required this.email,
      @required this.token,
      @required this.phone,
      @required this.username});
}

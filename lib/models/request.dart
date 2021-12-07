import 'package:flutter/material.dart';

class Request {
  final String id;
  final String time;
  final String collectionId;
  final String comment;
  final String userId;
  final String username;
  final String userphone;
  final bool userOwnDesign;
  final List<Map<String,dynamic>> measurements;

  Request(
      {@required this.id,
      @required this.time,
      @required this.collectionId,
      @required this.comment,
      @required this.username,
      @required this.userphone,
      @required this.userId,
      this.userOwnDesign = false,
      @required this.measurements});
}

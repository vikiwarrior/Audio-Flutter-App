import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  final String displayname;
  final String imageUrl;
  final String userid;

  UserModel({this.displayname, this.imageUrl, this.userid});
}

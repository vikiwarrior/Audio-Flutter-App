import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  final String displayname;
  final String imageUrl;

  UserModel({this.displayname, this.imageUrl});
}

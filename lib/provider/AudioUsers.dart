import 'package:audio_flutter_app/auth/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audiomodel.dart';

class AudioUser with ChangeNotifier {
  UserModel _user = UserModel(displayname: '', imageUrl: '', userid: '');

  UserModel get user {
    notifyListeners();
    return _user;
  }

  void setuid(String uid) {
    _user = UserModel(
      displayname: user.displayname,
      imageUrl: user.imageUrl,
      userid: uid,
    );
    notifyListeners();
  }

  Future<void> changeprofile(
      String name, String url, BuildContext context) async {
    final firebaseUser = context.read<User>();
    await Provider.of<AuthenticationService>(context, listen: false)
        .updateProfile(name, url, firebaseUser);
    _user = UserModel(displayname: name, imageUrl: url, userid: _user.userid);
    notifyListeners();
  }
}

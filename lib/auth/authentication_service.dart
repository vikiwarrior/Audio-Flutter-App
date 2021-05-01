import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthenticationService {
  FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User> get authStateChanges => _firebaseAuth.idTokenChanges();

  String getUserid() {
    return _firebaseAuth.currentUser.uid;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _firebaseAuth.currentUser;
  }

  Future<String> updateProfile(
      String url, String name, User firebaseUser) async {
    try {
      await firebaseUser.updateProfile(photoURL: url, displayName: name);
      await firebaseUser.reload();
      return 'Profile details updated';
    } catch (e) {
      return e.message;
    }
  }

  Future<String> signIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Signed in";
    } catch (e) {
      return e.message;
    }
  }

  Future<String> signUp({String email, String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return "Signed up";
    } catch (e) {
      return e.message;
    }
  }
}

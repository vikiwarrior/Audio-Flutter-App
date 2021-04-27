import 'package:audio_flutter_app/screens/profileEditPage.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Your cart')),
        body: Column(
          children: [
            Container(
              child: Text('HIIII'),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(ProfileEditPage.routeName);
                },
                child: Text('Edit profile'))
          ],
        ));
  }
}

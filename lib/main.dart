import 'dart:io';
import 'package:audio_flutter_app/provider/AudioUsers.dart';
import 'package:audio_flutter_app/provider/audio.dart';
import 'package:audio_flutter_app/provider/audiomodel.dart';
import 'package:audio_flutter_app/screens/profileEditPage.dart';
import 'package:audio_flutter_app/widget/audiolist.dart';
import 'provider/audios.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/loginPage.dart';
import 'screens/profilepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Audios(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AudioUser(),
        ),
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        routes: {
          UserProfilePage.routeName: (ctx) => UserProfilePage(),
          ProfileEditPage.routeName: (ctx) => ProfileEditPage(),
        },
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      Provider.of<AudioUser>(context, listen: false).setuid(firebaseUser.uid);
      return MyHomePage(title: 'Your Audio Feed ');
    } else {
      return LoginPage();
    }
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _init = true;

  @override
  void didChangeDependencies() async {
    if (_init) {
      await Provider.of<Audios>(context).fetchAndSetAudios();
    }
    _init = false;

    super.didChangeDependencies();
  }

  Future<void> logout() async {
    await context.read<AuthenticationService>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final audioData = Provider.of<Audios>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6200EE),
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(child: AudioList(references: audioData.items)),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF6200EE),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(.60),
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: (value) {
          if (value == 0) {
            MyHomePage(
              title: 'Homepage',
            );
          } else if (value == 1) {
            Navigator.of(context).pushNamed(UserProfilePage.routeName);
          } else if (value == 2) {
            logout();
          }
          // Respond to item press.
        },
        items: [
          BottomNavigationBarItem(
            title: Text('Home'),
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            title: Text('Profile'),
            icon: Icon(Icons.account_circle_rounded),
          ),
          BottomNavigationBarItem(
            title: Text('Logout'),
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF6200EE),
        onPressed: () async {
          FilePickerResult result = await FilePicker.platform.pickFiles();
          File audiofile = File(result.paths.first);
          if (result != null) {
            PlatformFile file = result.files.first;

            print(file.name);

            FirebaseStorage fs = FirebaseStorage.instance;

            Reference rootref = fs.ref();
            String audiofilename = 'audio' + TimeOfDay.now().toString();

            Reference audioFolderRef =
                rootref.child("audios").child(audiofilename);
            String url;

            UploadTask uploadTask = audioFolderRef.putFile(audiofile);
            uploadTask.whenComplete(() async {
              url = await audioFolderRef.getDownloadURL();

              UserModel curruser =
                  Provider.of<AudioUser>(context, listen: false).user;

              await audioData.addAudio(
                Audio(
                    id: '',
                    title: audiofilename,
                    audioUrl: url,
                    owner: curruser.userid,
                    likedBy: []),
              );
              print(url);
            }).catchError((onError) {
              print(onError);
            });
          } else {
            // User canceled the picker
            print('Hiii');
          }
        },
        tooltip: 'Increment',
        child: Icon(Icons.upload_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

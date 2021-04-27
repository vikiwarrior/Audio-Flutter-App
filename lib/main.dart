import 'dart:io';
import 'package:audio_flutter_app/provider/AudioUsers.dart';
import 'package:audio_flutter_app/provider/audio.dart';
import 'package:audio_flutter_app/screens/profileEditPage.dart';
import 'package:audio_flutter_app/widget/audiolist.dart';
import 'provider/audios.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'auth/authentication_service.dart';
import 'screens/loginPage.dart';
import 'screens/profilepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  //

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
          primarySwatch: Colors.blue,
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
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return MyHomePage(title: 'Flutter Demo Home Page');
    }
    return LoginPage();
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

  @override
  Widget build(BuildContext context) {
    final audioData = Provider.of<Audios>(context);
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () async {
                await context.read<AuthenticationService>().signOut();
              },
              child: Text('Logout')),
          TextButton(
            child: Text('Profile page'),
            onPressed: () {
              Navigator.of(context).pushNamed(UserProfilePage.routeName);
            },
          ),
          Expanded(child: AudioList(references: audioData.items)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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

              final User firebaseUser = context.read()<User>();

              await audioData.addAudio(
                Audio(
                    id: '',
                    title: audiofilename,
                    audioUrl: url,
                    owner: firebaseUser.uid,
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
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

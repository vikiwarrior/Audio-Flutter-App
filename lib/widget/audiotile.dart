import 'package:audio_flutter_app/auth/authentication_service.dart';
import 'package:audio_flutter_app/provider/AudioUsers.dart';
import 'package:audio_flutter_app/provider/audio.dart';
import 'package:audio_flutter_app/provider/audiomodel.dart';
import 'package:audio_flutter_app/provider/audios.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AudioLists extends StatefulWidget {
  final List<Audio> references;

  const AudioLists({
    Key key,
    @required this.references,
  }) : super(key: key);

  @override
  _AudioListsState createState() => _AudioListsState();
}

class _AudioListsState extends State<AudioLists> {
  bool isPlaying;
  AudioPlayer audioPlayer;
  int selectedIndex;
  String userid;
  @override
  void initState() {
    super.initState();
    isPlaying = false;
    audioPlayer = AudioPlayer();
    selectedIndex = -1;
    UserModel curruser = Provider.of<AudioUser>(context, listen: false).user;
    userid = curruser.userid;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.references.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(widget.references.elementAt(index).title),
          trailing: (selectedIndex == index) && (isPlaying == true)
              ? IconButton(
                  icon: Icon(Icons.pause),
                  onPressed: () => _onpressedpause(index),
                )
              : IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () => _onpressedplay(index),
                ),
          leading: (widget.references.elementAt(index).likedBy != null)
              ? Text(
                  widget.references.elementAt(index).likedBy.length.toString() +
                      ' Likes')
              : Text('0 Likes'),
        );
      },
    );
  }

  Future<void> _onpressedplay(int index) async {
    if (selectedIndex == index && isPlaying == false) {
      await audioPlayer.resume();
      setState(() {
        isPlaying = true;
      });
    } else {
      await audioPlayer.play(widget.references.elementAt(index).audioUrl,
          isLocal: false);
      setState(() {
        selectedIndex = index;
        isPlaying = true;
      });

      audioPlayer.onPlayerCompletion.listen((value) {
        setState(() {
          selectedIndex = -1;
          isPlaying = false;
        });
      });
    }
  }

  Future<void> _onpressedpause(int index) async {
    await audioPlayer.pause();

    setState(() {
      isPlaying = false;
    });
  }

  Future<void> _onpressedlike(int index, String id) async {
    print(index);
    print(id);
    await Provider.of<Audios>(context, listen: false).decrementlike(id, userid);
  }

  Future<void> _onpressedunlike(int index, String id) async {
    print(index);
    print(id);
    await Provider.of<Audios>(context, listen: false).incrementlike(id, userid);
  }
}

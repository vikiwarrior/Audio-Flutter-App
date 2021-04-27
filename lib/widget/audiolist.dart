import 'package:audio_flutter_app/auth/authentication_service.dart';
import 'package:audio_flutter_app/provider/AudioUsers.dart';
import 'package:audio_flutter_app/provider/audio.dart';
import 'package:audio_flutter_app/provider/audiomodel.dart';
import 'package:audio_flutter_app/provider/audios.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AudioList extends StatefulWidget {
  final List<Audio> references;

  const AudioList({
    Key key,
    @required this.references,
  }) : super(key: key);

  @override
  _AudioListState createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
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
    List<Audio> list = widget.references;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.references.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            ListTile(
              title: Text(widget.references.elementAt(index).title),
              trailing: (selectedIndex == index) && (isPlaying == true)
                  ? IconButton(
                      icon: Icon(
                        Icons.pause,
                        color: Color(0xFF6200EE),
                      ),
                      onPressed: () => _onpressedpause(index),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.play_arrow,
                        color: Color(0xFF6200EE),
                      ),
                      onPressed: () => _onpressedplay(index),
                    ),
              leading: (widget.references.elementAt(index).likedBy != null &&
                      widget.references
                          .elementAt(index)
                          .likedBy
                          .any((element) => element == userid))
                  ? IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () => _onpressedlike(
                          index, widget.references.elementAt(index).id),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => _onpressedunlike(
                          index, widget.references.elementAt(index).id),
                    ),
            ),
            Divider(
              color: Colors.grey,
            )
          ],
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

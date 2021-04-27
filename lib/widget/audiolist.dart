import 'package:audio_flutter_app/provider/audio.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    isPlaying = false;
    audioPlayer = AudioPlayer();
    selectedIndex = -1;
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
                  ));
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
}

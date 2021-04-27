import 'package:flutter/material.dart';
import '../provider/audio.dart' as aud;

class AudioTile extends StatefulWidget {
  final aud.Audio audio;
  AudioTile(
    this.audio,
  );

  @override
  _AudioTileState createState() => _AudioTileState();
}

class _AudioTileState extends State<AudioTile> {
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text(' as ${widget.audio.title}'),
              subtitle: Text(' fesc ${widget.audio.audioUrl}'),
            ),
          ],
        ));
  }
}

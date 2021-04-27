import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Audio with ChangeNotifier {
  final String id;
  final String title;
  final String audioUrl;
  List<String> likedBy = [];
  final String owner;

  Audio(
      {@required this.owner,
      @required this.id,
      @required this.title,
      @required this.audioUrl,
      this.likedBy});
}

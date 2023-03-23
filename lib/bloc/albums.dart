//Progrm the person class
//https://youtu.be/Mn254cnduOY?t=2650
import 'package:flutter/foundation.dart' show immutable;

@immutable
class Album {
  final int userId;
  final int id;
  final String title;
  //final String url;
  //final String thumbnailUrl;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
    //required this.url,
    //required this.thumbnailUrl,
  });

  Album.fromJson(Map<String, dynamic> json)
      : userId = json['userId'] as int,
        id = json['id'] as int,
        title = json['title'] as String;
  //url = json['url'] as String,
  //thumbnailUrl = json['thumbnailUrl'] as String;

//https://youtu.be/Mn254cnduOY?t=4869
//put to test
  @override
  String toString() => 'Album (userId=$userId, id=$id, title =$title)';
} //, url=$url,thumbnailUrl=$thumbnailUrl

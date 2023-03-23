//https://youtu.be/Mn254cnduOY?t=5536
import 'package:flutter/foundation.dart' show immutable;
import 'package:testingbloc_course/bloc/albums.dart';

//https://youtu.be/Mn254cnduOY?t=5683
const album1Url = 'https://jsonplaceholder.typicode.com/albums';
const album2Url = 'https://jsonplaceholder.typicode.com/albums';

typedef AlbumsLoader = Future<Iterable<Album>> Function(String url);

//https://youtu.be/Mn254cnduOY?t=2176
//want to tell the bloc to load something
@immutable
abstract class LoadAction {
  const LoadAction();
}

//https://youtu.be/Mn254cnduOY?t=2534
//Define an action for loading persons

@immutable
class LoadAlbumAction implements LoadAction {
  //https://youtu.be/Mn254cnduOY?t=5685
  // final AlbumUrl url;

  final String url;

  //https://youtu.be/Mn254cnduOY?t=5884
  //dependency injection
  final AlbumsLoader loader;
  const LoadAlbumAction({
    required this.url,
    required this.loader,
  }) : super();
}

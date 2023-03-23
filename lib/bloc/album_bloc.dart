//https://youtu.be/Mn254cnduOY?t=6000

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testingbloc_course/bloc/albums.dart';
import 'package:testingbloc_course/bloc/bloc_actions.dart';

extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length &&
      {...this}.intersection({...other}).length == length;
}

//https://youtu.be/Mn254cnduOY?t=6255

//https://youtu.be/Mn254cnduOY?t=3084
//defin the result of the bloc
@immutable
class FetchResult {
  final Iterable<Album> album;
  final bool isRetrievedFromCache;

  const FetchResult({required this.album, required this.isRetrievedFromCache});

//determine how it is displayed in the logged
  @override
  String toString() =>
      'FetchResult ( isRetrievedFromCache= $isRetrievedFromCache, album =$album)';

//https://youtu.be/Mn254cnduOY?t=6320

  @override
  bool operator ==(covariant FetchResult other) =>
      album.isEqualToIgnoringOrdering(other.album) &&
      isRetrievedFromCache == other.isRetrievedFromCache;

  @override
  int get hashCode => Object.hash(album, isRetrievedFromCache);
}

//https://youtu.be/Mn254cnduOY?t=5894

class AlbumBloc extends Bloc<LoadAction, FetchResult?> {
  //https://youtu.be/Mn254cnduOY?t=6426
  //https://youtu.be/Mn254cnduOY?t=3385
  //cache in the bloc
  final Map<String, Iterable<Album>> _cache = {};

  AlbumBloc() : super(null) {
    //https://youtu.be/Mn254cnduOY?t=3422
    //Handle the loadpersonaaction in the constructor
    on<LoadAlbumAction>(
      //event is the input, emit is the output
      (event, emit) async {
        final url = event.url;
        if (_cache.containsKey(url)) {
          //we have the value in the cache
          final cachedAlbums = _cache[url]!;
          final result = FetchResult(
            album: cachedAlbums,
            isRetrievedFromCache: true,
          );
          emit(result);
        } else {
          final loader = event.loader;
          final albums = await loader(url);
          _cache[url] = albums;
          final result = FetchResult(
            album: albums,
            isRetrievedFromCache: false,
          );
          emit(result);
        }
      },
    );
  }
}

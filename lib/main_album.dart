// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//logging
//https://youtu.be/Mn254cnduOY?t=4788
import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

//https://youtu.be/Mn254cnduOY?t=1924
//want to serve two JSOn files locally
void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    //Adding BlocProvider
    //https://youtu.be/Mn254cnduOY?t=3749
    home: BlocProvider(
      create: (_) => AlbumBloc(),
      child: const HomePage(),
    ),
  ));
}

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
  final AlbumUrl url;
  const LoadAlbumAction({required this.url}) : super();
}

//https://youtu.be/Mn254cnduOY?t=2431
enum AlbumUrl {
  album1,
  album2,
}

extension UrlString on AlbumUrl {
  String get urlString {
    switch (this) {
      case AlbumUrl.album1:
        return 'https://jsonplaceholder.typicode.com/albums';
      case AlbumUrl.album2:
        return 'https://jsonplaceholder.typicode.com/albums';
    }
  }
}

//Progrm the person class
//https://youtu.be/Mn254cnduOY?t=2650
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

//https://youtu.be/Mn254cnduOY?t=2775
//Download and parse JSON
Future<Iterable<Album>> getAlbum(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Album.fromJson(e)));

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
}

//Write the bloc header
//https://youtu.be/Mn254cnduOY?t=3271
class AlbumBloc extends Bloc<LoadAction, FetchResult?> {
  //https://youtu.be/Mn254cnduOY?t=3385
  //cache in the bloc
  final Map<AlbumUrl, Iterable<Album>> _cache = {};

  AlbumBloc() : super(null) {
    //https://youtu.be/Mn254cnduOY?t=3422
    //Handle the loadpersonaaction in the constructor
    on<LoadAlbumAction>(
      //event is the input, emit is the output
      (event, emit) async {
        final url = event.url;
        if (_cache.containsKey(url)) {
          //we have the value in the cache
          final cachedAlbum = _cache[url]!;
          final result = FetchResult(
            album: cachedAlbum,
            isRetrievedFromCache: true,
          );
          emit(result);
        } else {
          final albums = await getAlbum(url.urlString);
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

//https://youtu.be/Mn254cnduOY?t=3893
//because of this, we can write this code letter on 'final person = persons[index]!;'
extension Subscript<T> on Iterable {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      //https://youtu.be/Mn254cnduOY?t=4105
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  //https://youtu.be/Mn254cnduOY?t=4199
                  context.read<AlbumBloc>().add(const LoadAlbumAction(
                        url: AlbumUrl.album1,
                      ));
                },
                child: const Text('Load json #1'),
              ),
              TextButton(
                onPressed: () {
                  //https://youtu.be/Mn254cnduOY?t=4199
                  context.read<AlbumBloc>().add(const LoadAlbumAction(
                        url: AlbumUrl.album2,
                      ));
                },
                child: const Text('Load json #2'),
              ),
            ],
          ),
          //https://youtu.be/Mn254cnduOY?t=4323
          BlocBuilder<AlbumBloc, FetchResult?>(
            buildWhen: (previousResult, currentResult) {
              return previousResult?.album != currentResult?.album;
            },
            builder: ((context, fetchResult) {
              fetchResult?.log();
              final albums = fetchResult?.album;
              if (albums == null) {
                return const SizedBox();
              }
              //https://youtu.be/PD0eAXLd5ls?t=6
              return Expanded(
                child: ListView.builder(
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index]!;
                    if (album.title != null) {
                      return ListTile(
                        title: Text(album.title),
                      );
                    }
                    return const ListTile(
                      title: Text('Empty code'),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

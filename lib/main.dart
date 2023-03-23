// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testingbloc_course/bloc/bloc_actions.dart';

//logging
//https://youtu.be/Mn254cnduOY?t=4788
import 'dart:developer' as devtools show log;

import 'bloc/album_bloc.dart';
import 'bloc/albums.dart';

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

//https://youtu.be/Mn254cnduOY?t=2775
//Download and parse JSON
Future<Iterable<Album>> getAlbum(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Album.fromJson(e)));

//Write the bloc header
//https://youtu.be/Mn254cnduOY?t=3271

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
                        url: album1Url,
                        loader: getAlbum,
                      ));
                },
                child: const Text('Load json #1'),
              ),
              TextButton(
                onPressed: () {
                  //https://youtu.be/Mn254cnduOY?t=4199
                  context.read<AlbumBloc>().add(const LoadAlbumAction(
                        url: album2Url,
                        //!Shouldn't we load the URL for this this such as getAlbum(album2Url)?
                        //!it is already putting in the url from album_bloc 67-  final albums = await loader(url);
                        loader: getAlbum,
                      ));
                },
                //TODO: Will not load this one because it is using the same dataset and we have the cache looks for changes
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

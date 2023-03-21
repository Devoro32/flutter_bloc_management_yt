// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//! refused (OS Error: Connection refused, errno = 111), address = 127.0.0.1, port = 37460
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
      create: (_) => PersonsBloc(),
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
class LoadPersonaAction implements LoadAction {
  final PersonUrl url;
  const LoadPersonaAction({required this.url}) : super();
}

//https://youtu.be/Mn254cnduOY?t=2431
enum PersonUrl {
  persons1,
  persons2,
}

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.persons1:
        return 'https://hacker-news.firebaseio.com/v0/topstories.json';
      case PersonUrl.persons2:
        return 'http://127.0.0.1:5500/lib/api/person2.json';
    }
  }
}

//Progrm the person class
//https://youtu.be/Mn254cnduOY?t=2650
@immutable
class Person {
  final String name;
  final int age;
  final int id;
  final String username;
  final String email;
  final String address;
  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final List geo;
  final int lat;
  final int lng;

  const Person({
    required this.name,
    required this.age,
    required this.id,
    required this.username,
    required this.email,
    required this.address,
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
    required this.lat,
    required this.lng,
  });

  Person.fromJson(Map<String, int> json)
      : name = json['name'] as String,
        age = json['age'] as int,
        id = json['id'] as int,
        username = json['username'] as String,
        email = json['email'] as String,
        address = json['address'] as String,
        street = json['street'] as String,
        suite = json['suite'] as String,
        city = json['city'] as String,
        zipcode = json['zipcode'] as String,
        geo = json['geo'] as List,
        lat = json['lat'] as int,
        lng = json['lng'] as int;

//https://youtu.be/Mn254cnduOY?t=4869
//put to test
  @override
  String toString() {
    return 'Person ( name =$name, age=$age, username=$username, email=$email,address=$address, street=$street,suite=$suite,city=$city,zipcode=$zipcode, geo=$geo,lat=$lat, lng=$lng)';
  }
}

//https://youtu.be/Mn254cnduOY?t=2775
//Download and parse JSON
Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

//https://youtu.be/Mn254cnduOY?t=3084
//defin the result of the bloc
@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  const FetchResult(
      {required this.persons, required this.isRetrievedFromCache});

  @override
  String toString() =>
      'FetchResult ( isRetrievedFromCache= $isRetrievedFromCache, persons =$persons)';
}

//Write the bloc header
//https://youtu.be/Mn254cnduOY?t=3271
class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  //https://youtu.be/Mn254cnduOY?t=3385
  //cache in the bloc
  final Map<PersonUrl, Iterable<Person>> _cache = {};

  PersonsBloc() : super(null) {
    //https://youtu.be/Mn254cnduOY?t=3422
    //Handle the loadpersonaaction in the constructor
    on<LoadPersonaAction>(
      //event is the input, emit is the output
      (event, emit) async {
        final url = event.url;
        if (_cache.containsKey(url)) {
          //we have the value in the cache
          final cachedPersons = _cache[url]!;
          final result = FetchResult(
            persons: cachedPersons,
            isRetrievedFromCache: true,
          );
          emit(result);
        } else {
          final persons = await getPersons(url.urlString);
          _cache[url] = persons;
          final result = FetchResult(
            persons: persons,
            isRetrievedFromCache: false,
          );
          emit(result);
        }
      },
    );
  }
}

//https://youtu.be/Mn254cnduOY?t=3893
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
                  context.read<PersonsBloc>().add(const LoadPersonaAction(
                        url: PersonUrl.persons1,
                      ));
                },
                child: const Text('Load json #1'),
              ),
              TextButton(
                onPressed: () {
                  //https://youtu.be/Mn254cnduOY?t=4199
                  context.read<PersonsBloc>().add(const LoadPersonaAction(
                        url: PersonUrl.persons2,
                      ));
                },
                child: const Text('Load json #2'),
              ),
            ],
          ),
          //https://youtu.be/Mn254cnduOY?t=4323
          BlocBuilder<PersonsBloc, FetchResult?>(
            buildWhen: (previousResult, currentResult) {
              return previousResult?.persons != currentResult?.persons;
            },
            builder: ((context, fetchResult) {
              fetchResult?.log();
              final persons = fetchResult?.persons;
              if (persons == null) {
                return const SizedBox();
              }
              return ListView.builder(
                itemCount: persons.length,
                itemBuilder: (context, index) {
                  final person = persons[index]!;
                  return ListTile(
                    title: Text(person.name),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

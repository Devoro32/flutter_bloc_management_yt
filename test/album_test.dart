//https://youtu.be/Mn254cnduOY?t=6775
//all test files need to end with 'test.dart'

//to run the test: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:testingbloc_course/bloc/album_bloc.dart';
import 'package:testingbloc_course/bloc/albums.dart';
import 'package:testingbloc_course/bloc/bloc_actions.dart';

const mockAlbum1 = [
  Album(userId: 1, id: 1, title: 'quidem molestiae enim'),
  Album(userId: 2, id: 2, title: 'sunt qui excepturi placeat culpa'),
];
//https://youtu.be/Mn254cnduOY?t=6998
const mockAlbum2 = [
  Album(userId: 1, id: 1, title: 'quidem molestiae enim'),
  Album(userId: 2, id: 2, title: 'sunt qui excepturi placeat culpa'),
];

//https://youtu.be/Mn254cnduOY?t=7078
Future<Iterable<Album>> mockGetPersons1(String _) => Future.value(mockAlbum1);
Future<Iterable<Album>> mockGetPersons2(String _) => Future.value(mockAlbum2);

void main() {
  //https://youtu.be/Mn254cnduOY?t=7400
  group(
    'Testing bloc',
    () {
      late AlbumBloc bloc;
      //create the setup that all the test requires
      //create a fresh copy of the album bloc
      //create as a new instance, once per test in the group
      setUp(() {
        bloc = AlbumBloc();
      });

      blocTest<AlbumBloc, FetchResult?>(
        'Test initial state',
        build: () => bloc,
        verify: (bloc) => expect(bloc.state, null),
      );

      //https://youtu.be/Mn254cnduOY?t=7900
      //fetch mock data (album1) and comparing it with fetch result
      blocTest<AlbumBloc, FetchResult?>(
        'Test initial state',
        build: () => bloc,
        act: (bloc) {
          bloc.add(
            const LoadAlbumAction(
              url: 'Dummy_url_1',
              loader: mockGetPersons1,
            ),
          );
          bloc.add(
            const LoadAlbumAction(
              url: 'Dummy_url_1',
              loader: mockGetPersons1,
            ),
          );
        }, //end of the action
        expect: () => [
          const FetchResult(
            album: mockAlbum1,
            isRetrievedFromCache: false,
          ),
          const FetchResult(
            album: mockAlbum1,
            isRetrievedFromCache: true,
          ),
        ],
      ); //end of bloc test

      //fetch mock data (album2) and comparing it with fetch result
      blocTest<AlbumBloc, FetchResult?>(
        'Test initial state',
        build: () => bloc,
        act: (bloc) {
          bloc.add(
            const LoadAlbumAction(
              url: 'Dummy_url_2',
              loader: mockGetPersons2,
            ),
          );
          bloc.add(
            const LoadAlbumAction(
              url: 'Dummy_url_2',
              loader: mockGetPersons2,
            ),
          );
        }, //end of the action
        expect: () => [
          const FetchResult(
            album: mockAlbum2,
            isRetrievedFromCache: false,
          ),
          const FetchResult(
            album: mockAlbum2,
            isRetrievedFromCache: true,
          ),
        ],
      ); //end of the bloc test
    },
  );
}

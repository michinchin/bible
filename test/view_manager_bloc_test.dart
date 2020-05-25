import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:tec_util/tec_util.dart' as tec;

import 'package:bible/blocs/view_manager_bloc.dart';

void main() {
  group('ViewManagerBloc', () {
    tec.KeyValueStore kvStore;
    ViewManagerBloc bloc; // ignore: close_sinks

    setUpAll(() {
      ViewManager.shared.register('test',
          title: 'test', builder: (context, state) => Container());
    });

    setUp(() {
      kvStore = tec.MemoryKVStore();
      bloc = ViewManagerBloc(kvStore: kvStore);
    });

    test('initial state is empty list', () {
      expect(bloc.initialState, ViewManagerState([], 1));
    });

    blocTest<ViewManagerBloc, ViewManagerEvent, ViewManagerState>(
      'emits correct states when various events are added',
      build: () async => bloc,
      act: (bloc) {
        bloc
          ..add(add('1'))
          ..add(add('2'))
          ..add(move(0, 1))
          ..add(move(0, 1))
          ..add(remove(0))
          ..add(remove(0));
        return Future.value();
      },
      expect: <dynamic>[
        ViewManagerState([view(1, '1')], 2),
        ViewManagerState([view(1, '1'), view(2, '2')], 3),
        ViewManagerState([view(2, '2'), view(1, '1')], 3),
        ViewManagerState([view(1, '1'), view(2, '2')], 3),
        ViewManagerState([view(2, '2')], 3),
        ViewManagerState([], 3),
      ],
    );
  });
}

//
// UTILITY FUNCTIONS
//

ViewManagerEvent add(String data) =>
    ViewManagerEvent.add(type: 'test', data: data);

ViewManagerEvent move(int from, int to) =>
    ViewManagerEvent.move(fromPosition: from, toPosition: to);

ViewManagerEvent remove(int position) => ViewManagerEvent.remove(position);

ViewState view(int uid, String data) => ViewState(uid: uid, type: 'test', data: data);

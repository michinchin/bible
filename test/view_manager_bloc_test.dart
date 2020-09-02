import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:tec_util/tec_util.dart' as tec;

import 'package:bible/blocs/view_manager/view_manager_bloc.dart';

void main() {
  group('ViewManagerBloc', () {
    tec.KeyValueStore kvStore;
    ViewManagerBloc bloc; // ignore: close_sinks

    setUpAll(() {
      ViewManager.shared.register('test',
          title: 'test', bodyBuilder: (context, state, size) => Container());
    });

    setUp(() {
      kvStore = tec.MemoryKVStore();
      bloc = ViewManagerBloc(kvStore: kvStore);
    });

    test('initial state is empty list', () {
      expect(bloc.state, ViewManagerState([bcv], 0, 2, ViewManagerStateBuildInfo.build));
    });

    blocTest<ViewManagerBloc, ViewManagerState>(
      'emits correct states when various events are added',
      build: () => bloc,
      act: (bloc) {
        bloc
          ..add(add('1'))
          ..add(add('2'))
          ..add(move(1, 2))
          ..add(move(1, 2))
          ..add(remove(2))
          ..add(remove(3));
      },
      expect: <dynamic>[
        ViewManagerState([bcv, view(2, '1')], 0, 3, ViewManagerStateBuildInfo.build),
        ViewManagerState([bcv, view(2, '1'), view(3, '2')], 0, 4, ViewManagerStateBuildInfo.build),
        ViewManagerState([bcv, view(3, '2'), view(2, '1')], 0, 4, ViewManagerStateBuildInfo.build),
        ViewManagerState([bcv, view(2, '1'), view(3, '2')], 0, 4, ViewManagerStateBuildInfo.build),
        ViewManagerState([bcv, view(3, '2')], 0, 4, ViewManagerStateBuildInfo.build),
        ViewManagerState([bcv], 0, 4, ViewManagerStateBuildInfo.build),
      ],
    );
  });
}

//
// UTILITY FUNCTIONS
//

final bcv = ViewState(uid: 1, type: 'BibleChapter');

ViewManagerEvent add(String data) => ViewManagerEvent.add(type: 'test', data: data);

ViewManagerEvent move(int from, int to) =>
    ViewManagerEvent.move(fromPosition: from, toPosition: to);

ViewManagerEvent remove(int position) => ViewManagerEvent.remove(position);

ViewState view(int uid, String data) => ViewState(uid: uid, type: 'test', data: data);

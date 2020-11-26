import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:tec_util/tec_util.dart' as tec;

import 'package:bible/blocs/view_manager/view_manager_bloc.dart';

class ViewableTest extends Viewable {
  ViewableTest(String typeName, IconData icon) : super(typeName, icon);

  @override
  Widget builder(BuildContext context, ViewState state, Size size) {
    return Container();
  }

  @override
  Widget floatingTitleBuilder(BuildContext context, ViewState state, Size size) {
    return Container(
      constraints: const BoxConstraints(minWidth: double.infinity, minHeight: double.infinity),
      color: Colors.red,
    );
  }

  @override
  String menuTitle({BuildContext context, ViewState state}) => 'test';

  @override
  Future<ViewData> dataForNewView(
          {BuildContext context, int currentViewId, Map<String, dynamic> options}) =>
      Future.value(const ViewData());

  @override
  ViewDataBloc createViewDataBloc(BuildContext context, ViewState state) {
    return ViewDataBloc(context.viewManager, state.uid, ViewData.fromContext(context, state.uid));
  }
}

void main() {
  group('ViewManagerBloc', () {
    tec.KeyValueStore kvStore;
    ViewManagerBloc bloc; // ignore: close_sinks

    setUpAll(() {
      ViewManager.defaultViewType = 'test';
      ViewManager.shared.register(ViewableTest('test', null));
    });

    setUp(() {
      kvStore = tec.MemoryKVStore();
      bloc = ViewManagerBloc(kvStore: kvStore);
    });

    test('initial state is empty list', () {
      expect(bloc.state, ViewManagerState([bcv], 0, 2));
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
        ViewManagerState([bcv, view(2)], 0, 3),
        ViewManagerState([bcv, view(2), view(3)], 0, 4),
        ViewManagerState([bcv, view(3), view(2)], 0, 4),
        ViewManagerState([bcv, view(2), view(3)], 0, 4),
        ViewManagerState([bcv, view(3)], 0, 4),
        ViewManagerState([bcv], 0, 4),
      ],
    );
  });
}

//
// UTILITY FUNCTIONS
//

final bcv = ViewState(uid: 1, type: 'test');

ViewManagerEvent add(String data) => ViewManagerEvent.add(type: 'test', data: data);

ViewManagerEvent move(int from, int to) =>
    ViewManagerEvent.move(fromPosition: from, toPosition: to);

ViewManagerEvent remove(int position) => ViewManagerEvent.remove(position);

ViewState view(int uid) => ViewState(uid: uid, type: 'test');

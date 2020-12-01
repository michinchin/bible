import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TecTab { today, library, plans, store, reader, overlay }

class TabManagerState {
  final TecTab tab;
  TabManagerState(this.tab);
}

class TabManagerBloc extends Bloc<TecTab, TabManagerState> {
  TabManagerBloc() : super(TabManagerState(TecTab.reader));

  @override
  Stream<TabManagerState> mapEventToState(TecTab event) async* {
    yield TabManagerState(event);
  }
}

extension ViewManagerExtOnBuildContext on BuildContext {
  TabManagerBloc get tabManager => BlocProvider.of<TabManagerBloc>(this);
}

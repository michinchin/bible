import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TecTab { today, library, plans, store, reader, overlay }

class TabManagerCubit extends Cubit<TecTab> {
  TabManagerCubit({TecTab tab}) : super(tab ?? TecTab.reader);
  void changeTab(TecTab tab) => emit(tab);
}

extension ViewManagerExtOnBuildContext on BuildContext {
  TabManagerCubit get tabManager => BlocProvider.of<TabManagerCubit>(this);
}

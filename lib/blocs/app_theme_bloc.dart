import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;

enum AppThemeEvent { toggle }

class AppThemeBloc extends Bloc<AppThemeEvent, ThemeMode> {
  @override
  ThemeMode get initialState {
    final isDarkTheme = tec.Prefs.shared.getBool('isDarkTheme');
    if (isDarkTheme == null) {
      return ThemeMode.system;
    } else {
      return isDarkTheme ? ThemeMode.dark : ThemeMode.light;
    }
  }

  @override
  Stream<ThemeMode> mapEventToState(AppThemeEvent event) async* {
    switch (event) {
      case AppThemeEvent.toggle:
        {
          final isDarkTheme = state != ThemeMode.dark;
          await tec.Prefs.shared.setBool('isDarkTheme', isDarkTheme);
          yield isDarkTheme ? ThemeMode.dark : ThemeMode.light;
          break;
        }
    }
  }
}

import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;

enum ThemeModeEvent { toggle }

class ThemeModeBloc extends Bloc<ThemeModeEvent, ThemeMode> {
  ThemeModeBloc() : super(initialState);

  static ThemeMode get initialState {
    final isDarkTheme = tec.Prefs.shared.getBool('isDarkTheme');
    if (isDarkTheme == null) {
      return ThemeMode.system;
    } else {
      return isDarkTheme ? ThemeMode.dark : ThemeMode.light;
    }
  }

  @override
  Stream<ThemeMode> mapEventToState(ThemeModeEvent event) async* {
    switch (event) {
      case ThemeModeEvent.toggle:
        {
          ThemeMode newThemeMode;
          final isDark = (WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
          if (state == ThemeMode.system || ((state == ThemeMode.dark) == isDark)) {
            newThemeMode = isDark ? ThemeMode.light : ThemeMode.dark;
            await tec.Prefs.shared.setBool('isDarkTheme', !isDark);
          } else {
            newThemeMode = ThemeMode.system;
            await tec.Prefs.shared.remove('isDarkTheme');
          }
          // tec.dmPrint('newThemeMode: $newThemeMode');
          yield newThemeMode;
          break;
        }
    }
  }
}

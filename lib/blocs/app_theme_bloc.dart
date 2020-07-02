import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

enum ThemeModeEvent { toggle }

class ThemeModeBloc extends Bloc<ThemeModeEvent, ThemeMode> {
  @override
  ThemeMode get initialState {
    final isDarkTheme = tec.Prefs.shared.getBool('isDarkTheme');
    if (isDarkTheme == null) {
      final systemDarkMode =
          SchedulerBinding.instance.window.platformBrightness ==
              Brightness.dark;
      SystemChrome.setSystemUIOverlayStyle(
          systemDarkMode ? lightOverlayStyle : darkOverlayStyle);
      tec.Prefs.shared.setBool('isDarkTheme', systemDarkMode);
      return systemDarkMode ? ThemeMode.dark : ThemeMode.light;
    } else {
      SystemChrome.setSystemUIOverlayStyle(
          isDarkTheme ? lightOverlayStyle : darkOverlayStyle);
      return isDarkTheme ? ThemeMode.dark : ThemeMode.light;
    }
  }

  @override
  Stream<ThemeMode> mapEventToState(ThemeModeEvent event) async* {
    switch (event) {
      case ThemeModeEvent.toggle:
        {
          final isDarkTheme = state != ThemeMode.dark;
          await tec.Prefs.shared.setBool('isDarkTheme', isDarkTheme);
          SystemChrome.setSystemUIOverlayStyle(
              isDarkTheme ? lightOverlayStyle : darkOverlayStyle);
          yield isDarkTheme ? ThemeMode.dark : ThemeMode.light;
          break;
        }
    }
  }
}

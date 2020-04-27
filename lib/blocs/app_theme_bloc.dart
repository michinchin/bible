import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;

enum AppThemeEvent { toggle }

class AppThemeBloc extends Bloc<AppThemeEvent, ThemeData> {
  @override
  ThemeData get initialState =>
      tec.Prefs.shared.getBool('isDarkTheme', defaultValue: false)
          ? ThemeData.dark()
          : ThemeData.light();

  @override
  Stream<ThemeData> mapEventToState(AppThemeEvent event) async* {
    switch (event) {
      case AppThemeEvent.toggle:
        {
          final isDarkTheme = state != ThemeData.dark();
          await tec.Prefs.shared.setBool('isDarkTheme', isDarkTheme);
          yield isDarkTheme ? ThemeData.dark() : ThemeData.light();
          break;
        }
    }
  }
}

// theme: ThemeData(
//   primarySwatch: Colors.blue,
//   visualDensity: VisualDensity.adaptivePlatformDensity,
// ),

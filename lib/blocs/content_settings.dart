import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../models/const.dart';

///
/// ContentSettings
///
class ContentSettings {
  final double textScaleFactor;
  final String fontName;

  ContentSettings({
    @required this.textScaleFactor,
    @required this.fontName,
  }) : assert(textScaleFactor != null && fontName != null);

  ContentSettings copyWith({
    double textScaleFactor,
    String fontName,
  }) =>
      ContentSettings(
        textScaleFactor: textScaleFactor ?? this.textScaleFactor,
        fontName: fontName ?? this.fontName,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentSettings &&
          runtimeType == other.runtimeType &&
          textScaleFactor == other.textScaleFactor &&
          fontName == other.fontName;

  @override
  int get hashCode => textScaleFactor.hashCode ^ fontName.hashCode;

  @override
  String toString() =>
      '{ "textScaleFactor": $textScaleFactor, "fontName": ${jsonEncode(fontName)} }';
}

///
/// ContentSettingsBloc
///
class ContentSettingsBloc extends Cubit<ContentSettings> {
  ContentSettingsBloc()
      : super(ContentSettings(
          textScaleFactor:
              tec.Prefs.shared.getDouble(Const.prefContentTextScaleFactor, defaultValue: 1.35),
          fontName: tec.Prefs.shared.getString(Const.prefContentFontName, defaultValue: ''),
        ));

  void updateWith(ContentSettings settings) {
    assert(settings != null);

    if (state.textScaleFactor != settings.textScaleFactor) {
      tec.Prefs.shared.setDouble(Const.prefContentTextScaleFactor, settings.textScaleFactor);
    }

    if (state.fontName != settings.fontName) {
      tec.Prefs.shared.setString(Const.prefContentFontName, settings.fontName);
    }

    emit(settings);
  }
}

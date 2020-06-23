import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:tec_user_account/tec_user_account.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import 'labels.dart';

class AppSettings {
  static final AppSettings shared = AppSettings._();
  factory AppSettings() => shared;
  AppSettings._();

  //
  // PUBLIC API
  //

  tec.DeviceInfo deviceInfo;
  tua.UserAccount userAccount;

  ///
  /// The font scale factor for content (e.g. devo or Bible HTML).
  ///
  final contentTextScaleFactor = BehaviorSubject<double>.seeded(1); // ignore: close_sinks

  ///
  /// Loads the app settings. This must only be called once.
  ///
  Future<void> load({
    @required String appName,
    @required List<tua.UserItemType> itemsToSync,
  }) async {
    assert(shared.userAccount == null, 'AppSettings.load() must only be called once.');

    deviceInfo = await tec.DeviceInfo.fetch();
    tec.dmPrint(
        'Running on ${deviceInfo.productName} with ${tec.platformName} ${deviceInfo.version}');

    final platformPrefix = tec.platformName == 'ANDROID' ? 'PLAY' : tec.platformName;
    final appPrefix = '${platformPrefix}_$appName';
    userAccount = await tua.UserAccount.init(
      kvStore: _KVStore(),
      deviceUid: deviceInfo.deviceUid,
      appPrefix: appPrefix,
      itemTypesToSync: itemsToSync,
    );

    contentTextScaleFactor
      ..add((tec.Prefs.shared.getDouble(Labels.prefContentTextScaleFactor, defaultValue: 1.2)))
      ..listen((scaleFactor) {
        tec.Prefs.shared.setDouble(Labels.prefContentTextScaleFactor, scaleFactor);
      });
  }
}

///
/// Returns the text scale factor for content (e.g. Bible or study content HTML).
///
double contentTextScaleFactorWith(
  BuildContext context, {
  bool forAbsoluteFontSize = true,
  double dampingFactor = defaultDampingFactor,
  double minScaleFactor = minContentScaleFactor,
  double maxScaleFactor = maxContentScaleFactor,
}) {
  var scale = scaleFactorWith(
    context,
    dampingFactor: dampingFactor,
  );
  if (forAbsoluteFontSize) {
    scale = scale * MediaQuery.of(context).textScaleFactor;
  }
  scale = scale * AppSettings.shared.contentTextScaleFactor.value;
  return math.min(maxScaleFactor, math.max(minScaleFactor, scale));
}

//
// PRIVATE STUFF
//

/// _KVStore for use with UserAccount instance.
class _KVStore with tua.UserAccountKVStore {
  _KVStore();

  @override
  String getString(String key, {String defaultValue}) {
    return tec.Prefs.shared.getString(key, defaultValue: defaultValue);
  }

  @override
  Future<bool> setString(String key, String value) async {
    return tec.Prefs.shared.setString(key, value);
  }
}

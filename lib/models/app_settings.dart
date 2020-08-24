import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedantic/pedantic.dart';
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
  /// The font scale factor for content (e.g. Bible or study content HTML).
  ///
  final contentTextScaleFactor = BehaviorSubject<double>.seeded(1); // ignore: close_sinks

  ///
  /// The font scale factor for content (e.g. Bible or study content HTML).
  ///
  final contentFontName = BehaviorSubject<String>.seeded(''); // ignore: close_sinks

  ///
  /// isDarkTheme
  ///
  bool isDarkTheme() {
    // if it's been set in the app - return that
    var isDarkTheme = tec.Prefs.shared.getBool('isDarkTheme');

    // otherwise check system dark mode...
    isDarkTheme ??= (WidgetsBinding.instance.window.platformBrightness == Brightness.dark);

    return isDarkTheme;
  }

  ///
  /// OverlayStyle
  ///
  SystemUiOverlayStyle overlayStyle(BuildContext context) {
    var overlayStyle = isDarkTheme() ? lightOverlayStyle : darkOverlayStyle;

    if (tec.platformIs(tec.Platform.android) && !TecScaffoldWrapper.isAndroidFullScreen()) {
      overlayStyle = overlayStyle.copyWith(systemNavigationBarColor: Theme.of(context).canvasColor);
    }

    return overlayStyle;
  }

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

    // we want to open the user db - but don't wait for sync
    userAccount = await tua.UserAccount.init(
      kvStore: _KVStore(),
      deviceUid: deviceInfo.deviceUid,
      appPrefix: appPrefix,
      itemTypesToSync: itemsToSync,
      startSync: false,
    );

    if (userAccount.user.isSignedIn) {
      unawaited(userAccount.syncUserDb<void>(itemTypes: userAccount.itemTypesToSync));
    }

    contentTextScaleFactor
      ..add((tec.Prefs.shared.getDouble(Labels.prefContentTextScaleFactor, defaultValue: 1.2)))
      ..listen((scaleFactor) {
        tec.Prefs.shared.setDouble(Labels.prefContentTextScaleFactor, scaleFactor);
      });

    contentFontName
      ..add((tec.Prefs.shared.getString(Labels.prefContentFontName, defaultValue: '')))
      ..listen((fontName) {
        tec.Prefs.shared.setString(Labels.prefContentFontName, fontName);
      });
  }
}

///
/// Returns the text scale factor for content (e.g. Bible or study content HTML).
///
double contentTextScaleFactorWith(BuildContext context) {
  final scale = textScaleFactorWith(
        context,
        // dampingFactor: 0.5,
        // maxScaleFactor: 1.0,
      ) *
      AppSettings.shared.contentTextScaleFactor.value;
  // tec.dmPrint('scale: $scale');
  return scale;
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

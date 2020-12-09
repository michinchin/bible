import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';
import 'package:tec_env/tec_env.dart' as tev;
import 'package:tec_user_account/tec_user_account.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../blocs/content_settings.dart';

class AppSettings {
  static final AppSettings shared = AppSettings._();

  factory AppSettings() => shared;

  AppSettings._();

  //
  // PUBLIC API
  //

  tec.DeviceInfo deviceInfo;
  tua.UserAccount userAccount;
  tev.TecEnv env;

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
    final overlayStyle = isDarkTheme() ? lightOverlayStyle : darkOverlayStyle;
    return overlayStyle.copyWith(systemNavigationBarColor: Theme.of(context).appBarTheme.color);
  }

  ///
  /// Loads the app settings. This must only be called once.
  ///
  Future<void> load({
    @required String appName,
    @required List<tua.UserItemType> itemsToSync,
  }) async {
    assert(shared.userAccount == null, 'AppSettings.load() must only be called once.');
    env = const tev.TecEnv();
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
  }
}

///
/// Checks to see if this is a small screen
///
bool isSmallScreen(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return (math.max(size.width, size.height) < 1004);
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
      BlocProvider.of<ContentSettingsBloc>(context).state.textScaleFactor;
  // tec.dmPrint('scale: $scale');
  return scale;
}

///
/// Returns the font size for the current text scale factor for content
/// (e.g. Bible or study content HTML).
///
double contentFontSizeWith(BuildContext context) {
  return 12 * contentTextScaleFactorWith(context);
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

extension TecDeviceInfoExt on tec.DeviceInfo {
  bool get isSimulator => productName.contains('Simulator');
}

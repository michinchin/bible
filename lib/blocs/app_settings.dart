import 'package:flutter/foundation.dart';

import 'package:tec_user_account/tec_user_account.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;
import 'package:universal_platform/universal_platform.dart';

class AppSettings {
  // singleton
  static final AppSettings _singleton = AppSettings._();
  factory AppSettings() => _singleton;
  AppSettings._();
  static AppSettings get shared => _singleton;

  tua.UserAccount userAccount;
  tec.DeviceInfo deviceInfo;

  static Future<void> load(
      {@required String appName,
      @required List<tua.UserItemType> itemsToSync}) async {

    // Get device info.
    final di = await tec.DeviceInfo.fetch();
    debugPrint(
        'Running on ${di.productName} with ${tec.DeviceInfo.os} ${di.version}');

    // app prefix to indicate platform and app
    String platform;
    if (UniversalPlatform.isAndroid) {
      platform = 'PLAY';
    } else if (UniversalPlatform.isIOS) {
      platform = 'IOS';
    } else if (UniversalPlatform.isWeb) {
      platform = 'WEB';
    } else {
      platform = 'OTHER';
    }

    final appPrefix = '${platform}_$appName';

    final ua = await tua.UserAccount.init(
      kvStore: KVStore(),
      deviceUid: di.deviceUid,
      appPrefix: appPrefix,
      itemTypesToSync: itemsToSync,
    );

    shared.userAccount = ua;
    shared.deviceInfo = di;
  }
}

///
/// KVStore for use with UserAccount instance.
///
class KVStore with tua.UserAccountKVStore {
  KVStore();

  @override
  String getString(String key, {String defaultValue}) {
    return tec.Prefs.shared.getString(key, defaultValue: defaultValue);
  }

  @override
  Future<bool> setString(String key, String value) async {
    return tec.Prefs.shared.setString(key, value);
  }
}

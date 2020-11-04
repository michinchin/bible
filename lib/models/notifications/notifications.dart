import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import '../../ui/menu/notifications/notification_dialog.dart';

class ChannelInfo {
  String id;
  String name;
  String description;
  ChannelInfo({@required this.id, @required this.name, @required this.description});
}

class Notifications {
  static Notifications get shared => _n;
  static Notifications _n;
  Notifications._(this._prefFirstTimeOpened, this._channelInfo, this._color);

  /// notification stream
  static Stream<String> get payloadStream => _notification.stream;

  /// intialize notification plugin (to be called at app initialization)
  ///
  /// * provide [prefFirstTimeOpened] identifier for app
  /// * android requires [channelInfo] to create notification
  /// * label android notification icon in drawable as `notification_icon.png`
  static Future<void> init(
      {@required String prefFirstTimeOpened,
      @required ChannelInfo channelInfo,
      @required Color color}) async {
    _n ??= Notifications._(prefFirstTimeOpened, channelInfo, color);
    await _initializeTimezone();
    Future<void> onSelectNotification(String payload) async {
      if (payload != null) {
        tec.dmPrint('Notification payload: $payload');
      }
      _notification.add(payload);
    }

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const initializationSettingsAndroid = AndroidInitializationSettings('notification_icon');
    // pre iOS 10: must add onDidReceiveNotification callback to handle notification correctly
    const initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    // don't want to ask for permissions on init
    const initializationSettingsMacOS = MacOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false);
    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsMacOS);
    await _localNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  static Future<void> _initializeTimezone() async {
    String timezone;
    try {
      timezone = await FlutterNativeTimezone.getLocalTimezone();
    } on PlatformException {
      timezone = 'Failed to get the timezone.';
    }
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timezone));
  }

  /// ask user for notification privileges
  /// * call on first time open or on notification page tap
  Future<bool> requestPermissions(BuildContext c) async {
    final granted = await _permissionGranted();
    final firstTimeOpened = tec.Prefs.shared.getBool(_prefFirstTimeOpened, defaultValue: true);

    if (!(tec.platformName == 'IOS' || tec.platformName == 'MACOS')) {
      // android check permissions
      if (!granted) {
        await showDialog<void>(context: c, builder: (c) => NotificationPermDialog());
        return false;
      } else {
        return true;
      }
    }

    if (firstTimeOpened || !granted) {
      final proceed = await showDialog<bool>(context: c, builder: (c) => NotificationDialog());
      if (proceed != null && proceed) {
        await tec.Prefs.shared.setBool(_prefFirstTimeOpened, false);

        var allowedByOS = true;

        if (tec.platformName == 'IOS') {
          final result = await _localNotificationsPlugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              );
          allowedByOS = result;
        } else if (tec.platformName == 'MACOS') {
          final result = await _localNotificationsPlugin
              .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              );
          allowedByOS = result;
        }

        if (!allowedByOS) {
          await showDialog<void>(context: c, builder: (c) => NotificationPermDialog());
        } else {
          return allowedByOS;
        }
      }
    } else if (granted) {
      return true;
    }
    return false;
  }

  Future<void> cancelAllNotifications() => _localNotificationsPlugin.cancelAll();

  Future<void> createNotification(DateTime time,
      {String title, String body, int i, String payload}) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelInfo.id,
      _channelInfo.name,
      _channelInfo.description,
      importance: Importance.max,
      priority: Priority.high,
      color: _color,
    );
    const iOSPlatformChannelSpecifics =
        IOSNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
    final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    // on Android, if you schedule notifications from the past, it
    // will display them all now
    debugPrint('Creating notification for $title on ${time.toString()}');

    await _localNotificationsPlugin.zonedSchedule((DateTime.now().millisecond) + i + time.day,
        title, body, tz.TZDateTime.from(time, tz.local), platformChannelSpecifics,
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  ///
  /// PRIVATE
  ///

  /// identifier for first time opened shared preference
  final String _prefFirstTimeOpened;

  /// provide `channelId`, `channelName`, `channelDescription` to create notification
  final ChannelInfo _channelInfo;

  /// color for android notifications
  final Color _color;

  /// local notifications plugin initialization
  static final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // ignore: close_sinks
  static final _notification = PublishSubject<String>();

  /// check permission status
  static Future<bool> _permissionGranted() async {
    final status = await NotificationPermissions.getNotificationPermissionStatus();
    return status == PermissionStatus.granted;
  }
}

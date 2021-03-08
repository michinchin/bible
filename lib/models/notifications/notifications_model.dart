import 'package:flutter/material.dart';
import 'package:tec_notifications/tec_notifications.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../navigation_service.dart';
import '../../ui/home/today.dart';
import '../../ui/home/votd_screen.dart';
import '../const.dart';
import '../home/dotds.dart';
import '../home/votd.dart';
import '../reference_ext.dart';

class NotificationsModel extends NotificationsHelper {
  Dotds dotds;
  Votd votds;
  Bible bible;

  static final NotificationsModel shared = NotificationsModel();

  NotificationsModel()
      : super([
          LocalNotification.blank().copyWith(
              type: NotificationType.votd,
              time: DateTime.now().applied(const TimeOfDay(hour: 8, minute: 0))),
          LocalNotification.blank().copyWith(
              type: NotificationType.dotd,
              time: DateTime.now().applied(const TimeOfDay(hour: 8, minute: 0)),
              enabled: false),
          LocalNotification.blank().copyWith(
              type: NotificationType.scriptureBreak,
              time: DateTime.now().applied(const TimeOfDay(hour: 8, minute: 0)),
              enabled: false),
        ]) {
    bible = VolumesRepository.shared.bibleWithId(Const.defaultBible);
  }

  @override
  Future<void> scheduleNotificationsForFuture(LocalNotification n) async {
    shared.dotds ??= await Dotds.fetch();
    shared.votds ??= await Votd.fetch();
    await super.scheduleNotificationsForFuture(n);
  }

  /// schedules notifications for the next 37 days
  @override
  Future<void> createNotification(LocalNotification n) async {
    var title = '';
    var subtitle = '';

    switch (n.type) {
      case NotificationType.votd:
        final votdEntry = shared.votds?.forDateTime(n.time);
        if (votdEntry != null) {
          final ref = votdEntry.ref.copyWith(volume: shared.bible.id);
          final text = (await votdEntry.getFormattedVerse(shared.bible)).value;
          title = ref.label();
          subtitle = text;
        }
        break;
      // get title and subtitle (day and verse text)
      case NotificationType.dotd:
        final devo = shared.dotds?.devoForDate(n.time);
        title = 'Devotional of the day: ${devo.title}';
        subtitle = devo.intro;
        break;
      default:
        title = 'Time to Read!';
        subtitle = '';
        break;
    }
    final payload = '${NotificationConsts.payloadPrefixes[n.type]}${n.time.toIso8601String()}';
    await Notifications.shared.createNotification(n.time,
        title: title,
        body: subtitle,
        id: DateTime.now().millisecond + n.type.index + n.time.day,
        payload: payload);
  }

  Future<void> handlePayload(String payload) async {
    final uri = Uri.parse(payload);
    final type = NotificationConsts.getType(payload);

    switch (type) {
      case NotificationType.votd:
        final date = DateTime.parse(uri.pathSegments[0]);
        await showVotdFromNotification(navService.navigatorKey.currentContext, date);
        break;
      case NotificationType.dotd:
        final date = DateTime.parse(uri.pathSegments[0]);
        await showDotdFromNotification(navService.navigatorKey.currentContext, date);
        break;
      default:
        break;
    }
  }

  static Future<void> initNotifications(BuildContext context, {bool appInit = false}) async {
    var granted = false;

    final prefGranted =
        Prefs.shared.getInt(Const.prefNotificationPermissionGranted, defaultValue: 0);

    if (appInit && prefGranted != 1 && (platformIs(Platform.iOS) || platformIs(Platform.macOS))) {
      // don't do the initial request permissions on Apple devices on app start
      return;
    }
    else if (!appInit && prefGranted == 1) {
      // notifications have already been initialized...
      return;
    }

    if (prefGranted == 0) {
      granted = await Notifications.shared?.requestPermissions(context);
      await Prefs.shared.setInt(Const.prefNotificationPermissionGranted, granted ? 1 : -1);
    } else if (prefGranted == 1) {
      granted = await Notifications.shared?.requestPermissions(context);
    }

    if (granted) {
      NotificationBloc.init(NotificationsModel.shared);
      NotificationsModel.shared.bible = currentBibleFromContext(context);
      Future.delayed(const Duration(milliseconds: 500), () {
        // resend the notification
        Notifications.payloadStream.listen(NotificationsModel.shared.handlePayload);
      });
    }
  }
}

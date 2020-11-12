import 'package:flutter/material.dart';
import 'package:tec_notifications/tec_notifications.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/view_data/chapter_view_data.dart';
import '../../navigation_service.dart';
import '../../ui/home/home.dart';
import '../app_settings.dart';
import '../home/dotd.dart';
import '../home/votd.dart';

class NotificationsModel extends NotificationsHelper {
  Dotd dotds;
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
    bible = VolumesRepository.shared.bibleWithId(defaultBibleId);
  }

  @override
  Future<void> scheduleNotificationsForFuture(LocalNotification n) async {
    dotds ??= await Dotd.fetch(AppSettings.shared.env);
    votds ??= await Votd.fetch(AppSettings.shared.env);
    await super.scheduleNotificationsForFuture(n);
  }

  /// schedules notifications for the next 37 days
  @override
  Future<void> createNotification(LocalNotification n) async {
    var title = '';
    var subtitle = '';

    switch (n.type) {
      case NotificationType.votd:
        final votdEntry = votds?.forDateTime(n.time);
        if (votdEntry != null) {
          final ref = votdEntry.ref;
          final text = (await votdEntry.getFormattedVerse(bible)).value;
          title = ref.label();
          subtitle = text;
        }
        break;
      // get title and subtitle (day and verse text)
      case NotificationType.dotd:
        final devo = dotds?.devoForDate(n.time);
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
    debugPrint(uri.toString());
  }
}

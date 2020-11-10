import 'package:flutter/material.dart';
import 'package:tec_notifications/tec_notifications.dart';

class NotificationsModel extends NotificationsHelper {
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
        ]);

  /// schedules notifications for the next 37 days
  @override
  Future<void> createNotification(LocalNotification n) async {
    var title = '';
    var subtitle = '';

    switch (n.type) {
      case NotificationType.votd:
        title = 'Verse of the Day';
        subtitle = '(verse goes here)';
        break;
      // get title and subtitle (day and verse text)
      case NotificationType.dotd:
        title = 'Devotional of the Day';
        subtitle = '(devo goes here';
        break;
      default:
        title = 'Time to Read!';
        subtitle = '(verse goes here)';
        break;
    }
    final payload = '${NotificationConsts.payloadPrefixes[n.type]}${n.time.toIso8601String()}';
    await Notifications.shared.createNotification(n.time,
        title: title,
        body: subtitle,
        id: DateTime.now().millisecond + n.type.index + n.time.day,
        payload: payload);
  }
}

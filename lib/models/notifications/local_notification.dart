import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'days_of_week.dart';

class LocalNotification {
  final Week week;
  final DateTime time;
  final bool enabled;
  final String title;

  LocalNotification({this.week, this.time, this.enabled = true, this.title = ''});

  LocalNotification.blank()
      : week = Week(bitField: tec.everyDay),
        time = DateTime.now(),
        enabled = true,
        title = '';

  LocalNotification copyWith({Week week, DateTime time, bool enabled, String title}) =>
      LocalNotification(
          time: time ?? this.time,
          week: week ?? this.week,
          enabled: enabled ?? this.enabled,
          title: title ?? this.title);

  bool isEqualTo(LocalNotification n) =>
      n.week.bitField == week.bitField &&
      n.time.hour == time.hour &&
      n.time.minute == time.minute &&
      n.title == title;

  static String toJsonString(LocalNotification n) => tec.toJsonString(<String, dynamic>{
        'week': n.week.bitField,
        'time': n.time.toIso8601String(),
        'enabled': n.enabled ? 1 : 0,
        'title': n.title
      });

  factory LocalNotification.fromJson(String json) {
    final res = tec.parseJsonSync(json);
    if (res != null) {
      final week = Week(bitField: tec.as<int>(res['week']));
      final time = DateTime.parse(tec.as<String>(res['time']));
      final enabled = tec.as<int>(res['enabled']) == 1;
      final title = tec.as<String>(res['title']);
      return LocalNotification(week: week, time: time, enabled: enabled, title: title);
    } else {
      return null;
    }
  }
}

extension DateTimeExtension on DateTime {
  DateTime applied(TimeOfDay time) {
    return DateTime(year, month, day, time.hour, time.minute);
  }
}
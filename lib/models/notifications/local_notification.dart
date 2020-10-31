import 'package:freezed_annotation/freezed_annotation.dart';

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

  LocalNotification copyWith({
    Week week,
    DateTime time,
    bool enabled,
    String title
  }) =>
      LocalNotification(
        time: time ?? this.time,
        week: week ?? this.week,
        enabled: enabled ?? this.enabled,
        title: title ?? this.title
      );

  bool isEqualTo(LocalNotification n) =>
      n.week.bitField == week.bitField &&
      n.time.hour == time.hour &&
      n.time.minute == time.minute &&
      n.title == title;

  String toJson(LocalNotification n) =>
      '{"week":${n.week.bitField},"time":${n.time.toIso8601String()},"enabled": ${n.enabled ? 1 : 0}, "title":${n.title}';

  LocalNotification fromJson(String json) {
    final res = tec.parseJsonSync(json);
    final week = Week(bitField: int.parse(tec.as<String>(res['week'])));
    final time = DateTime.parse(tec.as<String>(res['time']));
    final enabled = int.parse(tec.as<String>(res['enabled'])) == 1;
    final title = tec.as<String>(tec.as<String>(res['title']));
    return LocalNotification(week: week, time: time, enabled: enabled, title: title);
  }
}

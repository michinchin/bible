import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/notifications/local_notification.dart';

import '../../models/const.dart';
import '../../models/notifications/local_notification.dart';
import '../../models/notifications/notifications.dart';

part 'notification_bloc.freezed.dart';

///
/// Notification Manager Bloc:
/// manages all the notifications saved
///
///
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc._() : super(NotificationState([])) {
    init();
  }
  // ignore: close_sinks
  static final NotificationBloc shared = NotificationBloc._();

  void init() {
    final lastUpdated = tec.Prefs.shared
        .getString(Const.prefNotificationUpdate, defaultValue: tec.today.toIso8601String());
    final updateDate = DateTime.tryParse(lastUpdated);

    /// update notifications today if not yet finnished
    if (tec.today.compareTo(updateDate) != 0) {
      updateNotifications();
    }

    load();
  }

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    final newState = event.when(load: _load, add: _add, update: _update, remove: _remove);
    assert(newState != null);
    if (newState != null) {
      yield newState;
    } else {
      yield state;
    }
  }

  ///
  /// EVENTS
  ///

  NotificationState _load() {
    final notifications = _grabNotificationsFromPrefs();
    final notificationList = <LocalNotification>[];
    for (var i = 0; i < notifications.length; i++) {
      final n = notifications[i];
      notificationList.add(LocalNotification.fromJson(n));
    }
    if (notificationList.isEmpty) {
      _saveNotifications(_defaultNotifications);
      return state.copyWith(notifications: _defaultNotifications);
    }
    return state.copyWith(notifications: notificationList);
  }

  NotificationState _add(LocalNotification notification) {
    final notificationList = List<LocalNotification>.from(state.notifications)..add(notification);
    _saveNotifications(notificationList);
    return state.copyWith(notifications: notificationList);
  }

  NotificationState _update(LocalNotification notification) {
    final notificationList = List<LocalNotification>.from(state.notifications);
    final idx = notificationList.indexWhere((n) => n.title == notification.title);
    if (idx != -1) {
      notificationList[idx] = notification;
    } else {
      notificationList.add(notification);
    }
    _saveNotifications(notificationList);
    return state.copyWith(notifications: notificationList);
  }

  NotificationState _remove(LocalNotification n) {
    final notificationList = List<LocalNotification>.from(state.notifications)..remove(n);
    return state.copyWith(notifications: notificationList);
  }

  List<String> _grabNotificationsFromPrefs() =>
      tec.Prefs.shared.getStringList(Const.prefNotifications) ?? [];

  Future<void> _saveNotifications(List<LocalNotification> notifications) async =>
      tec.Prefs.shared.setStringList(
          Const.prefNotifications, notifications.map(LocalNotification.toJsonString).toList());

  /// cancel all notifications and update accordingly
  Future<void> updateNotifications() async {
    await Notifications.shared.cancelAllNotifications();
    final notifications = state.notifications;
    for (var i = 0; i < notifications.length; i++) {
      if (notifications[i].enabled) {
        await _createNotification(notifications[i]);
      }
    }

    debugPrint('Notifications updated');

    await tec.Prefs.shared.setString(Const.prefNotificationUpdate, tec.today.toIso8601String());
  }

  ///
  /// HELPERS
  ///
  void load() => add(const NotificationEvent.load());
  void create(LocalNotification n) => add(NotificationEvent.add(n));
  void remove(LocalNotification n) => add(NotificationEvent.remove(n));
  void update(LocalNotification notification) => add(NotificationEvent.update(notification));

  ///
  /// PRIVATE
  ///
  ///
  final _defaultNotifications = <LocalNotification>[
    LocalNotification.blank().copyWith(
        title: 'Verse of the day',
        time: DateTime.now().applied(const TimeOfDay(hour: 8, minute: 0))),
    LocalNotification.blank().copyWith(
        title: 'Devo of the day',
        time: DateTime.now().applied(const TimeOfDay(hour: 8, minute: 0))),
    LocalNotification.blank().copyWith(
        title: 'Scripture break',
        time: DateTime.now().applied(const TimeOfDay(hour: 8, minute: 0))),
  ];

  /// creates notification for OS
  Future<void> _createNotification(LocalNotification n) async {
    final currentDay = tec.today ?? DateTime.now();

    const thirtyDays = 30;
    const oneWeek = 7;

    final daysChosen = tec.weekdayListFromBitField(n.week.currentBitfield).toList();

    for (var i = 0; i < (thirtyDays + oneWeek); i++) {
      final day = currentDay.add(Duration(days: i));

      if (daysChosen.contains(day.weekday)) {
        final time = DateTime(day.year, day.month, day.day, n.time.hour, n.time.minute);

        if (time.isAfter(DateTime.now()) && n.enabled) {
          final notification = LocalNotification(time: time, week: n.week);
          await Notifications.shared.createNotification(notification.time,
              title: n.title, body: 'Time to read!', i: i, payload: 'tap here');
        }
      }
    }
  }
}

@freezed
abstract class NotificationState with _$NotificationState {
  factory NotificationState(List<LocalNotification> notifications) = _Notifications;
}

@freezed
abstract class NotificationEvent with _$NotificationEvent {
  const factory NotificationEvent.load() = _LoadNotifications;
  const factory NotificationEvent.add(LocalNotification notification) = _AddToNotifications;
  const factory NotificationEvent.update(LocalNotification notification) = _UpdateNotification;
  const factory NotificationEvent.remove(LocalNotification notification) = _RemoveFromNotifications;
}

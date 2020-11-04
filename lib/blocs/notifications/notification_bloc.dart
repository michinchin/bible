import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/notifications/local_notification.dart';

part 'notification_bloc.freezed.dart';

///
/// Notification Manager Bloc:
/// manages all the notifications saved
///
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc._() : super(NotificationState([]));

  // ignore: close_sinks
  static final NotificationBloc shared = NotificationBloc._();

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async* {
    final newState = event.when(load: _load, create: _create, update: _update, remove: _remove);
    assert(newState != null);
    if (newState != null) {
      yield newState;
    } else {
      yield state;
    }
  }

  NotificationState _create(LocalNotification notification) {
    final notificationList = List<LocalNotification>.from(state.notifications)..add(notification);
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
    return state.copyWith(notifications: notificationList);
  }

  NotificationState _load() {
    // final notifications = _grabNotificationsFromPrefs();
    final notificationList = <LocalNotification>[];
    // for (var i = 0; i < notifications.length; i++) {
    //   final content = notifications[i];
    //   notificationList.add(LocalNotification());
    // }
    return state.copyWith(notifications: notificationList);
  }

  NotificationState _remove(LocalNotification n) {
    final notificationList = List<LocalNotification>.from(state.notifications);
    //   ..removeWhere((n) => n.id == id);
    // for (var i = 0; i < notificationList.length; i++) {
    //   notificationList[i] = notificationList[i].copyWith(id: i);
    // }
    return state.copyWith(notifications: notificationList);
  }

  // List<String> _grabNotificationsFromPrefs() =>
  //     tec.Prefs.shared.getStringList(notificationsPref) ?? [];

  void load() => add(const NotificationEvent.load());
  void create(LocalNotification n) => add(NotificationEvent.create(n));
  void remove(LocalNotification n) => add(NotificationEvent.remove(n));
  void update(LocalNotification notification) => add(NotificationEvent.update(notification));
}

@freezed
abstract class NotificationState with _$NotificationState {
  factory NotificationState(List<LocalNotification> notifications) = _Notifications;
}

@freezed
abstract class NotificationEvent with _$NotificationEvent {
  const factory NotificationEvent.load() = _LoadNotifications;
  const factory NotificationEvent.create(LocalNotification notification) = _AddToNotifications;
  const factory NotificationEvent.update(LocalNotification notification) = _UpdateNotification;
  const factory NotificationEvent.remove(LocalNotification notification) = _RemoveFromNotifications;
}

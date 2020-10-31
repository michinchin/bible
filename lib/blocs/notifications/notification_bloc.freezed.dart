// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'notification_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
class _$NotificationStateTearOff {
  const _$NotificationStateTearOff();

// ignore: unused_element
  _Notifications call(List<LocalNotification> notifications) {
    return _Notifications(
      notifications,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $NotificationState = _$NotificationStateTearOff();

/// @nodoc
mixin _$NotificationState {
  List<LocalNotification> get notifications;

  $NotificationStateCopyWith<NotificationState> get copyWith;
}

/// @nodoc
abstract class $NotificationStateCopyWith<$Res> {
  factory $NotificationStateCopyWith(
          NotificationState value, $Res Function(NotificationState) then) =
      _$NotificationStateCopyWithImpl<$Res>;
  $Res call({List<LocalNotification> notifications});
}

/// @nodoc
class _$NotificationStateCopyWithImpl<$Res>
    implements $NotificationStateCopyWith<$Res> {
  _$NotificationStateCopyWithImpl(this._value, this._then);

  final NotificationState _value;
  // ignore: unused_field
  final $Res Function(NotificationState) _then;

  @override
  $Res call({
    Object notifications = freezed,
  }) {
    return _then(_value.copyWith(
      notifications: notifications == freezed
          ? _value.notifications
          : notifications as List<LocalNotification>,
    ));
  }
}

/// @nodoc
abstract class _$NotificationsCopyWith<$Res>
    implements $NotificationStateCopyWith<$Res> {
  factory _$NotificationsCopyWith(
          _Notifications value, $Res Function(_Notifications) then) =
      __$NotificationsCopyWithImpl<$Res>;
  @override
  $Res call({List<LocalNotification> notifications});
}

/// @nodoc
class __$NotificationsCopyWithImpl<$Res>
    extends _$NotificationStateCopyWithImpl<$Res>
    implements _$NotificationsCopyWith<$Res> {
  __$NotificationsCopyWithImpl(
      _Notifications _value, $Res Function(_Notifications) _then)
      : super(_value, (v) => _then(v as _Notifications));

  @override
  _Notifications get _value => super._value as _Notifications;

  @override
  $Res call({
    Object notifications = freezed,
  }) {
    return _then(_Notifications(
      notifications == freezed
          ? _value.notifications
          : notifications as List<LocalNotification>,
    ));
  }
}

/// @nodoc
class _$_Notifications with DiagnosticableTreeMixin implements _Notifications {
  _$_Notifications(this.notifications) : assert(notifications != null);

  @override
  final List<LocalNotification> notifications;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationState(notifications: $notifications)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NotificationState'))
      ..add(DiagnosticsProperty('notifications', notifications));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Notifications &&
            (identical(other.notifications, notifications) ||
                const DeepCollectionEquality()
                    .equals(other.notifications, notifications)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(notifications);

  @override
  _$NotificationsCopyWith<_Notifications> get copyWith =>
      __$NotificationsCopyWithImpl<_Notifications>(this, _$identity);
}

abstract class _Notifications implements NotificationState {
  factory _Notifications(List<LocalNotification> notifications) =
      _$_Notifications;

  @override
  List<LocalNotification> get notifications;
  @override
  _$NotificationsCopyWith<_Notifications> get copyWith;
}

/// @nodoc
class _$NotificationEventTearOff {
  const _$NotificationEventTearOff();

// ignore: unused_element
  _LoadNotifications load() {
    return const _LoadNotifications();
  }

// ignore: unused_element
  _AddToNotifications create(LocalNotification notification) {
    return _AddToNotifications(
      notification,
    );
  }

// ignore: unused_element
  _UpdateNotification update(LocalNotification notification) {
    return _UpdateNotification(
      notification,
    );
  }

// ignore: unused_element
  _RemoveFromNotifications remove(LocalNotification notification) {
    return _RemoveFromNotifications(
      notification,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $NotificationEvent = _$NotificationEventTearOff();

/// @nodoc
mixin _$NotificationEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result create(LocalNotification notification),
    @required Result update(LocalNotification notification),
    @required Result remove(LocalNotification notification),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result create(LocalNotification notification),
    Result update(LocalNotification notification),
    Result remove(LocalNotification notification),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNotifications value),
    @required Result create(_AddToNotifications value),
    @required Result update(_UpdateNotification value),
    @required Result remove(_RemoveFromNotifications value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNotifications value),
    Result create(_AddToNotifications value),
    Result update(_UpdateNotification value),
    Result remove(_RemoveFromNotifications value),
    @required Result orElse(),
  });
}

/// @nodoc
abstract class $NotificationEventCopyWith<$Res> {
  factory $NotificationEventCopyWith(
          NotificationEvent value, $Res Function(NotificationEvent) then) =
      _$NotificationEventCopyWithImpl<$Res>;
}

/// @nodoc
class _$NotificationEventCopyWithImpl<$Res>
    implements $NotificationEventCopyWith<$Res> {
  _$NotificationEventCopyWithImpl(this._value, this._then);

  final NotificationEvent _value;
  // ignore: unused_field
  final $Res Function(NotificationEvent) _then;
}

/// @nodoc
abstract class _$LoadNotificationsCopyWith<$Res> {
  factory _$LoadNotificationsCopyWith(
          _LoadNotifications value, $Res Function(_LoadNotifications) then) =
      __$LoadNotificationsCopyWithImpl<$Res>;
}

/// @nodoc
class __$LoadNotificationsCopyWithImpl<$Res>
    extends _$NotificationEventCopyWithImpl<$Res>
    implements _$LoadNotificationsCopyWith<$Res> {
  __$LoadNotificationsCopyWithImpl(
      _LoadNotifications _value, $Res Function(_LoadNotifications) _then)
      : super(_value, (v) => _then(v as _LoadNotifications));

  @override
  _LoadNotifications get _value => super._value as _LoadNotifications;
}

/// @nodoc
class _$_LoadNotifications
    with DiagnosticableTreeMixin
    implements _LoadNotifications {
  const _$_LoadNotifications();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationEvent.load()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'NotificationEvent.load'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _LoadNotifications);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result create(LocalNotification notification),
    @required Result update(LocalNotification notification),
    @required Result remove(LocalNotification notification),
  }) {
    assert(load != null);
    assert(create != null);
    assert(update != null);
    assert(remove != null);
    return load();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result create(LocalNotification notification),
    Result update(LocalNotification notification),
    Result remove(LocalNotification notification),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (load != null) {
      return load();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNotifications value),
    @required Result create(_AddToNotifications value),
    @required Result update(_UpdateNotification value),
    @required Result remove(_RemoveFromNotifications value),
  }) {
    assert(load != null);
    assert(create != null);
    assert(update != null);
    assert(remove != null);
    return load(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNotifications value),
    Result create(_AddToNotifications value),
    Result update(_UpdateNotification value),
    Result remove(_RemoveFromNotifications value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class _LoadNotifications implements NotificationEvent {
  const factory _LoadNotifications() = _$_LoadNotifications;
}

/// @nodoc
abstract class _$AddToNotificationsCopyWith<$Res> {
  factory _$AddToNotificationsCopyWith(
          _AddToNotifications value, $Res Function(_AddToNotifications) then) =
      __$AddToNotificationsCopyWithImpl<$Res>;
  $Res call({LocalNotification notification});
}

/// @nodoc
class __$AddToNotificationsCopyWithImpl<$Res>
    extends _$NotificationEventCopyWithImpl<$Res>
    implements _$AddToNotificationsCopyWith<$Res> {
  __$AddToNotificationsCopyWithImpl(
      _AddToNotifications _value, $Res Function(_AddToNotifications) _then)
      : super(_value, (v) => _then(v as _AddToNotifications));

  @override
  _AddToNotifications get _value => super._value as _AddToNotifications;

  @override
  $Res call({
    Object notification = freezed,
  }) {
    return _then(_AddToNotifications(
      notification == freezed
          ? _value.notification
          : notification as LocalNotification,
    ));
  }
}

/// @nodoc
class _$_AddToNotifications
    with DiagnosticableTreeMixin
    implements _AddToNotifications {
  const _$_AddToNotifications(this.notification) : assert(notification != null);

  @override
  final LocalNotification notification;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationEvent.create(notification: $notification)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NotificationEvent.create'))
      ..add(DiagnosticsProperty('notification', notification));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _AddToNotifications &&
            (identical(other.notification, notification) ||
                const DeepCollectionEquality()
                    .equals(other.notification, notification)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(notification);

  @override
  _$AddToNotificationsCopyWith<_AddToNotifications> get copyWith =>
      __$AddToNotificationsCopyWithImpl<_AddToNotifications>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result create(LocalNotification notification),
    @required Result update(LocalNotification notification),
    @required Result remove(LocalNotification notification),
  }) {
    assert(load != null);
    assert(create != null);
    assert(update != null);
    assert(remove != null);
    return create(notification);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result create(LocalNotification notification),
    Result update(LocalNotification notification),
    Result remove(LocalNotification notification),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (create != null) {
      return create(notification);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNotifications value),
    @required Result create(_AddToNotifications value),
    @required Result update(_UpdateNotification value),
    @required Result remove(_RemoveFromNotifications value),
  }) {
    assert(load != null);
    assert(create != null);
    assert(update != null);
    assert(remove != null);
    return create(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNotifications value),
    Result create(_AddToNotifications value),
    Result update(_UpdateNotification value),
    Result remove(_RemoveFromNotifications value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (create != null) {
      return create(this);
    }
    return orElse();
  }
}

abstract class _AddToNotifications implements NotificationEvent {
  const factory _AddToNotifications(LocalNotification notification) =
      _$_AddToNotifications;

  LocalNotification get notification;
  _$AddToNotificationsCopyWith<_AddToNotifications> get copyWith;
}

/// @nodoc
abstract class _$UpdateNotificationCopyWith<$Res> {
  factory _$UpdateNotificationCopyWith(
          _UpdateNotification value, $Res Function(_UpdateNotification) then) =
      __$UpdateNotificationCopyWithImpl<$Res>;
  $Res call({LocalNotification notification});
}

/// @nodoc
class __$UpdateNotificationCopyWithImpl<$Res>
    extends _$NotificationEventCopyWithImpl<$Res>
    implements _$UpdateNotificationCopyWith<$Res> {
  __$UpdateNotificationCopyWithImpl(
      _UpdateNotification _value, $Res Function(_UpdateNotification) _then)
      : super(_value, (v) => _then(v as _UpdateNotification));

  @override
  _UpdateNotification get _value => super._value as _UpdateNotification;

  @override
  $Res call({
    Object notification = freezed,
  }) {
    return _then(_UpdateNotification(
      notification == freezed
          ? _value.notification
          : notification as LocalNotification,
    ));
  }
}

/// @nodoc
class _$_UpdateNotification
    with DiagnosticableTreeMixin
    implements _UpdateNotification {
  const _$_UpdateNotification(this.notification) : assert(notification != null);

  @override
  final LocalNotification notification;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationEvent.update(notification: $notification)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NotificationEvent.update'))
      ..add(DiagnosticsProperty('notification', notification));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _UpdateNotification &&
            (identical(other.notification, notification) ||
                const DeepCollectionEquality()
                    .equals(other.notification, notification)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(notification);

  @override
  _$UpdateNotificationCopyWith<_UpdateNotification> get copyWith =>
      __$UpdateNotificationCopyWithImpl<_UpdateNotification>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result create(LocalNotification notification),
    @required Result update(LocalNotification notification),
    @required Result remove(LocalNotification notification),
  }) {
    assert(load != null);
    assert(create != null);
    assert(update != null);
    assert(remove != null);
    return update(notification);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result create(LocalNotification notification),
    Result update(LocalNotification notification),
    Result remove(LocalNotification notification),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (update != null) {
      return update(notification);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNotifications value),
    @required Result create(_AddToNotifications value),
    @required Result update(_UpdateNotification value),
    @required Result remove(_RemoveFromNotifications value),
  }) {
    assert(load != null);
    assert(create != null);
    assert(update != null);
    assert(remove != null);
    return update(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNotifications value),
    Result create(_AddToNotifications value),
    Result update(_UpdateNotification value),
    Result remove(_RemoveFromNotifications value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (update != null) {
      return update(this);
    }
    return orElse();
  }
}

abstract class _UpdateNotification implements NotificationEvent {
  const factory _UpdateNotification(LocalNotification notification) =
      _$_UpdateNotification;

  LocalNotification get notification;
  _$UpdateNotificationCopyWith<_UpdateNotification> get copyWith;
}

/// @nodoc
abstract class _$RemoveFromNotificationsCopyWith<$Res> {
  factory _$RemoveFromNotificationsCopyWith(_RemoveFromNotifications value,
          $Res Function(_RemoveFromNotifications) then) =
      __$RemoveFromNotificationsCopyWithImpl<$Res>;
  $Res call({LocalNotification notification});
}

/// @nodoc
class __$RemoveFromNotificationsCopyWithImpl<$Res>
    extends _$NotificationEventCopyWithImpl<$Res>
    implements _$RemoveFromNotificationsCopyWith<$Res> {
  __$RemoveFromNotificationsCopyWithImpl(_RemoveFromNotifications _value,
      $Res Function(_RemoveFromNotifications) _then)
      : super(_value, (v) => _then(v as _RemoveFromNotifications));

  @override
  _RemoveFromNotifications get _value =>
      super._value as _RemoveFromNotifications;

  @override
  $Res call({
    Object notification = freezed,
  }) {
    return _then(_RemoveFromNotifications(
      notification == freezed
          ? _value.notification
          : notification as LocalNotification,
    ));
  }
}

/// @nodoc
class _$_RemoveFromNotifications
    with DiagnosticableTreeMixin
    implements _RemoveFromNotifications {
  const _$_RemoveFromNotifications(this.notification)
      : assert(notification != null);

  @override
  final LocalNotification notification;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationEvent.remove(notification: $notification)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NotificationEvent.remove'))
      ..add(DiagnosticsProperty('notification', notification));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _RemoveFromNotifications &&
            (identical(other.notification, notification) ||
                const DeepCollectionEquality()
                    .equals(other.notification, notification)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(notification);

  @override
  _$RemoveFromNotificationsCopyWith<_RemoveFromNotifications> get copyWith =>
      __$RemoveFromNotificationsCopyWithImpl<_RemoveFromNotifications>(
          this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result load(),
    @required Result create(LocalNotification notification),
    @required Result update(LocalNotification notification),
    @required Result remove(LocalNotification notification),
  }) {
    assert(load != null);
    assert(create != null);
    assert(update != null);
    assert(remove != null);
    return remove(notification);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result load(),
    Result create(LocalNotification notification),
    Result update(LocalNotification notification),
    Result remove(LocalNotification notification),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (remove != null) {
      return remove(notification);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result load(_LoadNotifications value),
    @required Result create(_AddToNotifications value),
    @required Result update(_UpdateNotification value),
    @required Result remove(_RemoveFromNotifications value),
  }) {
    assert(load != null);
    assert(create != null);
    assert(update != null);
    assert(remove != null);
    return remove(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result load(_LoadNotifications value),
    Result create(_AddToNotifications value),
    Result update(_UpdateNotification value),
    Result remove(_RemoveFromNotifications value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (remove != null) {
      return remove(this);
    }
    return orElse();
  }
}

abstract class _RemoveFromNotifications implements NotificationEvent {
  const factory _RemoveFromNotifications(LocalNotification notification) =
      _$_RemoveFromNotifications;

  LocalNotification get notification;
  _$RemoveFromNotificationsCopyWith<_RemoveFromNotifications> get copyWith;
}

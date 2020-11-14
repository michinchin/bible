// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'sheet_manager_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
class _$SheetManagerStateTearOff {
  const _$SheetManagerStateTearOff();

// ignore: unused_element
  _SheetState call({@required SheetType type}) {
    return _SheetState(
      type: type,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $SheetManagerState = _$SheetManagerStateTearOff();

/// @nodoc
mixin _$SheetManagerState {
  SheetType get type;

  $SheetManagerStateCopyWith<SheetManagerState> get copyWith;
}

/// @nodoc
abstract class $SheetManagerStateCopyWith<$Res> {
  factory $SheetManagerStateCopyWith(
          SheetManagerState value, $Res Function(SheetManagerState) then) =
      _$SheetManagerStateCopyWithImpl<$Res>;
  $Res call({SheetType type});
}

/// @nodoc
class _$SheetManagerStateCopyWithImpl<$Res>
    implements $SheetManagerStateCopyWith<$Res> {
  _$SheetManagerStateCopyWithImpl(this._value, this._then);

  final SheetManagerState _value;
  // ignore: unused_field
  final $Res Function(SheetManagerState) _then;

  @override
  $Res call({
    Object type = freezed,
  }) {
    return _then(_value.copyWith(
      type: type == freezed ? _value.type : type as SheetType,
    ));
  }
}

/// @nodoc
abstract class _$SheetStateCopyWith<$Res>
    implements $SheetManagerStateCopyWith<$Res> {
  factory _$SheetStateCopyWith(
          _SheetState value, $Res Function(_SheetState) then) =
      __$SheetStateCopyWithImpl<$Res>;
  @override
  $Res call({SheetType type});
}

/// @nodoc
class __$SheetStateCopyWithImpl<$Res>
    extends _$SheetManagerStateCopyWithImpl<$Res>
    implements _$SheetStateCopyWith<$Res> {
  __$SheetStateCopyWithImpl(
      _SheetState _value, $Res Function(_SheetState) _then)
      : super(_value, (v) => _then(v as _SheetState));

  @override
  _SheetState get _value => super._value as _SheetState;

  @override
  $Res call({
    Object type = freezed,
  }) {
    return _then(_SheetState(
      type: type == freezed ? _value.type : type as SheetType,
    ));
  }
}

/// @nodoc
class _$_SheetState with DiagnosticableTreeMixin implements _SheetState {
  const _$_SheetState({@required this.type}) : assert(type != null);

  @override
  final SheetType type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SheetManagerState(type: $type)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SheetManagerState'))
      ..add(DiagnosticsProperty('type', type));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SheetState &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(type);

  @override
  _$SheetStateCopyWith<_SheetState> get copyWith =>
      __$SheetStateCopyWithImpl<_SheetState>(this, _$identity);
}

abstract class _SheetState implements SheetManagerState {
  const factory _SheetState({@required SheetType type}) = _$_SheetState;

  @override
  SheetType get type;
  @override
  _$SheetStateCopyWith<_SheetState> get copyWith;
}

/// @nodoc
class _$SheetEventTearOff {
  const _$SheetEventTearOff();

// ignore: unused_element
  _ChangeType changeType(SheetType type) {
    return _ChangeType(
      type,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $SheetEvent = _$SheetEventTearOff();

/// @nodoc
mixin _$SheetEvent {
  SheetType get type;

  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeType(SheetType type),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeType(SheetType type),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeType(_ChangeType value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeType(_ChangeType value),
    @required Result orElse(),
  });

  $SheetEventCopyWith<SheetEvent> get copyWith;
}

/// @nodoc
abstract class $SheetEventCopyWith<$Res> {
  factory $SheetEventCopyWith(
          SheetEvent value, $Res Function(SheetEvent) then) =
      _$SheetEventCopyWithImpl<$Res>;
  $Res call({SheetType type});
}

/// @nodoc
class _$SheetEventCopyWithImpl<$Res> implements $SheetEventCopyWith<$Res> {
  _$SheetEventCopyWithImpl(this._value, this._then);

  final SheetEvent _value;
  // ignore: unused_field
  final $Res Function(SheetEvent) _then;

  @override
  $Res call({
    Object type = freezed,
  }) {
    return _then(_value.copyWith(
      type: type == freezed ? _value.type : type as SheetType,
    ));
  }
}

/// @nodoc
abstract class _$ChangeTypeCopyWith<$Res> implements $SheetEventCopyWith<$Res> {
  factory _$ChangeTypeCopyWith(
          _ChangeType value, $Res Function(_ChangeType) then) =
      __$ChangeTypeCopyWithImpl<$Res>;
  @override
  $Res call({SheetType type});
}

/// @nodoc
class __$ChangeTypeCopyWithImpl<$Res> extends _$SheetEventCopyWithImpl<$Res>
    implements _$ChangeTypeCopyWith<$Res> {
  __$ChangeTypeCopyWithImpl(
      _ChangeType _value, $Res Function(_ChangeType) _then)
      : super(_value, (v) => _then(v as _ChangeType));

  @override
  _ChangeType get _value => super._value as _ChangeType;

  @override
  $Res call({
    Object type = freezed,
  }) {
    return _then(_ChangeType(
      type == freezed ? _value.type : type as SheetType,
    ));
  }
}

/// @nodoc
class _$_ChangeType with DiagnosticableTreeMixin implements _ChangeType {
  const _$_ChangeType(this.type) : assert(type != null);

  @override
  final SheetType type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SheetEvent.changeType(type: $type)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SheetEvent.changeType'))
      ..add(DiagnosticsProperty('type', type));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ChangeType &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(type);

  @override
  _$ChangeTypeCopyWith<_ChangeType> get copyWith =>
      __$ChangeTypeCopyWithImpl<_ChangeType>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeType(SheetType type),
  }) {
    assert(changeType != null);
    return changeType(type);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeType(SheetType type),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeType != null) {
      return changeType(type);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeType(_ChangeType value),
  }) {
    assert(changeType != null);
    return changeType(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeType(_ChangeType value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeType != null) {
      return changeType(this);
    }
    return orElse();
  }
}

abstract class _ChangeType implements SheetEvent {
  const factory _ChangeType(SheetType type) = _$_ChangeType;

  @override
  SheetType get type;
  @override
  _$ChangeTypeCopyWith<_ChangeType> get copyWith;
}

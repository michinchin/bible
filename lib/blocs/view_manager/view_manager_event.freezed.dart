// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'view_manager_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
class _$ViewManagerEventTearOff {
  const _$ViewManagerEventTearOff();

// ignore: unused_element
  _Add add({@required String type, int position, String data}) {
    return _Add(
      type: type,
      position: position,
      data: data,
    );
  }

// ignore: unused_element
  _Remove remove(int uid) {
    return _Remove(
      uid,
    );
  }

// ignore: unused_element
  _Maximize maximize(int uid) {
    return _Maximize(
      uid,
    );
  }

// ignore: unused_element
  _Restore restore() {
    return const _Restore();
  }

// ignore: unused_element
  _Move move({int fromPosition, int toPosition}) {
    return _Move(
      fromPosition: fromPosition,
      toPosition: toPosition,
    );
  }

// ignore: unused_element
  _SetWidth setWidth({int position, double width}) {
    return _SetWidth(
      position: position,
      width: width,
    );
  }

// ignore: unused_element
  _SetHeight setHeight({int position, double height}) {
    return _SetHeight(
      position: position,
      height: height,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $ViewManagerEvent = _$ViewManagerEventTearOff();

/// @nodoc
mixin _$ViewManagerEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(String type, int position, String data),
    @required Result remove(int uid),
    @required Result maximize(int uid),
    @required Result restore(),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int uid),
    Result maximize(int uid),
    Result restore(),
    Result move(int fromPosition, int toPosition),
    Result setWidth(int position, double width),
    Result setHeight(int position, double height),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result remove(_Remove value),
    @required Result maximize(_Maximize value),
    @required Result restore(_Restore value),
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result remove(_Remove value),
    Result maximize(_Maximize value),
    Result restore(_Restore value),
    Result move(_Move value),
    Result setWidth(_SetWidth value),
    Result setHeight(_SetHeight value),
    @required Result orElse(),
  });
}

/// @nodoc
abstract class $ViewManagerEventCopyWith<$Res> {
  factory $ViewManagerEventCopyWith(
          ViewManagerEvent value, $Res Function(ViewManagerEvent) then) =
      _$ViewManagerEventCopyWithImpl<$Res>;
}

/// @nodoc
class _$ViewManagerEventCopyWithImpl<$Res>
    implements $ViewManagerEventCopyWith<$Res> {
  _$ViewManagerEventCopyWithImpl(this._value, this._then);

  final ViewManagerEvent _value;
  // ignore: unused_field
  final $Res Function(ViewManagerEvent) _then;
}

/// @nodoc
abstract class _$AddCopyWith<$Res> {
  factory _$AddCopyWith(_Add value, $Res Function(_Add) then) =
      __$AddCopyWithImpl<$Res>;
  $Res call({String type, int position, String data});
}

/// @nodoc
class __$AddCopyWithImpl<$Res> extends _$ViewManagerEventCopyWithImpl<$Res>
    implements _$AddCopyWith<$Res> {
  __$AddCopyWithImpl(_Add _value, $Res Function(_Add) _then)
      : super(_value, (v) => _then(v as _Add));

  @override
  _Add get _value => super._value as _Add;

  @override
  $Res call({
    Object type = freezed,
    Object position = freezed,
    Object data = freezed,
  }) {
    return _then(_Add(
      type: type == freezed ? _value.type : type as String,
      position: position == freezed ? _value.position : position as int,
      data: data == freezed ? _value.data : data as String,
    ));
  }
}

/// @nodoc
class _$_Add implements _Add {
  const _$_Add({@required this.type, this.position, this.data})
      : assert(type != null);

  @override
  final String type;
  @override
  final int position;
  @override
  final String data;

  @override
  String toString() {
    return 'ViewManagerEvent.add(type: $type, position: $position, data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Add &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.position, position) ||
                const DeepCollectionEquality()
                    .equals(other.position, position)) &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(position) ^
      const DeepCollectionEquality().hash(data);

  @override
  _$AddCopyWith<_Add> get copyWith =>
      __$AddCopyWithImpl<_Add>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(String type, int position, String data),
    @required Result remove(int uid),
    @required Result maximize(int uid),
    @required Result restore(),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return add(type, position, data);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int uid),
    Result maximize(int uid),
    Result restore(),
    Result move(int fromPosition, int toPosition),
    Result setWidth(int position, double width),
    Result setHeight(int position, double height),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (add != null) {
      return add(type, position, data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result remove(_Remove value),
    @required Result maximize(_Maximize value),
    @required Result restore(_Restore value),
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return add(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result remove(_Remove value),
    Result maximize(_Maximize value),
    Result restore(_Restore value),
    Result move(_Move value),
    Result setWidth(_SetWidth value),
    Result setHeight(_SetHeight value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (add != null) {
      return add(this);
    }
    return orElse();
  }
}

abstract class _Add implements ViewManagerEvent {
  const factory _Add({@required String type, int position, String data}) =
      _$_Add;

  String get type;
  int get position;
  String get data;
  _$AddCopyWith<_Add> get copyWith;
}

/// @nodoc
abstract class _$RemoveCopyWith<$Res> {
  factory _$RemoveCopyWith(_Remove value, $Res Function(_Remove) then) =
      __$RemoveCopyWithImpl<$Res>;
  $Res call({int uid});
}

/// @nodoc
class __$RemoveCopyWithImpl<$Res> extends _$ViewManagerEventCopyWithImpl<$Res>
    implements _$RemoveCopyWith<$Res> {
  __$RemoveCopyWithImpl(_Remove _value, $Res Function(_Remove) _then)
      : super(_value, (v) => _then(v as _Remove));

  @override
  _Remove get _value => super._value as _Remove;

  @override
  $Res call({
    Object uid = freezed,
  }) {
    return _then(_Remove(
      uid == freezed ? _value.uid : uid as int,
    ));
  }
}

/// @nodoc
class _$_Remove implements _Remove {
  const _$_Remove(this.uid) : assert(uid != null);

  @override
  final int uid;

  @override
  String toString() {
    return 'ViewManagerEvent.remove(uid: $uid)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Remove &&
            (identical(other.uid, uid) ||
                const DeepCollectionEquality().equals(other.uid, uid)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(uid);

  @override
  _$RemoveCopyWith<_Remove> get copyWith =>
      __$RemoveCopyWithImpl<_Remove>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(String type, int position, String data),
    @required Result remove(int uid),
    @required Result maximize(int uid),
    @required Result restore(),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return remove(uid);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int uid),
    Result maximize(int uid),
    Result restore(),
    Result move(int fromPosition, int toPosition),
    Result setWidth(int position, double width),
    Result setHeight(int position, double height),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (remove != null) {
      return remove(uid);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result remove(_Remove value),
    @required Result maximize(_Maximize value),
    @required Result restore(_Restore value),
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return remove(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result remove(_Remove value),
    Result maximize(_Maximize value),
    Result restore(_Restore value),
    Result move(_Move value),
    Result setWidth(_SetWidth value),
    Result setHeight(_SetHeight value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (remove != null) {
      return remove(this);
    }
    return orElse();
  }
}

abstract class _Remove implements ViewManagerEvent {
  const factory _Remove(int uid) = _$_Remove;

  int get uid;
  _$RemoveCopyWith<_Remove> get copyWith;
}

/// @nodoc
abstract class _$MaximizeCopyWith<$Res> {
  factory _$MaximizeCopyWith(_Maximize value, $Res Function(_Maximize) then) =
      __$MaximizeCopyWithImpl<$Res>;
  $Res call({int uid});
}

/// @nodoc
class __$MaximizeCopyWithImpl<$Res> extends _$ViewManagerEventCopyWithImpl<$Res>
    implements _$MaximizeCopyWith<$Res> {
  __$MaximizeCopyWithImpl(_Maximize _value, $Res Function(_Maximize) _then)
      : super(_value, (v) => _then(v as _Maximize));

  @override
  _Maximize get _value => super._value as _Maximize;

  @override
  $Res call({
    Object uid = freezed,
  }) {
    return _then(_Maximize(
      uid == freezed ? _value.uid : uid as int,
    ));
  }
}

/// @nodoc
class _$_Maximize implements _Maximize {
  const _$_Maximize(this.uid) : assert(uid != null);

  @override
  final int uid;

  @override
  String toString() {
    return 'ViewManagerEvent.maximize(uid: $uid)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Maximize &&
            (identical(other.uid, uid) ||
                const DeepCollectionEquality().equals(other.uid, uid)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(uid);

  @override
  _$MaximizeCopyWith<_Maximize> get copyWith =>
      __$MaximizeCopyWithImpl<_Maximize>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(String type, int position, String data),
    @required Result remove(int uid),
    @required Result maximize(int uid),
    @required Result restore(),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return maximize(uid);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int uid),
    Result maximize(int uid),
    Result restore(),
    Result move(int fromPosition, int toPosition),
    Result setWidth(int position, double width),
    Result setHeight(int position, double height),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (maximize != null) {
      return maximize(uid);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result remove(_Remove value),
    @required Result maximize(_Maximize value),
    @required Result restore(_Restore value),
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return maximize(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result remove(_Remove value),
    Result maximize(_Maximize value),
    Result restore(_Restore value),
    Result move(_Move value),
    Result setWidth(_SetWidth value),
    Result setHeight(_SetHeight value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (maximize != null) {
      return maximize(this);
    }
    return orElse();
  }
}

abstract class _Maximize implements ViewManagerEvent {
  const factory _Maximize(int uid) = _$_Maximize;

  int get uid;
  _$MaximizeCopyWith<_Maximize> get copyWith;
}

/// @nodoc
abstract class _$RestoreCopyWith<$Res> {
  factory _$RestoreCopyWith(_Restore value, $Res Function(_Restore) then) =
      __$RestoreCopyWithImpl<$Res>;
}

/// @nodoc
class __$RestoreCopyWithImpl<$Res> extends _$ViewManagerEventCopyWithImpl<$Res>
    implements _$RestoreCopyWith<$Res> {
  __$RestoreCopyWithImpl(_Restore _value, $Res Function(_Restore) _then)
      : super(_value, (v) => _then(v as _Restore));

  @override
  _Restore get _value => super._value as _Restore;
}

/// @nodoc
class _$_Restore implements _Restore {
  const _$_Restore();

  @override
  String toString() {
    return 'ViewManagerEvent.restore()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _Restore);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(String type, int position, String data),
    @required Result remove(int uid),
    @required Result maximize(int uid),
    @required Result restore(),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return restore();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int uid),
    Result maximize(int uid),
    Result restore(),
    Result move(int fromPosition, int toPosition),
    Result setWidth(int position, double width),
    Result setHeight(int position, double height),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (restore != null) {
      return restore();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result remove(_Remove value),
    @required Result maximize(_Maximize value),
    @required Result restore(_Restore value),
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return restore(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result remove(_Remove value),
    Result maximize(_Maximize value),
    Result restore(_Restore value),
    Result move(_Move value),
    Result setWidth(_SetWidth value),
    Result setHeight(_SetHeight value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (restore != null) {
      return restore(this);
    }
    return orElse();
  }
}

abstract class _Restore implements ViewManagerEvent {
  const factory _Restore() = _$_Restore;
}

/// @nodoc
abstract class _$MoveCopyWith<$Res> {
  factory _$MoveCopyWith(_Move value, $Res Function(_Move) then) =
      __$MoveCopyWithImpl<$Res>;
  $Res call({int fromPosition, int toPosition});
}

/// @nodoc
class __$MoveCopyWithImpl<$Res> extends _$ViewManagerEventCopyWithImpl<$Res>
    implements _$MoveCopyWith<$Res> {
  __$MoveCopyWithImpl(_Move _value, $Res Function(_Move) _then)
      : super(_value, (v) => _then(v as _Move));

  @override
  _Move get _value => super._value as _Move;

  @override
  $Res call({
    Object fromPosition = freezed,
    Object toPosition = freezed,
  }) {
    return _then(_Move(
      fromPosition:
          fromPosition == freezed ? _value.fromPosition : fromPosition as int,
      toPosition: toPosition == freezed ? _value.toPosition : toPosition as int,
    ));
  }
}

/// @nodoc
class _$_Move implements _Move {
  const _$_Move({this.fromPosition, this.toPosition});

  @override
  final int fromPosition;
  @override
  final int toPosition;

  @override
  String toString() {
    return 'ViewManagerEvent.move(fromPosition: $fromPosition, toPosition: $toPosition)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Move &&
            (identical(other.fromPosition, fromPosition) ||
                const DeepCollectionEquality()
                    .equals(other.fromPosition, fromPosition)) &&
            (identical(other.toPosition, toPosition) ||
                const DeepCollectionEquality()
                    .equals(other.toPosition, toPosition)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(fromPosition) ^
      const DeepCollectionEquality().hash(toPosition);

  @override
  _$MoveCopyWith<_Move> get copyWith =>
      __$MoveCopyWithImpl<_Move>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(String type, int position, String data),
    @required Result remove(int uid),
    @required Result maximize(int uid),
    @required Result restore(),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return move(fromPosition, toPosition);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int uid),
    Result maximize(int uid),
    Result restore(),
    Result move(int fromPosition, int toPosition),
    Result setWidth(int position, double width),
    Result setHeight(int position, double height),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (move != null) {
      return move(fromPosition, toPosition);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result remove(_Remove value),
    @required Result maximize(_Maximize value),
    @required Result restore(_Restore value),
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return move(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result remove(_Remove value),
    Result maximize(_Maximize value),
    Result restore(_Restore value),
    Result move(_Move value),
    Result setWidth(_SetWidth value),
    Result setHeight(_SetHeight value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (move != null) {
      return move(this);
    }
    return orElse();
  }
}

abstract class _Move implements ViewManagerEvent {
  const factory _Move({int fromPosition, int toPosition}) = _$_Move;

  int get fromPosition;
  int get toPosition;
  _$MoveCopyWith<_Move> get copyWith;
}

/// @nodoc
abstract class _$SetWidthCopyWith<$Res> {
  factory _$SetWidthCopyWith(_SetWidth value, $Res Function(_SetWidth) then) =
      __$SetWidthCopyWithImpl<$Res>;
  $Res call({int position, double width});
}

/// @nodoc
class __$SetWidthCopyWithImpl<$Res> extends _$ViewManagerEventCopyWithImpl<$Res>
    implements _$SetWidthCopyWith<$Res> {
  __$SetWidthCopyWithImpl(_SetWidth _value, $Res Function(_SetWidth) _then)
      : super(_value, (v) => _then(v as _SetWidth));

  @override
  _SetWidth get _value => super._value as _SetWidth;

  @override
  $Res call({
    Object position = freezed,
    Object width = freezed,
  }) {
    return _then(_SetWidth(
      position: position == freezed ? _value.position : position as int,
      width: width == freezed ? _value.width : width as double,
    ));
  }
}

/// @nodoc
class _$_SetWidth implements _SetWidth {
  const _$_SetWidth({this.position, this.width});

  @override
  final int position;
  @override
  final double width;

  @override
  String toString() {
    return 'ViewManagerEvent.setWidth(position: $position, width: $width)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SetWidth &&
            (identical(other.position, position) ||
                const DeepCollectionEquality()
                    .equals(other.position, position)) &&
            (identical(other.width, width) ||
                const DeepCollectionEquality().equals(other.width, width)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(position) ^
      const DeepCollectionEquality().hash(width);

  @override
  _$SetWidthCopyWith<_SetWidth> get copyWith =>
      __$SetWidthCopyWithImpl<_SetWidth>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(String type, int position, String data),
    @required Result remove(int uid),
    @required Result maximize(int uid),
    @required Result restore(),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return setWidth(position, width);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int uid),
    Result maximize(int uid),
    Result restore(),
    Result move(int fromPosition, int toPosition),
    Result setWidth(int position, double width),
    Result setHeight(int position, double height),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setWidth != null) {
      return setWidth(position, width);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result remove(_Remove value),
    @required Result maximize(_Maximize value),
    @required Result restore(_Restore value),
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return setWidth(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result remove(_Remove value),
    Result maximize(_Maximize value),
    Result restore(_Restore value),
    Result move(_Move value),
    Result setWidth(_SetWidth value),
    Result setHeight(_SetHeight value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setWidth != null) {
      return setWidth(this);
    }
    return orElse();
  }
}

abstract class _SetWidth implements ViewManagerEvent {
  const factory _SetWidth({int position, double width}) = _$_SetWidth;

  int get position;
  double get width;
  _$SetWidthCopyWith<_SetWidth> get copyWith;
}

/// @nodoc
abstract class _$SetHeightCopyWith<$Res> {
  factory _$SetHeightCopyWith(
          _SetHeight value, $Res Function(_SetHeight) then) =
      __$SetHeightCopyWithImpl<$Res>;
  $Res call({int position, double height});
}

/// @nodoc
class __$SetHeightCopyWithImpl<$Res>
    extends _$ViewManagerEventCopyWithImpl<$Res>
    implements _$SetHeightCopyWith<$Res> {
  __$SetHeightCopyWithImpl(_SetHeight _value, $Res Function(_SetHeight) _then)
      : super(_value, (v) => _then(v as _SetHeight));

  @override
  _SetHeight get _value => super._value as _SetHeight;

  @override
  $Res call({
    Object position = freezed,
    Object height = freezed,
  }) {
    return _then(_SetHeight(
      position: position == freezed ? _value.position : position as int,
      height: height == freezed ? _value.height : height as double,
    ));
  }
}

/// @nodoc
class _$_SetHeight implements _SetHeight {
  const _$_SetHeight({this.position, this.height});

  @override
  final int position;
  @override
  final double height;

  @override
  String toString() {
    return 'ViewManagerEvent.setHeight(position: $position, height: $height)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SetHeight &&
            (identical(other.position, position) ||
                const DeepCollectionEquality()
                    .equals(other.position, position)) &&
            (identical(other.height, height) ||
                const DeepCollectionEquality().equals(other.height, height)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(position) ^
      const DeepCollectionEquality().hash(height);

  @override
  _$SetHeightCopyWith<_SetHeight> get copyWith =>
      __$SetHeightCopyWithImpl<_SetHeight>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(String type, int position, String data),
    @required Result remove(int uid),
    @required Result maximize(int uid),
    @required Result restore(),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return setHeight(position, height);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int uid),
    Result maximize(int uid),
    Result restore(),
    Result move(int fromPosition, int toPosition),
    Result setWidth(int position, double width),
    Result setHeight(int position, double height),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setHeight != null) {
      return setHeight(position, height);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result remove(_Remove value),
    @required Result maximize(_Maximize value),
    @required Result restore(_Restore value),
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(maximize != null);
    assert(restore != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return setHeight(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result remove(_Remove value),
    Result maximize(_Maximize value),
    Result restore(_Restore value),
    Result move(_Move value),
    Result setWidth(_SetWidth value),
    Result setHeight(_SetHeight value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setHeight != null) {
      return setHeight(this);
    }
    return orElse();
  }
}

abstract class _SetHeight implements ViewManagerEvent {
  const factory _SetHeight({int position, double height}) = _$_SetHeight;

  int get position;
  double get height;
  _$SetHeightCopyWith<_SetHeight> get copyWith;
}

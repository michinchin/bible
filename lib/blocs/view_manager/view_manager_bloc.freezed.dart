// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, avoid_positional_boolean_parameters

part of 'view_manager_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

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

// ignore: unused_element
const $ViewManagerEvent = _$ViewManagerEventTearOff();

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

abstract class $ViewManagerEventCopyWith<$Res> {
  factory $ViewManagerEventCopyWith(
          ViewManagerEvent value, $Res Function(ViewManagerEvent) then) =
      _$ViewManagerEventCopyWithImpl<$Res>;
}

class _$ViewManagerEventCopyWithImpl<$Res>
    implements $ViewManagerEventCopyWith<$Res> {
  _$ViewManagerEventCopyWithImpl(this._value, this._then);

  final ViewManagerEvent _value;
  // ignore: unused_field
  final $Res Function(ViewManagerEvent) _then;
}

abstract class _$AddCopyWith<$Res> {
  factory _$AddCopyWith(_Add value, $Res Function(_Add) then) =
      __$AddCopyWithImpl<$Res>;
  $Res call({String type, int position, String data});
}

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

class _$_Add with DiagnosticableTreeMixin implements _Add {
  const _$_Add({@required this.type, this.position, this.data})
      : assert(type != null);

  @override
  final String type;
  @override
  final int position;
  @override
  final String data;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewManagerEvent.add(type: $type, position: $position, data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ViewManagerEvent.add'))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('data', data));
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

abstract class _$RemoveCopyWith<$Res> {
  factory _$RemoveCopyWith(_Remove value, $Res Function(_Remove) then) =
      __$RemoveCopyWithImpl<$Res>;
  $Res call({int uid});
}

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

class _$_Remove with DiagnosticableTreeMixin implements _Remove {
  const _$_Remove(this.uid) : assert(uid != null);

  @override
  final int uid;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewManagerEvent.remove(uid: $uid)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ViewManagerEvent.remove'))
      ..add(DiagnosticsProperty('uid', uid));
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

abstract class _$MaximizeCopyWith<$Res> {
  factory _$MaximizeCopyWith(_Maximize value, $Res Function(_Maximize) then) =
      __$MaximizeCopyWithImpl<$Res>;
  $Res call({int uid});
}

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

class _$_Maximize with DiagnosticableTreeMixin implements _Maximize {
  const _$_Maximize(this.uid) : assert(uid != null);

  @override
  final int uid;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewManagerEvent.maximize(uid: $uid)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ViewManagerEvent.maximize'))
      ..add(DiagnosticsProperty('uid', uid));
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

abstract class _$RestoreCopyWith<$Res> {
  factory _$RestoreCopyWith(_Restore value, $Res Function(_Restore) then) =
      __$RestoreCopyWithImpl<$Res>;
}

class __$RestoreCopyWithImpl<$Res> extends _$ViewManagerEventCopyWithImpl<$Res>
    implements _$RestoreCopyWith<$Res> {
  __$RestoreCopyWithImpl(_Restore _value, $Res Function(_Restore) _then)
      : super(_value, (v) => _then(v as _Restore));

  @override
  _Restore get _value => super._value as _Restore;
}

class _$_Restore with DiagnosticableTreeMixin implements _Restore {
  const _$_Restore();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewManagerEvent.restore()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'ViewManagerEvent.restore'));
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

abstract class _$MoveCopyWith<$Res> {
  factory _$MoveCopyWith(_Move value, $Res Function(_Move) then) =
      __$MoveCopyWithImpl<$Res>;
  $Res call({int fromPosition, int toPosition});
}

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

class _$_Move with DiagnosticableTreeMixin implements _Move {
  const _$_Move({this.fromPosition, this.toPosition});

  @override
  final int fromPosition;
  @override
  final int toPosition;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewManagerEvent.move(fromPosition: $fromPosition, toPosition: $toPosition)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ViewManagerEvent.move'))
      ..add(DiagnosticsProperty('fromPosition', fromPosition))
      ..add(DiagnosticsProperty('toPosition', toPosition));
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

abstract class _$SetWidthCopyWith<$Res> {
  factory _$SetWidthCopyWith(_SetWidth value, $Res Function(_SetWidth) then) =
      __$SetWidthCopyWithImpl<$Res>;
  $Res call({int position, double width});
}

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

class _$_SetWidth with DiagnosticableTreeMixin implements _SetWidth {
  const _$_SetWidth({this.position, this.width});

  @override
  final int position;
  @override
  final double width;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewManagerEvent.setWidth(position: $position, width: $width)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ViewManagerEvent.setWidth'))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('width', width));
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

abstract class _$SetHeightCopyWith<$Res> {
  factory _$SetHeightCopyWith(
          _SetHeight value, $Res Function(_SetHeight) then) =
      __$SetHeightCopyWithImpl<$Res>;
  $Res call({int position, double height});
}

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

class _$_SetHeight with DiagnosticableTreeMixin implements _SetHeight {
  const _$_SetHeight({this.position, this.height});

  @override
  final int position;
  @override
  final double height;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewManagerEvent.setHeight(position: $position, height: $height)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ViewManagerEvent.setHeight'))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('height', height));
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

ViewState _$ViewStateFromJson(Map<String, dynamic> json) {
  return _ViewState.fromJson(json);
}

class _$ViewStateTearOff {
  const _$ViewStateTearOff();

// ignore: unused_element
  _ViewState call(
      {int uid, String type, double preferredWidth, double preferredHeight}) {
    return _ViewState(
      uid: uid,
      type: type,
      preferredWidth: preferredWidth,
      preferredHeight: preferredHeight,
    );
  }
}

// ignore: unused_element
const $ViewState = _$ViewStateTearOff();

mixin _$ViewState {
  int get uid;
  String get type;
  double get preferredWidth;
  double get preferredHeight;

  Map<String, dynamic> toJson();
  $ViewStateCopyWith<ViewState> get copyWith;
}

abstract class $ViewStateCopyWith<$Res> {
  factory $ViewStateCopyWith(ViewState value, $Res Function(ViewState) then) =
      _$ViewStateCopyWithImpl<$Res>;
  $Res call(
      {int uid, String type, double preferredWidth, double preferredHeight});
}

class _$ViewStateCopyWithImpl<$Res> implements $ViewStateCopyWith<$Res> {
  _$ViewStateCopyWithImpl(this._value, this._then);

  final ViewState _value;
  // ignore: unused_field
  final $Res Function(ViewState) _then;

  @override
  $Res call({
    Object uid = freezed,
    Object type = freezed,
    Object preferredWidth = freezed,
    Object preferredHeight = freezed,
  }) {
    return _then(_value.copyWith(
      uid: uid == freezed ? _value.uid : uid as int,
      type: type == freezed ? _value.type : type as String,
      preferredWidth: preferredWidth == freezed
          ? _value.preferredWidth
          : preferredWidth as double,
      preferredHeight: preferredHeight == freezed
          ? _value.preferredHeight
          : preferredHeight as double,
    ));
  }
}

abstract class _$ViewStateCopyWith<$Res> implements $ViewStateCopyWith<$Res> {
  factory _$ViewStateCopyWith(
          _ViewState value, $Res Function(_ViewState) then) =
      __$ViewStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {int uid, String type, double preferredWidth, double preferredHeight});
}

class __$ViewStateCopyWithImpl<$Res> extends _$ViewStateCopyWithImpl<$Res>
    implements _$ViewStateCopyWith<$Res> {
  __$ViewStateCopyWithImpl(_ViewState _value, $Res Function(_ViewState) _then)
      : super(_value, (v) => _then(v as _ViewState));

  @override
  _ViewState get _value => super._value as _ViewState;

  @override
  $Res call({
    Object uid = freezed,
    Object type = freezed,
    Object preferredWidth = freezed,
    Object preferredHeight = freezed,
  }) {
    return _then(_ViewState(
      uid: uid == freezed ? _value.uid : uid as int,
      type: type == freezed ? _value.type : type as String,
      preferredWidth: preferredWidth == freezed
          ? _value.preferredWidth
          : preferredWidth as double,
      preferredHeight: preferredHeight == freezed
          ? _value.preferredHeight
          : preferredHeight as double,
    ));
  }
}

@JsonSerializable()
class _$_ViewState with DiagnosticableTreeMixin implements _ViewState {
  _$_ViewState(
      {this.uid, this.type, this.preferredWidth, this.preferredHeight});

  factory _$_ViewState.fromJson(Map<String, dynamic> json) =>
      _$_$_ViewStateFromJson(json);

  @override
  final int uid;
  @override
  final String type;
  @override
  final double preferredWidth;
  @override
  final double preferredHeight;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewState(uid: $uid, type: $type, preferredWidth: $preferredWidth, preferredHeight: $preferredHeight)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ViewState'))
      ..add(DiagnosticsProperty('uid', uid))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('preferredWidth', preferredWidth))
      ..add(DiagnosticsProperty('preferredHeight', preferredHeight));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ViewState &&
            (identical(other.uid, uid) ||
                const DeepCollectionEquality().equals(other.uid, uid)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.preferredWidth, preferredWidth) ||
                const DeepCollectionEquality()
                    .equals(other.preferredWidth, preferredWidth)) &&
            (identical(other.preferredHeight, preferredHeight) ||
                const DeepCollectionEquality()
                    .equals(other.preferredHeight, preferredHeight)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(uid) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(preferredWidth) ^
      const DeepCollectionEquality().hash(preferredHeight);

  @override
  _$ViewStateCopyWith<_ViewState> get copyWith =>
      __$ViewStateCopyWithImpl<_ViewState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_ViewStateToJson(this);
  }
}

abstract class _ViewState implements ViewState {
  factory _ViewState(
      {int uid,
      String type,
      double preferredWidth,
      double preferredHeight}) = _$_ViewState;

  factory _ViewState.fromJson(Map<String, dynamic> json) =
      _$_ViewState.fromJson;

  @override
  int get uid;
  @override
  String get type;
  @override
  double get preferredWidth;
  @override
  double get preferredHeight;
  @override
  _$ViewStateCopyWith<_ViewState> get copyWith;
}

ViewManagerState _$ViewManagerStateFromJson(Map<String, dynamic> json) {
  return _Views.fromJson(json);
}

class _$ViewManagerStateTearOff {
  const _$ViewManagerStateTearOff();

// ignore: unused_element
  _Views call(List<ViewState> views, int maximizedViewUid, int nextUid) {
    return _Views(
      views,
      maximizedViewUid,
      nextUid,
    );
  }
}

// ignore: unused_element
const $ViewManagerState = _$ViewManagerStateTearOff();

mixin _$ViewManagerState {
  List<ViewState> get views;
  int get maximizedViewUid;
  int get nextUid;

  Map<String, dynamic> toJson();
  $ViewManagerStateCopyWith<ViewManagerState> get copyWith;
}

abstract class $ViewManagerStateCopyWith<$Res> {
  factory $ViewManagerStateCopyWith(
          ViewManagerState value, $Res Function(ViewManagerState) then) =
      _$ViewManagerStateCopyWithImpl<$Res>;
  $Res call({List<ViewState> views, int maximizedViewUid, int nextUid});
}

class _$ViewManagerStateCopyWithImpl<$Res>
    implements $ViewManagerStateCopyWith<$Res> {
  _$ViewManagerStateCopyWithImpl(this._value, this._then);

  final ViewManagerState _value;
  // ignore: unused_field
  final $Res Function(ViewManagerState) _then;

  @override
  $Res call({
    Object views = freezed,
    Object maximizedViewUid = freezed,
    Object nextUid = freezed,
  }) {
    return _then(_value.copyWith(
      views: views == freezed ? _value.views : views as List<ViewState>,
      maximizedViewUid: maximizedViewUid == freezed
          ? _value.maximizedViewUid
          : maximizedViewUid as int,
      nextUid: nextUid == freezed ? _value.nextUid : nextUid as int,
    ));
  }
}

abstract class _$ViewsCopyWith<$Res>
    implements $ViewManagerStateCopyWith<$Res> {
  factory _$ViewsCopyWith(_Views value, $Res Function(_Views) then) =
      __$ViewsCopyWithImpl<$Res>;
  @override
  $Res call({List<ViewState> views, int maximizedViewUid, int nextUid});
}

class __$ViewsCopyWithImpl<$Res> extends _$ViewManagerStateCopyWithImpl<$Res>
    implements _$ViewsCopyWith<$Res> {
  __$ViewsCopyWithImpl(_Views _value, $Res Function(_Views) _then)
      : super(_value, (v) => _then(v as _Views));

  @override
  _Views get _value => super._value as _Views;

  @override
  $Res call({
    Object views = freezed,
    Object maximizedViewUid = freezed,
    Object nextUid = freezed,
  }) {
    return _then(_Views(
      views == freezed ? _value.views : views as List<ViewState>,
      maximizedViewUid == freezed
          ? _value.maximizedViewUid
          : maximizedViewUid as int,
      nextUid == freezed ? _value.nextUid : nextUid as int,
    ));
  }
}

@JsonSerializable()
class _$_Views with DiagnosticableTreeMixin implements _Views {
  _$_Views(this.views, this.maximizedViewUid, this.nextUid)
      : assert(views != null),
        assert(maximizedViewUid != null),
        assert(nextUid != null);

  factory _$_Views.fromJson(Map<String, dynamic> json) =>
      _$_$_ViewsFromJson(json);

  @override
  final List<ViewState> views;
  @override
  final int maximizedViewUid;
  @override
  final int nextUid;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewManagerState(views: $views, maximizedViewUid: $maximizedViewUid, nextUid: $nextUid)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ViewManagerState'))
      ..add(DiagnosticsProperty('views', views))
      ..add(DiagnosticsProperty('maximizedViewUid', maximizedViewUid))
      ..add(DiagnosticsProperty('nextUid', nextUid));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Views &&
            (identical(other.views, views) ||
                const DeepCollectionEquality().equals(other.views, views)) &&
            (identical(other.maximizedViewUid, maximizedViewUid) ||
                const DeepCollectionEquality()
                    .equals(other.maximizedViewUid, maximizedViewUid)) &&
            (identical(other.nextUid, nextUid) ||
                const DeepCollectionEquality().equals(other.nextUid, nextUid)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(views) ^
      const DeepCollectionEquality().hash(maximizedViewUid) ^
      const DeepCollectionEquality().hash(nextUid);

  @override
  _$ViewsCopyWith<_Views> get copyWith =>
      __$ViewsCopyWithImpl<_Views>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_ViewsToJson(this);
  }
}

abstract class _Views implements ViewManagerState {
  factory _Views(List<ViewState> views, int maximizedViewUid, int nextUid) =
      _$_Views;

  factory _Views.fromJson(Map<String, dynamic> json) = _$_Views.fromJson;

  @override
  List<ViewState> get views;
  @override
  int get maximizedViewUid;
  @override
  int get nextUid;
  @override
  _$ViewsCopyWith<_Views> get copyWith;
}

class _$ManagedViewStateTearOff {
  const _$ManagedViewStateTearOff();

// ignore: unused_element
  _ManagedViewState call(
      BoxConstraints parentConstraints,
      ViewState viewState,
      Size viewSize,
      int viewIndex,
      int row,
      int col,
      int rowCount,
      int colCount,
      bool isMaximized) {
    return _ManagedViewState(
      parentConstraints,
      viewState,
      viewSize,
      viewIndex,
      row,
      col,
      rowCount,
      colCount,
      isMaximized,
    );
  }
}

// ignore: unused_element
const $ManagedViewState = _$ManagedViewStateTearOff();

mixin _$ManagedViewState {
  BoxConstraints get parentConstraints;
  ViewState get viewState;
  Size get viewSize;
  int get viewIndex;
  int get row;
  int get col;
  int get rowCount;
  int get colCount;
  bool get isMaximized;

  $ManagedViewStateCopyWith<ManagedViewState> get copyWith;
}

abstract class $ManagedViewStateCopyWith<$Res> {
  factory $ManagedViewStateCopyWith(
          ManagedViewState value, $Res Function(ManagedViewState) then) =
      _$ManagedViewStateCopyWithImpl<$Res>;
  $Res call(
      {BoxConstraints parentConstraints,
      ViewState viewState,
      Size viewSize,
      int viewIndex,
      int row,
      int col,
      int rowCount,
      int colCount,
      bool isMaximized});

  $ViewStateCopyWith<$Res> get viewState;
}

class _$ManagedViewStateCopyWithImpl<$Res>
    implements $ManagedViewStateCopyWith<$Res> {
  _$ManagedViewStateCopyWithImpl(this._value, this._then);

  final ManagedViewState _value;
  // ignore: unused_field
  final $Res Function(ManagedViewState) _then;

  @override
  $Res call({
    Object parentConstraints = freezed,
    Object viewState = freezed,
    Object viewSize = freezed,
    Object viewIndex = freezed,
    Object row = freezed,
    Object col = freezed,
    Object rowCount = freezed,
    Object colCount = freezed,
    Object isMaximized = freezed,
  }) {
    return _then(_value.copyWith(
      parentConstraints: parentConstraints == freezed
          ? _value.parentConstraints
          : parentConstraints as BoxConstraints,
      viewState:
          viewState == freezed ? _value.viewState : viewState as ViewState,
      viewSize: viewSize == freezed ? _value.viewSize : viewSize as Size,
      viewIndex: viewIndex == freezed ? _value.viewIndex : viewIndex as int,
      row: row == freezed ? _value.row : row as int,
      col: col == freezed ? _value.col : col as int,
      rowCount: rowCount == freezed ? _value.rowCount : rowCount as int,
      colCount: colCount == freezed ? _value.colCount : colCount as int,
      isMaximized:
          isMaximized == freezed ? _value.isMaximized : isMaximized as bool,
    ));
  }

  @override
  $ViewStateCopyWith<$Res> get viewState {
    if (_value.viewState == null) {
      return null;
    }
    return $ViewStateCopyWith<$Res>(_value.viewState, (value) {
      return _then(_value.copyWith(viewState: value));
    });
  }
}

abstract class _$ManagedViewStateCopyWith<$Res>
    implements $ManagedViewStateCopyWith<$Res> {
  factory _$ManagedViewStateCopyWith(
          _ManagedViewState value, $Res Function(_ManagedViewState) then) =
      __$ManagedViewStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {BoxConstraints parentConstraints,
      ViewState viewState,
      Size viewSize,
      int viewIndex,
      int row,
      int col,
      int rowCount,
      int colCount,
      bool isMaximized});

  @override
  $ViewStateCopyWith<$Res> get viewState;
}

class __$ManagedViewStateCopyWithImpl<$Res>
    extends _$ManagedViewStateCopyWithImpl<$Res>
    implements _$ManagedViewStateCopyWith<$Res> {
  __$ManagedViewStateCopyWithImpl(
      _ManagedViewState _value, $Res Function(_ManagedViewState) _then)
      : super(_value, (v) => _then(v as _ManagedViewState));

  @override
  _ManagedViewState get _value => super._value as _ManagedViewState;

  @override
  $Res call({
    Object parentConstraints = freezed,
    Object viewState = freezed,
    Object viewSize = freezed,
    Object viewIndex = freezed,
    Object row = freezed,
    Object col = freezed,
    Object rowCount = freezed,
    Object colCount = freezed,
    Object isMaximized = freezed,
  }) {
    return _then(_ManagedViewState(
      parentConstraints == freezed
          ? _value.parentConstraints
          : parentConstraints as BoxConstraints,
      viewState == freezed ? _value.viewState : viewState as ViewState,
      viewSize == freezed ? _value.viewSize : viewSize as Size,
      viewIndex == freezed ? _value.viewIndex : viewIndex as int,
      row == freezed ? _value.row : row as int,
      col == freezed ? _value.col : col as int,
      rowCount == freezed ? _value.rowCount : rowCount as int,
      colCount == freezed ? _value.colCount : colCount as int,
      isMaximized == freezed ? _value.isMaximized : isMaximized as bool,
    ));
  }
}

class _$_ManagedViewState
    with DiagnosticableTreeMixin
    implements _ManagedViewState {
  _$_ManagedViewState(
      this.parentConstraints,
      this.viewState,
      this.viewSize,
      this.viewIndex,
      this.row,
      this.col,
      this.rowCount,
      this.colCount,
      this.isMaximized)
      : assert(parentConstraints != null),
        assert(viewState != null),
        assert(viewSize != null),
        assert(viewIndex != null),
        assert(row != null),
        assert(col != null),
        assert(rowCount != null),
        assert(colCount != null),
        assert(isMaximized != null);

  @override
  final BoxConstraints parentConstraints;
  @override
  final ViewState viewState;
  @override
  final Size viewSize;
  @override
  final int viewIndex;
  @override
  final int row;
  @override
  final int col;
  @override
  final int rowCount;
  @override
  final int colCount;
  @override
  final bool isMaximized;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ManagedViewState(parentConstraints: $parentConstraints, viewState: $viewState, viewSize: $viewSize, viewIndex: $viewIndex, row: $row, col: $col, rowCount: $rowCount, colCount: $colCount, isMaximized: $isMaximized)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ManagedViewState'))
      ..add(DiagnosticsProperty('parentConstraints', parentConstraints))
      ..add(DiagnosticsProperty('viewState', viewState))
      ..add(DiagnosticsProperty('viewSize', viewSize))
      ..add(DiagnosticsProperty('viewIndex', viewIndex))
      ..add(DiagnosticsProperty('row', row))
      ..add(DiagnosticsProperty('col', col))
      ..add(DiagnosticsProperty('rowCount', rowCount))
      ..add(DiagnosticsProperty('colCount', colCount))
      ..add(DiagnosticsProperty('isMaximized', isMaximized));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ManagedViewState &&
            (identical(other.parentConstraints, parentConstraints) ||
                const DeepCollectionEquality()
                    .equals(other.parentConstraints, parentConstraints)) &&
            (identical(other.viewState, viewState) ||
                const DeepCollectionEquality()
                    .equals(other.viewState, viewState)) &&
            (identical(other.viewSize, viewSize) ||
                const DeepCollectionEquality()
                    .equals(other.viewSize, viewSize)) &&
            (identical(other.viewIndex, viewIndex) ||
                const DeepCollectionEquality()
                    .equals(other.viewIndex, viewIndex)) &&
            (identical(other.row, row) ||
                const DeepCollectionEquality().equals(other.row, row)) &&
            (identical(other.col, col) ||
                const DeepCollectionEquality().equals(other.col, col)) &&
            (identical(other.rowCount, rowCount) ||
                const DeepCollectionEquality()
                    .equals(other.rowCount, rowCount)) &&
            (identical(other.colCount, colCount) ||
                const DeepCollectionEquality()
                    .equals(other.colCount, colCount)) &&
            (identical(other.isMaximized, isMaximized) ||
                const DeepCollectionEquality()
                    .equals(other.isMaximized, isMaximized)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(parentConstraints) ^
      const DeepCollectionEquality().hash(viewState) ^
      const DeepCollectionEquality().hash(viewSize) ^
      const DeepCollectionEquality().hash(viewIndex) ^
      const DeepCollectionEquality().hash(row) ^
      const DeepCollectionEquality().hash(col) ^
      const DeepCollectionEquality().hash(rowCount) ^
      const DeepCollectionEquality().hash(colCount) ^
      const DeepCollectionEquality().hash(isMaximized);

  @override
  _$ManagedViewStateCopyWith<_ManagedViewState> get copyWith =>
      __$ManagedViewStateCopyWithImpl<_ManagedViewState>(this, _$identity);
}

abstract class _ManagedViewState implements ManagedViewState {
  factory _ManagedViewState(
      BoxConstraints parentConstraints,
      ViewState viewState,
      Size viewSize,
      int viewIndex,
      int row,
      int col,
      int rowCount,
      int colCount,
      bool isMaximized) = _$_ManagedViewState;

  @override
  BoxConstraints get parentConstraints;
  @override
  ViewState get viewState;
  @override
  Size get viewSize;
  @override
  int get viewIndex;
  @override
  int get row;
  @override
  int get col;
  @override
  int get rowCount;
  @override
  int get colCount;
  @override
  bool get isMaximized;
  @override
  _$ManagedViewStateCopyWith<_ManagedViewState> get copyWith;
}

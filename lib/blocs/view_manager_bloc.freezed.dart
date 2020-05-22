// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'view_manager_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$ViewManagerEventTearOff {
  const _$ViewManagerEventTearOff();

  _Add add({@required String type, int position, String data}) {
    return _Add(
      type: type,
      position: position,
      data: data,
    );
  }

  _Remove remove(int position) {
    return _Remove(
      position,
    );
  }

  _Move move({int fromPosition, int toPosition}) {
    return _Move(
      fromPosition: fromPosition,
      toPosition: toPosition,
    );
  }

  _SetWidth setWidth({int position, double width}) {
    return _SetWidth(
      position: position,
      width: width,
    );
  }

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
    @required Result remove(int position),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int position),
    Result move(int fromPosition, int toPosition),
    Result setWidth(int position, double width),
    Result setHeight(int position, double height),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result remove(_Remove value),
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result add(_Add value),
    Result remove(_Remove value),
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
    @required Result remove(int position),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return add(type, position, data);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int position),
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
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  }) {
    assert(add != null);
    assert(remove != null);
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
  $Res call({int position});
}

class __$RemoveCopyWithImpl<$Res> extends _$ViewManagerEventCopyWithImpl<$Res>
    implements _$RemoveCopyWith<$Res> {
  __$RemoveCopyWithImpl(_Remove _value, $Res Function(_Remove) _then)
      : super(_value, (v) => _then(v as _Remove));

  @override
  _Remove get _value => super._value as _Remove;

  @override
  $Res call({
    Object position = freezed,
  }) {
    return _then(_Remove(
      position == freezed ? _value.position : position as int,
    ));
  }
}

class _$_Remove with DiagnosticableTreeMixin implements _Remove {
  const _$_Remove(this.position) : assert(position != null);

  @override
  final int position;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewManagerEvent.remove(position: $position)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ViewManagerEvent.remove'))
      ..add(DiagnosticsProperty('position', position));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Remove &&
            (identical(other.position, position) ||
                const DeepCollectionEquality()
                    .equals(other.position, position)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(position);

  @override
  _$RemoveCopyWith<_Remove> get copyWith =>
      __$RemoveCopyWithImpl<_Remove>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result add(String type, int position, String data),
    @required Result remove(int position),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return remove(position);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int position),
    Result move(int fromPosition, int toPosition),
    Result setWidth(int position, double width),
    Result setHeight(int position, double height),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (remove != null) {
      return remove(position);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result add(_Add value),
    @required Result remove(_Remove value),
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  }) {
    assert(add != null);
    assert(remove != null);
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
  const factory _Remove(int position) = _$_Remove;

  int get position;
  _$RemoveCopyWith<_Remove> get copyWith;
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
    @required Result remove(int position),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return move(fromPosition, toPosition);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int position),
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
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  }) {
    assert(add != null);
    assert(remove != null);
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
    @required Result remove(int position),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return setWidth(position, width);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int position),
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
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  }) {
    assert(add != null);
    assert(remove != null);
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
    @required Result remove(int position),
    @required Result move(int fromPosition, int toPosition),
    @required Result setWidth(int position, double width),
    @required Result setHeight(int position, double height),
  }) {
    assert(add != null);
    assert(remove != null);
    assert(move != null);
    assert(setWidth != null);
    assert(setHeight != null);
    return setHeight(position, height);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result add(String type, int position, String data),
    Result remove(int position),
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
    @required Result move(_Move value),
    @required Result setWidth(_SetWidth value),
    @required Result setHeight(_SetHeight value),
  }) {
    assert(add != null);
    assert(remove != null);
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

  _ViewState call(
      {String type,
      double preferredWidth,
      double preferredHeight,
      String data}) {
    return _ViewState(
      type: type,
      preferredWidth: preferredWidth,
      preferredHeight: preferredHeight,
      data: data,
    );
  }
}

// ignore: unused_element
const $ViewState = _$ViewStateTearOff();

mixin _$ViewState {
  String get type;
  double get preferredWidth;
  double get preferredHeight;
  String get data;

  Map<String, dynamic> toJson();
  $ViewStateCopyWith<ViewState> get copyWith;
}

abstract class $ViewStateCopyWith<$Res> {
  factory $ViewStateCopyWith(ViewState value, $Res Function(ViewState) then) =
      _$ViewStateCopyWithImpl<$Res>;
  $Res call(
      {String type,
      double preferredWidth,
      double preferredHeight,
      String data});
}

class _$ViewStateCopyWithImpl<$Res> implements $ViewStateCopyWith<$Res> {
  _$ViewStateCopyWithImpl(this._value, this._then);

  final ViewState _value;
  // ignore: unused_field
  final $Res Function(ViewState) _then;

  @override
  $Res call({
    Object type = freezed,
    Object preferredWidth = freezed,
    Object preferredHeight = freezed,
    Object data = freezed,
  }) {
    return _then(_value.copyWith(
      type: type == freezed ? _value.type : type as String,
      preferredWidth: preferredWidth == freezed
          ? _value.preferredWidth
          : preferredWidth as double,
      preferredHeight: preferredHeight == freezed
          ? _value.preferredHeight
          : preferredHeight as double,
      data: data == freezed ? _value.data : data as String,
    ));
  }
}

abstract class _$ViewStateCopyWith<$Res> implements $ViewStateCopyWith<$Res> {
  factory _$ViewStateCopyWith(
          _ViewState value, $Res Function(_ViewState) then) =
      __$ViewStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {String type,
      double preferredWidth,
      double preferredHeight,
      String data});
}

class __$ViewStateCopyWithImpl<$Res> extends _$ViewStateCopyWithImpl<$Res>
    implements _$ViewStateCopyWith<$Res> {
  __$ViewStateCopyWithImpl(_ViewState _value, $Res Function(_ViewState) _then)
      : super(_value, (v) => _then(v as _ViewState));

  @override
  _ViewState get _value => super._value as _ViewState;

  @override
  $Res call({
    Object type = freezed,
    Object preferredWidth = freezed,
    Object preferredHeight = freezed,
    Object data = freezed,
  }) {
    return _then(_ViewState(
      type: type == freezed ? _value.type : type as String,
      preferredWidth: preferredWidth == freezed
          ? _value.preferredWidth
          : preferredWidth as double,
      preferredHeight: preferredHeight == freezed
          ? _value.preferredHeight
          : preferredHeight as double,
      data: data == freezed ? _value.data : data as String,
    ));
  }
}

@JsonSerializable()
class _$_ViewState with DiagnosticableTreeMixin implements _ViewState {
  _$_ViewState(
      {this.type, this.preferredWidth, this.preferredHeight, this.data});

  factory _$_ViewState.fromJson(Map<String, dynamic> json) =>
      _$_$_ViewStateFromJson(json);

  @override
  final String type;
  @override
  final double preferredWidth;
  @override
  final double preferredHeight;
  @override
  final String data;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewState(type: $type, preferredWidth: $preferredWidth, preferredHeight: $preferredHeight, data: $data)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ViewState'))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('preferredWidth', preferredWidth))
      ..add(DiagnosticsProperty('preferredHeight', preferredHeight))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ViewState &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.preferredWidth, preferredWidth) ||
                const DeepCollectionEquality()
                    .equals(other.preferredWidth, preferredWidth)) &&
            (identical(other.preferredHeight, preferredHeight) ||
                const DeepCollectionEquality()
                    .equals(other.preferredHeight, preferredHeight)) &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(preferredWidth) ^
      const DeepCollectionEquality().hash(preferredHeight) ^
      const DeepCollectionEquality().hash(data);

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
      {String type,
      double preferredWidth,
      double preferredHeight,
      String data}) = _$_ViewState;

  factory _ViewState.fromJson(Map<String, dynamic> json) =
      _$_ViewState.fromJson;

  @override
  String get type;
  @override
  double get preferredWidth;
  @override
  double get preferredHeight;
  @override
  String get data;
  @override
  _$ViewStateCopyWith<_ViewState> get copyWith;
}

ViewManagerState _$ViewManagerStateFromJson(Map<String, dynamic> json) {
  return _Views.fromJson(json);
}

class _$ViewManagerStateTearOff {
  const _$ViewManagerStateTearOff();

  _Views call(List<ViewState> views) {
    return _Views(
      views,
    );
  }
}

// ignore: unused_element
const $ViewManagerState = _$ViewManagerStateTearOff();

mixin _$ViewManagerState {
  List<ViewState> get views;

  Map<String, dynamic> toJson();
  $ViewManagerStateCopyWith<ViewManagerState> get copyWith;
}

abstract class $ViewManagerStateCopyWith<$Res> {
  factory $ViewManagerStateCopyWith(
          ViewManagerState value, $Res Function(ViewManagerState) then) =
      _$ViewManagerStateCopyWithImpl<$Res>;
  $Res call({List<ViewState> views});
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
  }) {
    return _then(_value.copyWith(
      views: views == freezed ? _value.views : views as List<ViewState>,
    ));
  }
}

abstract class _$ViewsCopyWith<$Res>
    implements $ViewManagerStateCopyWith<$Res> {
  factory _$ViewsCopyWith(_Views value, $Res Function(_Views) then) =
      __$ViewsCopyWithImpl<$Res>;
  @override
  $Res call({List<ViewState> views});
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
  }) {
    return _then(_Views(
      views == freezed ? _value.views : views as List<ViewState>,
    ));
  }
}

@JsonSerializable()
class _$_Views with DiagnosticableTreeMixin implements _Views {
  _$_Views(this.views) : assert(views != null);

  factory _$_Views.fromJson(Map<String, dynamic> json) =>
      _$_$_ViewsFromJson(json);

  @override
  final List<ViewState> views;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ViewManagerState(views: $views)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ViewManagerState'))
      ..add(DiagnosticsProperty('views', views));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Views &&
            (identical(other.views, views) ||
                const DeepCollectionEquality().equals(other.views, views)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(views);

  @override
  _$ViewsCopyWith<_Views> get copyWith =>
      __$ViewsCopyWithImpl<_Views>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_ViewsToJson(this);
  }
}

abstract class _Views implements ViewManagerState {
  factory _Views(List<ViewState> views) = _$_Views;

  factory _Views.fromJson(Map<String, dynamic> json) = _$_Views.fromJson;

  @override
  List<ViewState> get views;
  @override
  _$ViewsCopyWith<_Views> get copyWith;
}

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
ViewState _$ViewStateFromJson(Map<String, dynamic> json) {
  return _ViewState.fromJson(json);
}

/// @nodoc
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

// ignore: unused_element
  ViewState fromJson(Map<String, Object> json) {
    return ViewState.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $ViewState = _$ViewStateTearOff();

/// @nodoc
mixin _$ViewState {
  int get uid;
  String get type;
  double get preferredWidth;
  double get preferredHeight;

  Map<String, dynamic> toJson();
  $ViewStateCopyWith<ViewState> get copyWith;
}

/// @nodoc
abstract class $ViewStateCopyWith<$Res> {
  factory $ViewStateCopyWith(ViewState value, $Res Function(ViewState) then) =
      _$ViewStateCopyWithImpl<$Res>;
  $Res call(
      {int uid, String type, double preferredWidth, double preferredHeight});
}

/// @nodoc
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

/// @nodoc
abstract class _$ViewStateCopyWith<$Res> implements $ViewStateCopyWith<$Res> {
  factory _$ViewStateCopyWith(
          _ViewState value, $Res Function(_ViewState) then) =
      __$ViewStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {int uid, String type, double preferredWidth, double preferredHeight});
}

/// @nodoc
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

/// @nodoc
class _$_ViewState implements _ViewState {
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
  String toString() {
    return 'ViewState(uid: $uid, type: $type, preferredWidth: $preferredWidth, preferredHeight: $preferredHeight)';
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

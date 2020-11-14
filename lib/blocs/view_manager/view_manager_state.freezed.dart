// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'view_manager_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
ViewManagerState _$ViewManagerStateFromJson(Map<String, dynamic> json) {
  return _Views.fromJson(json);
}

/// @nodoc
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

// ignore: unused_element
  ViewManagerState fromJson(Map<String, Object> json) {
    return ViewManagerState.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $ViewManagerState = _$ViewManagerStateTearOff();

/// @nodoc
mixin _$ViewManagerState {
  List<ViewState> get views;
  int get maximizedViewUid;
  int get nextUid;

  Map<String, dynamic> toJson();
  $ViewManagerStateCopyWith<ViewManagerState> get copyWith;
}

/// @nodoc
abstract class $ViewManagerStateCopyWith<$Res> {
  factory $ViewManagerStateCopyWith(
          ViewManagerState value, $Res Function(ViewManagerState) then) =
      _$ViewManagerStateCopyWithImpl<$Res>;
  $Res call({List<ViewState> views, int maximizedViewUid, int nextUid});
}

/// @nodoc
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

/// @nodoc
abstract class _$ViewsCopyWith<$Res>
    implements $ViewManagerStateCopyWith<$Res> {
  factory _$ViewsCopyWith(_Views value, $Res Function(_Views) then) =
      __$ViewsCopyWithImpl<$Res>;
  @override
  $Res call({List<ViewState> views, int maximizedViewUid, int nextUid});
}

/// @nodoc
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

/// @nodoc
class _$_Views implements _Views {
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
  String toString() {
    return 'ViewManagerState(views: $views, maximizedViewUid: $maximizedViewUid, nextUid: $nextUid)';
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

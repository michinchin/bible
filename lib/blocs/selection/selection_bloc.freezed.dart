// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'selection_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$SelectionStateTearOff {
  const _$SelectionStateTearOff();

// ignore: unused_element
  _SelectionState call({bool isTextSelected}) {
    return _SelectionState(
      isTextSelected: isTextSelected,
    );
  }
}

// ignore: unused_element
const $SelectionState = _$SelectionStateTearOff();

mixin _$SelectionState {
  bool get isTextSelected;

  $SelectionStateCopyWith<SelectionState> get copyWith;
}

abstract class $SelectionStateCopyWith<$Res> {
  factory $SelectionStateCopyWith(
          SelectionState value, $Res Function(SelectionState) then) =
      _$SelectionStateCopyWithImpl<$Res>;
  $Res call({bool isTextSelected});
}

class _$SelectionStateCopyWithImpl<$Res>
    implements $SelectionStateCopyWith<$Res> {
  _$SelectionStateCopyWithImpl(this._value, this._then);

  final SelectionState _value;
  // ignore: unused_field
  final $Res Function(SelectionState) _then;

  @override
  $Res call({
    Object isTextSelected = freezed,
  }) {
    return _then(_value.copyWith(
      isTextSelected: isTextSelected == freezed
          ? _value.isTextSelected
          : isTextSelected as bool,
    ));
  }
}

abstract class _$SelectionStateCopyWith<$Res>
    implements $SelectionStateCopyWith<$Res> {
  factory _$SelectionStateCopyWith(
          _SelectionState value, $Res Function(_SelectionState) then) =
      __$SelectionStateCopyWithImpl<$Res>;
  @override
  $Res call({bool isTextSelected});
}

class __$SelectionStateCopyWithImpl<$Res>
    extends _$SelectionStateCopyWithImpl<$Res>
    implements _$SelectionStateCopyWith<$Res> {
  __$SelectionStateCopyWithImpl(
      _SelectionState _value, $Res Function(_SelectionState) _then)
      : super(_value, (v) => _then(v as _SelectionState));

  @override
  _SelectionState get _value => super._value as _SelectionState;

  @override
  $Res call({
    Object isTextSelected = freezed,
  }) {
    return _then(_SelectionState(
      isTextSelected: isTextSelected == freezed
          ? _value.isTextSelected
          : isTextSelected as bool,
    ));
  }
}

class _$_SelectionState implements _SelectionState {
  const _$_SelectionState({this.isTextSelected});

  @override
  final bool isTextSelected;

  @override
  String toString() {
    return 'SelectionState(isTextSelected: $isTextSelected)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SelectionState &&
            (identical(other.isTextSelected, isTextSelected) ||
                const DeepCollectionEquality()
                    .equals(other.isTextSelected, isTextSelected)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(isTextSelected);

  @override
  _$SelectionStateCopyWith<_SelectionState> get copyWith =>
      __$SelectionStateCopyWithImpl<_SelectionState>(this, _$identity);
}

abstract class _SelectionState implements SelectionState {
  const factory _SelectionState({bool isTextSelected}) = _$_SelectionState;

  @override
  bool get isTextSelected;
  @override
  _$SelectionStateCopyWith<_SelectionState> get copyWith;
}

class _$SelectionStyleTearOff {
  const _$SelectionStyleTearOff();

// ignore: unused_element
  _SelectionStyle call(
      {HighlightType type,
      int color,
      bool isTrialMode = false,
      DateTime modified}) {
    return _SelectionStyle(
      type: type,
      color: color,
      isTrialMode: isTrialMode,
      modified: modified,
    );
  }
}

// ignore: unused_element
const $SelectionStyle = _$SelectionStyleTearOff();

mixin _$SelectionStyle {
  HighlightType get type;
  int get color;
  bool get isTrialMode;
  DateTime get modified;

  $SelectionStyleCopyWith<SelectionStyle> get copyWith;
}

abstract class $SelectionStyleCopyWith<$Res> {
  factory $SelectionStyleCopyWith(
          SelectionStyle value, $Res Function(SelectionStyle) then) =
      _$SelectionStyleCopyWithImpl<$Res>;
  $Res call(
      {HighlightType type, int color, bool isTrialMode, DateTime modified});
}

class _$SelectionStyleCopyWithImpl<$Res>
    implements $SelectionStyleCopyWith<$Res> {
  _$SelectionStyleCopyWithImpl(this._value, this._then);

  final SelectionStyle _value;
  // ignore: unused_field
  final $Res Function(SelectionStyle) _then;

  @override
  $Res call({
    Object type = freezed,
    Object color = freezed,
    Object isTrialMode = freezed,
    Object modified = freezed,
  }) {
    return _then(_value.copyWith(
      type: type == freezed ? _value.type : type as HighlightType,
      color: color == freezed ? _value.color : color as int,
      isTrialMode:
          isTrialMode == freezed ? _value.isTrialMode : isTrialMode as bool,
      modified: modified == freezed ? _value.modified : modified as DateTime,
    ));
  }
}

abstract class _$SelectionStyleCopyWith<$Res>
    implements $SelectionStyleCopyWith<$Res> {
  factory _$SelectionStyleCopyWith(
          _SelectionStyle value, $Res Function(_SelectionStyle) then) =
      __$SelectionStyleCopyWithImpl<$Res>;
  @override
  $Res call(
      {HighlightType type, int color, bool isTrialMode, DateTime modified});
}

class __$SelectionStyleCopyWithImpl<$Res>
    extends _$SelectionStyleCopyWithImpl<$Res>
    implements _$SelectionStyleCopyWith<$Res> {
  __$SelectionStyleCopyWithImpl(
      _SelectionStyle _value, $Res Function(_SelectionStyle) _then)
      : super(_value, (v) => _then(v as _SelectionStyle));

  @override
  _SelectionStyle get _value => super._value as _SelectionStyle;

  @override
  $Res call({
    Object type = freezed,
    Object color = freezed,
    Object isTrialMode = freezed,
    Object modified = freezed,
  }) {
    return _then(_SelectionStyle(
      type: type == freezed ? _value.type : type as HighlightType,
      color: color == freezed ? _value.color : color as int,
      isTrialMode:
          isTrialMode == freezed ? _value.isTrialMode : isTrialMode as bool,
      modified: modified == freezed ? _value.modified : modified as DateTime,
    ));
  }
}

class _$_SelectionStyle implements _SelectionStyle {
  const _$_SelectionStyle(
      {this.type, this.color, this.isTrialMode = false, this.modified})
      : assert(isTrialMode != null);

  @override
  final HighlightType type;
  @override
  final int color;
  @JsonKey(defaultValue: false)
  @override
  final bool isTrialMode;
  @override
  final DateTime modified;

  @override
  String toString() {
    return 'SelectionStyle(type: $type, color: $color, isTrialMode: $isTrialMode, modified: $modified)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SelectionStyle &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.color, color) ||
                const DeepCollectionEquality().equals(other.color, color)) &&
            (identical(other.isTrialMode, isTrialMode) ||
                const DeepCollectionEquality()
                    .equals(other.isTrialMode, isTrialMode)) &&
            (identical(other.modified, modified) ||
                const DeepCollectionEquality()
                    .equals(other.modified, modified)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(color) ^
      const DeepCollectionEquality().hash(isTrialMode) ^
      const DeepCollectionEquality().hash(modified);

  @override
  _$SelectionStyleCopyWith<_SelectionStyle> get copyWith =>
      __$SelectionStyleCopyWithImpl<_SelectionStyle>(this, _$identity);
}

abstract class _SelectionStyle implements SelectionStyle {
  const factory _SelectionStyle(
      {HighlightType type,
      int color,
      bool isTrialMode,
      DateTime modified}) = _$_SelectionStyle;

  @override
  HighlightType get type;
  @override
  int get color;
  @override
  bool get isTrialMode;
  @override
  DateTime get modified;
  @override
  _$SelectionStyleCopyWith<_SelectionStyle> get copyWith;
}

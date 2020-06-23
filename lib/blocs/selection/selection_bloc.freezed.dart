// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'selection_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$SelectionStateTearOff {
  const _$SelectionStateTearOff();

  _SelectionState call({bool hasSelection, SelectionType type, int color}) {
    return _SelectionState(
      hasSelection: hasSelection,
      type: type,
      color: color,
    );
  }
}

// ignore: unused_element
const $SelectionState = _$SelectionStateTearOff();

mixin _$SelectionState {
  bool get hasSelection;
  SelectionType get type;
  int get color;

  $SelectionStateCopyWith<SelectionState> get copyWith;
}

abstract class $SelectionStateCopyWith<$Res> {
  factory $SelectionStateCopyWith(
          SelectionState value, $Res Function(SelectionState) then) =
      _$SelectionStateCopyWithImpl<$Res>;
  $Res call({bool hasSelection, SelectionType type, int color});
}

class _$SelectionStateCopyWithImpl<$Res>
    implements $SelectionStateCopyWith<$Res> {
  _$SelectionStateCopyWithImpl(this._value, this._then);

  final SelectionState _value;
  // ignore: unused_field
  final $Res Function(SelectionState) _then;

  @override
  $Res call({
    Object hasSelection = freezed,
    Object type = freezed,
    Object color = freezed,
  }) {
    return _then(_value.copyWith(
      hasSelection:
          hasSelection == freezed ? _value.hasSelection : hasSelection as bool,
      type: type == freezed ? _value.type : type as SelectionType,
      color: color == freezed ? _value.color : color as int,
    ));
  }
}

abstract class _$SelectionStateCopyWith<$Res>
    implements $SelectionStateCopyWith<$Res> {
  factory _$SelectionStateCopyWith(
          _SelectionState value, $Res Function(_SelectionState) then) =
      __$SelectionStateCopyWithImpl<$Res>;
  @override
  $Res call({bool hasSelection, SelectionType type, int color});
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
    Object hasSelection = freezed,
    Object type = freezed,
    Object color = freezed,
  }) {
    return _then(_SelectionState(
      hasSelection:
          hasSelection == freezed ? _value.hasSelection : hasSelection as bool,
      type: type == freezed ? _value.type : type as SelectionType,
      color: color == freezed ? _value.color : color as int,
    ));
  }
}

class _$_SelectionState implements _SelectionState {
  _$_SelectionState({this.hasSelection, this.type, this.color});

  @override
  final bool hasSelection;
  @override
  final SelectionType type;
  @override
  final int color;

  @override
  String toString() {
    return 'SelectionState(hasSelection: $hasSelection, type: $type, color: $color)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SelectionState &&
            (identical(other.hasSelection, hasSelection) ||
                const DeepCollectionEquality()
                    .equals(other.hasSelection, hasSelection)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.color, color) ||
                const DeepCollectionEquality().equals(other.color, color)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(hasSelection) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(color);

  @override
  _$SelectionStateCopyWith<_SelectionState> get copyWith =>
      __$SelectionStateCopyWithImpl<_SelectionState>(this, _$identity);
}

abstract class _SelectionState implements SelectionState {
  factory _SelectionState({bool hasSelection, SelectionType type, int color}) =
      _$_SelectionState;

  @override
  bool get hasSelection;
  @override
  SelectionType get type;
  @override
  int get color;
  @override
  _$SelectionStateCopyWith<_SelectionState> get copyWith;
}

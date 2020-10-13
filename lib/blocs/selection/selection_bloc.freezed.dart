// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'selection_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
class _$SelectionStateTearOff {
  const _$SelectionStateTearOff();

// ignore: unused_element
  _SelectionState call({bool isTextSelected, List<int> viewsWithSelections}) {
    return _SelectionState(
      isTextSelected: isTextSelected,
      viewsWithSelections: viewsWithSelections,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $SelectionState = _$SelectionStateTearOff();

/// @nodoc
mixin _$SelectionState {
  bool get isTextSelected;
  List<int> get viewsWithSelections;

  $SelectionStateCopyWith<SelectionState> get copyWith;
}

/// @nodoc
abstract class $SelectionStateCopyWith<$Res> {
  factory $SelectionStateCopyWith(
          SelectionState value, $Res Function(SelectionState) then) =
      _$SelectionStateCopyWithImpl<$Res>;
  $Res call({bool isTextSelected, List<int> viewsWithSelections});
}

/// @nodoc
class _$SelectionStateCopyWithImpl<$Res>
    implements $SelectionStateCopyWith<$Res> {
  _$SelectionStateCopyWithImpl(this._value, this._then);

  final SelectionState _value;
  // ignore: unused_field
  final $Res Function(SelectionState) _then;

  @override
  $Res call({
    Object isTextSelected = freezed,
    Object viewsWithSelections = freezed,
  }) {
    return _then(_value.copyWith(
      isTextSelected: isTextSelected == freezed
          ? _value.isTextSelected
          : isTextSelected as bool,
      viewsWithSelections: viewsWithSelections == freezed
          ? _value.viewsWithSelections
          : viewsWithSelections as List<int>,
    ));
  }
}

/// @nodoc
abstract class _$SelectionStateCopyWith<$Res>
    implements $SelectionStateCopyWith<$Res> {
  factory _$SelectionStateCopyWith(
          _SelectionState value, $Res Function(_SelectionState) then) =
      __$SelectionStateCopyWithImpl<$Res>;
  @override
  $Res call({bool isTextSelected, List<int> viewsWithSelections});
}

/// @nodoc
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
    Object viewsWithSelections = freezed,
  }) {
    return _then(_SelectionState(
      isTextSelected: isTextSelected == freezed
          ? _value.isTextSelected
          : isTextSelected as bool,
      viewsWithSelections: viewsWithSelections == freezed
          ? _value.viewsWithSelections
          : viewsWithSelections as List<int>,
    ));
  }
}

/// @nodoc
class _$_SelectionState implements _SelectionState {
  const _$_SelectionState({this.isTextSelected, this.viewsWithSelections});

  @override
  final bool isTextSelected;
  @override
  final List<int> viewsWithSelections;

  @override
  String toString() {
    return 'SelectionState(isTextSelected: $isTextSelected, viewsWithSelections: $viewsWithSelections)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SelectionState &&
            (identical(other.isTextSelected, isTextSelected) ||
                const DeepCollectionEquality()
                    .equals(other.isTextSelected, isTextSelected)) &&
            (identical(other.viewsWithSelections, viewsWithSelections) ||
                const DeepCollectionEquality()
                    .equals(other.viewsWithSelections, viewsWithSelections)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(isTextSelected) ^
      const DeepCollectionEquality().hash(viewsWithSelections);

  @override
  _$SelectionStateCopyWith<_SelectionState> get copyWith =>
      __$SelectionStateCopyWithImpl<_SelectionState>(this, _$identity);
}

abstract class _SelectionState implements SelectionState {
  const factory _SelectionState(
      {bool isTextSelected, List<int> viewsWithSelections}) = _$_SelectionState;

  @override
  bool get isTextSelected;
  @override
  List<int> get viewsWithSelections;
  @override
  _$SelectionStateCopyWith<_SelectionState> get copyWith;
}

/// @nodoc
class _$SelectionCmdTearOff {
  const _$SelectionCmdTearOff();

// ignore: unused_element
  _ClearStyle clearStyle() {
    return const _ClearStyle();
  }

// ignore: unused_element
  _SetStyle setStyle(HighlightType type, int color) {
    return _SetStyle(
      type,
      color,
    );
  }

// ignore: unused_element
  _TryStyle tryStyle(HighlightType type, int color) {
    return _TryStyle(
      type,
      color,
    );
  }

// ignore: unused_element
  _CancelTrial cancelTrial() {
    return const _CancelTrial();
  }

// ignore: unused_element
  _DeselectAll deselectAll() {
    return const _DeselectAll();
  }
}

/// @nodoc
// ignore: unused_element
const $SelectionCmd = _$SelectionCmdTearOff();

/// @nodoc
mixin _$SelectionCmd {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result clearStyle(),
    @required Result setStyle(HighlightType type, int color),
    @required Result tryStyle(HighlightType type, int color),
    @required Result cancelTrial(),
    @required Result deselectAll(),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result clearStyle(),
    Result setStyle(HighlightType type, int color),
    Result tryStyle(HighlightType type, int color),
    Result cancelTrial(),
    Result deselectAll(),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result clearStyle(_ClearStyle value),
    @required Result setStyle(_SetStyle value),
    @required Result tryStyle(_TryStyle value),
    @required Result cancelTrial(_CancelTrial value),
    @required Result deselectAll(_DeselectAll value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result clearStyle(_ClearStyle value),
    Result setStyle(_SetStyle value),
    Result tryStyle(_TryStyle value),
    Result cancelTrial(_CancelTrial value),
    Result deselectAll(_DeselectAll value),
    @required Result orElse(),
  });
}

/// @nodoc
abstract class $SelectionCmdCopyWith<$Res> {
  factory $SelectionCmdCopyWith(
          SelectionCmd value, $Res Function(SelectionCmd) then) =
      _$SelectionCmdCopyWithImpl<$Res>;
}

/// @nodoc
class _$SelectionCmdCopyWithImpl<$Res> implements $SelectionCmdCopyWith<$Res> {
  _$SelectionCmdCopyWithImpl(this._value, this._then);

  final SelectionCmd _value;
  // ignore: unused_field
  final $Res Function(SelectionCmd) _then;
}

/// @nodoc
abstract class _$ClearStyleCopyWith<$Res> {
  factory _$ClearStyleCopyWith(
          _ClearStyle value, $Res Function(_ClearStyle) then) =
      __$ClearStyleCopyWithImpl<$Res>;
}

/// @nodoc
class __$ClearStyleCopyWithImpl<$Res> extends _$SelectionCmdCopyWithImpl<$Res>
    implements _$ClearStyleCopyWith<$Res> {
  __$ClearStyleCopyWithImpl(
      _ClearStyle _value, $Res Function(_ClearStyle) _then)
      : super(_value, (v) => _then(v as _ClearStyle));

  @override
  _ClearStyle get _value => super._value as _ClearStyle;
}

/// @nodoc
class _$_ClearStyle implements _ClearStyle {
  const _$_ClearStyle();

  @override
  String toString() {
    return 'SelectionCmd.clearStyle()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _ClearStyle);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result clearStyle(),
    @required Result setStyle(HighlightType type, int color),
    @required Result tryStyle(HighlightType type, int color),
    @required Result cancelTrial(),
    @required Result deselectAll(),
  }) {
    assert(clearStyle != null);
    assert(setStyle != null);
    assert(tryStyle != null);
    assert(cancelTrial != null);
    assert(deselectAll != null);
    return clearStyle();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result clearStyle(),
    Result setStyle(HighlightType type, int color),
    Result tryStyle(HighlightType type, int color),
    Result cancelTrial(),
    Result deselectAll(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (clearStyle != null) {
      return clearStyle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result clearStyle(_ClearStyle value),
    @required Result setStyle(_SetStyle value),
    @required Result tryStyle(_TryStyle value),
    @required Result cancelTrial(_CancelTrial value),
    @required Result deselectAll(_DeselectAll value),
  }) {
    assert(clearStyle != null);
    assert(setStyle != null);
    assert(tryStyle != null);
    assert(cancelTrial != null);
    assert(deselectAll != null);
    return clearStyle(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result clearStyle(_ClearStyle value),
    Result setStyle(_SetStyle value),
    Result tryStyle(_TryStyle value),
    Result cancelTrial(_CancelTrial value),
    Result deselectAll(_DeselectAll value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (clearStyle != null) {
      return clearStyle(this);
    }
    return orElse();
  }
}

abstract class _ClearStyle implements SelectionCmd {
  const factory _ClearStyle() = _$_ClearStyle;
}

/// @nodoc
abstract class _$SetStyleCopyWith<$Res> {
  factory _$SetStyleCopyWith(_SetStyle value, $Res Function(_SetStyle) then) =
      __$SetStyleCopyWithImpl<$Res>;
  $Res call({HighlightType type, int color});
}

/// @nodoc
class __$SetStyleCopyWithImpl<$Res> extends _$SelectionCmdCopyWithImpl<$Res>
    implements _$SetStyleCopyWith<$Res> {
  __$SetStyleCopyWithImpl(_SetStyle _value, $Res Function(_SetStyle) _then)
      : super(_value, (v) => _then(v as _SetStyle));

  @override
  _SetStyle get _value => super._value as _SetStyle;

  @override
  $Res call({
    Object type = freezed,
    Object color = freezed,
  }) {
    return _then(_SetStyle(
      type == freezed ? _value.type : type as HighlightType,
      color == freezed ? _value.color : color as int,
    ));
  }
}

/// @nodoc
class _$_SetStyle implements _SetStyle {
  const _$_SetStyle(this.type, this.color)
      : assert(type != null),
        assert(color != null);

  @override
  final HighlightType type;
  @override
  final int color;

  @override
  String toString() {
    return 'SelectionCmd.setStyle(type: $type, color: $color)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SetStyle &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.color, color) ||
                const DeepCollectionEquality().equals(other.color, color)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(color);

  @override
  _$SetStyleCopyWith<_SetStyle> get copyWith =>
      __$SetStyleCopyWithImpl<_SetStyle>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result clearStyle(),
    @required Result setStyle(HighlightType type, int color),
    @required Result tryStyle(HighlightType type, int color),
    @required Result cancelTrial(),
    @required Result deselectAll(),
  }) {
    assert(clearStyle != null);
    assert(setStyle != null);
    assert(tryStyle != null);
    assert(cancelTrial != null);
    assert(deselectAll != null);
    return setStyle(type, color);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result clearStyle(),
    Result setStyle(HighlightType type, int color),
    Result tryStyle(HighlightType type, int color),
    Result cancelTrial(),
    Result deselectAll(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setStyle != null) {
      return setStyle(type, color);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result clearStyle(_ClearStyle value),
    @required Result setStyle(_SetStyle value),
    @required Result tryStyle(_TryStyle value),
    @required Result cancelTrial(_CancelTrial value),
    @required Result deselectAll(_DeselectAll value),
  }) {
    assert(clearStyle != null);
    assert(setStyle != null);
    assert(tryStyle != null);
    assert(cancelTrial != null);
    assert(deselectAll != null);
    return setStyle(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result clearStyle(_ClearStyle value),
    Result setStyle(_SetStyle value),
    Result tryStyle(_TryStyle value),
    Result cancelTrial(_CancelTrial value),
    Result deselectAll(_DeselectAll value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setStyle != null) {
      return setStyle(this);
    }
    return orElse();
  }
}

abstract class _SetStyle implements SelectionCmd {
  const factory _SetStyle(HighlightType type, int color) = _$_SetStyle;

  HighlightType get type;
  int get color;
  _$SetStyleCopyWith<_SetStyle> get copyWith;
}

/// @nodoc
abstract class _$TryStyleCopyWith<$Res> {
  factory _$TryStyleCopyWith(_TryStyle value, $Res Function(_TryStyle) then) =
      __$TryStyleCopyWithImpl<$Res>;
  $Res call({HighlightType type, int color});
}

/// @nodoc
class __$TryStyleCopyWithImpl<$Res> extends _$SelectionCmdCopyWithImpl<$Res>
    implements _$TryStyleCopyWith<$Res> {
  __$TryStyleCopyWithImpl(_TryStyle _value, $Res Function(_TryStyle) _then)
      : super(_value, (v) => _then(v as _TryStyle));

  @override
  _TryStyle get _value => super._value as _TryStyle;

  @override
  $Res call({
    Object type = freezed,
    Object color = freezed,
  }) {
    return _then(_TryStyle(
      type == freezed ? _value.type : type as HighlightType,
      color == freezed ? _value.color : color as int,
    ));
  }
}

/// @nodoc
class _$_TryStyle implements _TryStyle {
  const _$_TryStyle(this.type, this.color)
      : assert(type != null),
        assert(color != null);

  @override
  final HighlightType type;
  @override
  final int color;

  @override
  String toString() {
    return 'SelectionCmd.tryStyle(type: $type, color: $color)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _TryStyle &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.color, color) ||
                const DeepCollectionEquality().equals(other.color, color)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(color);

  @override
  _$TryStyleCopyWith<_TryStyle> get copyWith =>
      __$TryStyleCopyWithImpl<_TryStyle>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result clearStyle(),
    @required Result setStyle(HighlightType type, int color),
    @required Result tryStyle(HighlightType type, int color),
    @required Result cancelTrial(),
    @required Result deselectAll(),
  }) {
    assert(clearStyle != null);
    assert(setStyle != null);
    assert(tryStyle != null);
    assert(cancelTrial != null);
    assert(deselectAll != null);
    return tryStyle(type, color);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result clearStyle(),
    Result setStyle(HighlightType type, int color),
    Result tryStyle(HighlightType type, int color),
    Result cancelTrial(),
    Result deselectAll(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (tryStyle != null) {
      return tryStyle(type, color);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result clearStyle(_ClearStyle value),
    @required Result setStyle(_SetStyle value),
    @required Result tryStyle(_TryStyle value),
    @required Result cancelTrial(_CancelTrial value),
    @required Result deselectAll(_DeselectAll value),
  }) {
    assert(clearStyle != null);
    assert(setStyle != null);
    assert(tryStyle != null);
    assert(cancelTrial != null);
    assert(deselectAll != null);
    return tryStyle(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result clearStyle(_ClearStyle value),
    Result setStyle(_SetStyle value),
    Result tryStyle(_TryStyle value),
    Result cancelTrial(_CancelTrial value),
    Result deselectAll(_DeselectAll value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (tryStyle != null) {
      return tryStyle(this);
    }
    return orElse();
  }
}

abstract class _TryStyle implements SelectionCmd {
  const factory _TryStyle(HighlightType type, int color) = _$_TryStyle;

  HighlightType get type;
  int get color;
  _$TryStyleCopyWith<_TryStyle> get copyWith;
}

/// @nodoc
abstract class _$CancelTrialCopyWith<$Res> {
  factory _$CancelTrialCopyWith(
          _CancelTrial value, $Res Function(_CancelTrial) then) =
      __$CancelTrialCopyWithImpl<$Res>;
}

/// @nodoc
class __$CancelTrialCopyWithImpl<$Res> extends _$SelectionCmdCopyWithImpl<$Res>
    implements _$CancelTrialCopyWith<$Res> {
  __$CancelTrialCopyWithImpl(
      _CancelTrial _value, $Res Function(_CancelTrial) _then)
      : super(_value, (v) => _then(v as _CancelTrial));

  @override
  _CancelTrial get _value => super._value as _CancelTrial;
}

/// @nodoc
class _$_CancelTrial implements _CancelTrial {
  const _$_CancelTrial();

  @override
  String toString() {
    return 'SelectionCmd.cancelTrial()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _CancelTrial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result clearStyle(),
    @required Result setStyle(HighlightType type, int color),
    @required Result tryStyle(HighlightType type, int color),
    @required Result cancelTrial(),
    @required Result deselectAll(),
  }) {
    assert(clearStyle != null);
    assert(setStyle != null);
    assert(tryStyle != null);
    assert(cancelTrial != null);
    assert(deselectAll != null);
    return cancelTrial();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result clearStyle(),
    Result setStyle(HighlightType type, int color),
    Result tryStyle(HighlightType type, int color),
    Result cancelTrial(),
    Result deselectAll(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (cancelTrial != null) {
      return cancelTrial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result clearStyle(_ClearStyle value),
    @required Result setStyle(_SetStyle value),
    @required Result tryStyle(_TryStyle value),
    @required Result cancelTrial(_CancelTrial value),
    @required Result deselectAll(_DeselectAll value),
  }) {
    assert(clearStyle != null);
    assert(setStyle != null);
    assert(tryStyle != null);
    assert(cancelTrial != null);
    assert(deselectAll != null);
    return cancelTrial(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result clearStyle(_ClearStyle value),
    Result setStyle(_SetStyle value),
    Result tryStyle(_TryStyle value),
    Result cancelTrial(_CancelTrial value),
    Result deselectAll(_DeselectAll value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (cancelTrial != null) {
      return cancelTrial(this);
    }
    return orElse();
  }
}

abstract class _CancelTrial implements SelectionCmd {
  const factory _CancelTrial() = _$_CancelTrial;
}

/// @nodoc
abstract class _$DeselectAllCopyWith<$Res> {
  factory _$DeselectAllCopyWith(
          _DeselectAll value, $Res Function(_DeselectAll) then) =
      __$DeselectAllCopyWithImpl<$Res>;
}

/// @nodoc
class __$DeselectAllCopyWithImpl<$Res> extends _$SelectionCmdCopyWithImpl<$Res>
    implements _$DeselectAllCopyWith<$Res> {
  __$DeselectAllCopyWithImpl(
      _DeselectAll _value, $Res Function(_DeselectAll) _then)
      : super(_value, (v) => _then(v as _DeselectAll));

  @override
  _DeselectAll get _value => super._value as _DeselectAll;
}

/// @nodoc
class _$_DeselectAll implements _DeselectAll {
  const _$_DeselectAll();

  @override
  String toString() {
    return 'SelectionCmd.deselectAll()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _DeselectAll);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result clearStyle(),
    @required Result setStyle(HighlightType type, int color),
    @required Result tryStyle(HighlightType type, int color),
    @required Result cancelTrial(),
    @required Result deselectAll(),
  }) {
    assert(clearStyle != null);
    assert(setStyle != null);
    assert(tryStyle != null);
    assert(cancelTrial != null);
    assert(deselectAll != null);
    return deselectAll();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result clearStyle(),
    Result setStyle(HighlightType type, int color),
    Result tryStyle(HighlightType type, int color),
    Result cancelTrial(),
    Result deselectAll(),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (deselectAll != null) {
      return deselectAll();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result clearStyle(_ClearStyle value),
    @required Result setStyle(_SetStyle value),
    @required Result tryStyle(_TryStyle value),
    @required Result cancelTrial(_CancelTrial value),
    @required Result deselectAll(_DeselectAll value),
  }) {
    assert(clearStyle != null);
    assert(setStyle != null);
    assert(tryStyle != null);
    assert(cancelTrial != null);
    assert(deselectAll != null);
    return deselectAll(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result clearStyle(_ClearStyle value),
    Result setStyle(_SetStyle value),
    Result tryStyle(_TryStyle value),
    Result cancelTrial(_CancelTrial value),
    Result deselectAll(_DeselectAll value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (deselectAll != null) {
      return deselectAll(this);
    }
    return orElse();
  }
}

abstract class _DeselectAll implements SelectionCmd {
  const factory _DeselectAll() = _$_DeselectAll;
}

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, avoid_positional_boolean_parameters

part of 'selection_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$SelectionStateTearOff {
  const _$SelectionStateTearOff();

  _SelectionState call(
      {bool isTextSelected, HighlightType highlightType, int color}) {
    return _SelectionState(
      isTextSelected: isTextSelected,
      highlightType: highlightType,
      color: color,
    );
  }
}

// ignore: unused_element
const $SelectionState = _$SelectionStateTearOff();

mixin _$SelectionState {
  bool get isTextSelected;
  HighlightType get highlightType;
  int get color;

  $SelectionStateCopyWith<SelectionState> get copyWith;
}

abstract class $SelectionStateCopyWith<$Res> {
  factory $SelectionStateCopyWith(
          SelectionState value, $Res Function(SelectionState) then) =
      _$SelectionStateCopyWithImpl<$Res>;
  $Res call({bool isTextSelected, HighlightType highlightType, int color});
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
    Object highlightType = freezed,
    Object color = freezed,
  }) {
    return _then(_value.copyWith(
      isTextSelected: isTextSelected == freezed
          ? _value.isTextSelected
          : isTextSelected as bool,
      highlightType: highlightType == freezed
          ? _value.highlightType
          : highlightType as HighlightType,
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
  $Res call({bool isTextSelected, HighlightType highlightType, int color});
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
    Object highlightType = freezed,
    Object color = freezed,
  }) {
    return _then(_SelectionState(
      isTextSelected: isTextSelected == freezed
          ? _value.isTextSelected
          : isTextSelected as bool,
      highlightType: highlightType == freezed
          ? _value.highlightType
          : highlightType as HighlightType,
      color: color == freezed ? _value.color : color as int,
    ));
  }
}

class _$_SelectionState implements _SelectionState {
  _$_SelectionState({this.isTextSelected, this.highlightType, this.color});

  @override
  final bool isTextSelected;
  @override
  final HighlightType highlightType;
  @override
  final int color;

  @override
  String toString() {
    return 'SelectionState(isTextSelected: $isTextSelected, highlightType: $highlightType, color: $color)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SelectionState &&
            (identical(other.isTextSelected, isTextSelected) ||
                const DeepCollectionEquality()
                    .equals(other.isTextSelected, isTextSelected)) &&
            (identical(other.highlightType, highlightType) ||
                const DeepCollectionEquality()
                    .equals(other.highlightType, highlightType)) &&
            (identical(other.color, color) ||
                const DeepCollectionEquality().equals(other.color, color)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(isTextSelected) ^
      const DeepCollectionEquality().hash(highlightType) ^
      const DeepCollectionEquality().hash(color);

  @override
  _$SelectionStateCopyWith<_SelectionState> get copyWith =>
      __$SelectionStateCopyWithImpl<_SelectionState>(this, _$identity);
}

abstract class _SelectionState implements SelectionState {
  factory _SelectionState(
      {bool isTextSelected,
      HighlightType highlightType,
      int color}) = _$_SelectionState;

  @override
  bool get isTextSelected;
  @override
  HighlightType get highlightType;
  @override
  int get color;
  @override
  _$SelectionStateCopyWith<_SelectionState> get copyWith;
}

class _$SelectionEventTearOff {
  const _$SelectionEventTearOff();

  _Highlight highlight({@required HighlightType type, int color}) {
    return _Highlight(
      type: type,
      color: color,
    );
  }

  _UpdateIsTextSelected updateIsTextSelected(bool isTextSelected) {
    return _UpdateIsTextSelected(
      isTextSelected,
    );
  }
}

// ignore: unused_element
const $SelectionEvent = _$SelectionEventTearOff();

mixin _$SelectionEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result highlight(HighlightType type, int color),
    @required Result updateIsTextSelected(bool isTextSelected),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result highlight(HighlightType type, int color),
    Result updateIsTextSelected(bool isTextSelected),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result highlight(_Highlight value),
    @required Result updateIsTextSelected(_UpdateIsTextSelected value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result highlight(_Highlight value),
    Result updateIsTextSelected(_UpdateIsTextSelected value),
    @required Result orElse(),
  });
}

abstract class $SelectionEventCopyWith<$Res> {
  factory $SelectionEventCopyWith(
          SelectionEvent value, $Res Function(SelectionEvent) then) =
      _$SelectionEventCopyWithImpl<$Res>;
}

class _$SelectionEventCopyWithImpl<$Res>
    implements $SelectionEventCopyWith<$Res> {
  _$SelectionEventCopyWithImpl(this._value, this._then);

  final SelectionEvent _value;
  // ignore: unused_field
  final $Res Function(SelectionEvent) _then;
}

abstract class _$HighlightCopyWith<$Res> {
  factory _$HighlightCopyWith(
          _Highlight value, $Res Function(_Highlight) then) =
      __$HighlightCopyWithImpl<$Res>;
  $Res call({HighlightType type, int color});
}

class __$HighlightCopyWithImpl<$Res> extends _$SelectionEventCopyWithImpl<$Res>
    implements _$HighlightCopyWith<$Res> {
  __$HighlightCopyWithImpl(_Highlight _value, $Res Function(_Highlight) _then)
      : super(_value, (v) => _then(v as _Highlight));

  @override
  _Highlight get _value => super._value as _Highlight;

  @override
  $Res call({
    Object type = freezed,
    Object color = freezed,
  }) {
    return _then(_Highlight(
      type: type == freezed ? _value.type : type as HighlightType,
      color: color == freezed ? _value.color : color as int,
    ));
  }
}

class _$_Highlight implements _Highlight {
  const _$_Highlight({@required this.type, this.color}) : assert(type != null);

  @override
  final HighlightType type;
  @override
  final int color;

  @override
  String toString() {
    return 'SelectionEvent.highlight(type: $type, color: $color)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Highlight &&
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
  _$HighlightCopyWith<_Highlight> get copyWith =>
      __$HighlightCopyWithImpl<_Highlight>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result highlight(HighlightType type, int color),
    @required Result updateIsTextSelected(bool isTextSelected),
  }) {
    assert(highlight != null);
    assert(updateIsTextSelected != null);
    return highlight(type, color);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result highlight(HighlightType type, int color),
    Result updateIsTextSelected(bool isTextSelected),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (highlight != null) {
      return highlight(type, color);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result highlight(_Highlight value),
    @required Result updateIsTextSelected(_UpdateIsTextSelected value),
  }) {
    assert(highlight != null);
    assert(updateIsTextSelected != null);
    return highlight(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result highlight(_Highlight value),
    Result updateIsTextSelected(_UpdateIsTextSelected value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (highlight != null) {
      return highlight(this);
    }
    return orElse();
  }
}

abstract class _Highlight implements SelectionEvent {
  const factory _Highlight({@required HighlightType type, int color}) =
      _$_Highlight;

  HighlightType get type;
  int get color;
  _$HighlightCopyWith<_Highlight> get copyWith;
}

abstract class _$UpdateIsTextSelectedCopyWith<$Res> {
  factory _$UpdateIsTextSelectedCopyWith(_UpdateIsTextSelected value,
          $Res Function(_UpdateIsTextSelected) then) =
      __$UpdateIsTextSelectedCopyWithImpl<$Res>;
  $Res call({bool isTextSelected});
}

class __$UpdateIsTextSelectedCopyWithImpl<$Res>
    extends _$SelectionEventCopyWithImpl<$Res>
    implements _$UpdateIsTextSelectedCopyWith<$Res> {
  __$UpdateIsTextSelectedCopyWithImpl(
      _UpdateIsTextSelected _value, $Res Function(_UpdateIsTextSelected) _then)
      : super(_value, (v) => _then(v as _UpdateIsTextSelected));

  @override
  _UpdateIsTextSelected get _value => super._value as _UpdateIsTextSelected;

  @override
  $Res call({
    Object isTextSelected = freezed,
  }) {
    return _then(_UpdateIsTextSelected(
      isTextSelected == freezed
          ? _value.isTextSelected
          : isTextSelected as bool,
    ));
  }
}

class _$_UpdateIsTextSelected implements _UpdateIsTextSelected {
  const _$_UpdateIsTextSelected(this.isTextSelected)
      : assert(isTextSelected != null);

  @override
  final bool isTextSelected;

  @override
  String toString() {
    return 'SelectionEvent.updateIsTextSelected(isTextSelected: $isTextSelected)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _UpdateIsTextSelected &&
            (identical(other.isTextSelected, isTextSelected) ||
                const DeepCollectionEquality()
                    .equals(other.isTextSelected, isTextSelected)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(isTextSelected);

  @override
  _$UpdateIsTextSelectedCopyWith<_UpdateIsTextSelected> get copyWith =>
      __$UpdateIsTextSelectedCopyWithImpl<_UpdateIsTextSelected>(
          this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result highlight(HighlightType type, int color),
    @required Result updateIsTextSelected(bool isTextSelected),
  }) {
    assert(highlight != null);
    assert(updateIsTextSelected != null);
    return updateIsTextSelected(isTextSelected);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result highlight(HighlightType type, int color),
    Result updateIsTextSelected(bool isTextSelected),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (updateIsTextSelected != null) {
      return updateIsTextSelected(isTextSelected);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result highlight(_Highlight value),
    @required Result updateIsTextSelected(_UpdateIsTextSelected value),
  }) {
    assert(highlight != null);
    assert(updateIsTextSelected != null);
    return updateIsTextSelected(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result highlight(_Highlight value),
    Result updateIsTextSelected(_UpdateIsTextSelected value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (updateIsTextSelected != null) {
      return updateIsTextSelected(this);
    }
    return orElse();
  }
}

abstract class _UpdateIsTextSelected implements SelectionEvent {
  const factory _UpdateIsTextSelected(bool isTextSelected) =
      _$_UpdateIsTextSelected;

  bool get isTextSelected;
  _$UpdateIsTextSelectedCopyWith<_UpdateIsTextSelected> get copyWith;
}

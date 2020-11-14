// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'view_manager_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
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

/// @nodoc
// ignore: unused_element
const $ManagedViewState = _$ManagedViewStateTearOff();

/// @nodoc
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

/// @nodoc
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

/// @nodoc
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

/// @nodoc
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

/// @nodoc
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

/// @nodoc
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

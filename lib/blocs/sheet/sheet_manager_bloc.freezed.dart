// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'sheet_manager_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$SheetManagerStateTearOff {
  const _$SheetManagerStateTearOff();

// ignore: unused_element
  _SheetState call(
      {@required SheetType type, @required SheetSize size, int viewUid}) {
    return _SheetState(
      type: type,
      size: size,
      viewUid: viewUid,
    );
  }
}

// ignore: unused_element
const $SheetManagerState = _$SheetManagerStateTearOff();

mixin _$SheetManagerState {
  SheetType get type;
  SheetSize get size;
  int get viewUid;

  $SheetManagerStateCopyWith<SheetManagerState> get copyWith;
}

abstract class $SheetManagerStateCopyWith<$Res> {
  factory $SheetManagerStateCopyWith(
          SheetManagerState value, $Res Function(SheetManagerState) then) =
      _$SheetManagerStateCopyWithImpl<$Res>;
  $Res call({SheetType type, SheetSize size, int viewUid});
}

class _$SheetManagerStateCopyWithImpl<$Res>
    implements $SheetManagerStateCopyWith<$Res> {
  _$SheetManagerStateCopyWithImpl(this._value, this._then);

  final SheetManagerState _value;
  // ignore: unused_field
  final $Res Function(SheetManagerState) _then;

  @override
  $Res call({
    Object type = freezed,
    Object size = freezed,
    Object viewUid = freezed,
  }) {
    return _then(_value.copyWith(
      type: type == freezed ? _value.type : type as SheetType,
      size: size == freezed ? _value.size : size as SheetSize,
      viewUid: viewUid == freezed ? _value.viewUid : viewUid as int,
    ));
  }
}

abstract class _$SheetStateCopyWith<$Res>
    implements $SheetManagerStateCopyWith<$Res> {
  factory _$SheetStateCopyWith(
          _SheetState value, $Res Function(_SheetState) then) =
      __$SheetStateCopyWithImpl<$Res>;
  @override
  $Res call({SheetType type, SheetSize size, int viewUid});
}

class __$SheetStateCopyWithImpl<$Res>
    extends _$SheetManagerStateCopyWithImpl<$Res>
    implements _$SheetStateCopyWith<$Res> {
  __$SheetStateCopyWithImpl(
      _SheetState _value, $Res Function(_SheetState) _then)
      : super(_value, (v) => _then(v as _SheetState));

  @override
  _SheetState get _value => super._value as _SheetState;

  @override
  $Res call({
    Object type = freezed,
    Object size = freezed,
    Object viewUid = freezed,
  }) {
    return _then(_SheetState(
      type: type == freezed ? _value.type : type as SheetType,
      size: size == freezed ? _value.size : size as SheetSize,
      viewUid: viewUid == freezed ? _value.viewUid : viewUid as int,
    ));
  }
}

class _$_SheetState with DiagnosticableTreeMixin implements _SheetState {
  const _$_SheetState({@required this.type, @required this.size, this.viewUid})
      : assert(type != null),
        assert(size != null);

  @override
  final SheetType type;
  @override
  final SheetSize size;
  @override
  final int viewUid;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SheetManagerState(type: $type, size: $size, viewUid: $viewUid)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SheetManagerState'))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('size', size))
      ..add(DiagnosticsProperty('viewUid', viewUid));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SheetState &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.size, size) ||
                const DeepCollectionEquality().equals(other.size, size)) &&
            (identical(other.viewUid, viewUid) ||
                const DeepCollectionEquality().equals(other.viewUid, viewUid)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(size) ^
      const DeepCollectionEquality().hash(viewUid);

  @override
  _$SheetStateCopyWith<_SheetState> get copyWith =>
      __$SheetStateCopyWithImpl<_SheetState>(this, _$identity);
}

abstract class _SheetState implements SheetManagerState {
  const factory _SheetState(
      {@required SheetType type,
      @required SheetSize size,
      int viewUid}) = _$_SheetState;

  @override
  SheetType get type;
  @override
  SheetSize get size;
  @override
  int get viewUid;
  @override
  _$SheetStateCopyWith<_SheetState> get copyWith;
}

class _$SheetEventTearOff {
  const _$SheetEventTearOff();

// ignore: unused_element
  _ChangeSize changeSize(SheetSize size) {
    return _ChangeSize(
      size,
    );
  }

// ignore: unused_element
  _ChangeType changeType(SheetType type) {
    return _ChangeType(
      type,
    );
  }

// ignore: unused_element
  _ChangeView changeView(int uid) {
    return _ChangeView(
      uid,
    );
  }

// ignore: unused_element
  _ChangeTypeSize changeTypeSize(SheetType type, SheetSize size) {
    return _ChangeTypeSize(
      type,
      size,
    );
  }
}

// ignore: unused_element
const $SheetEvent = _$SheetEventTearOff();

mixin _$SheetEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeSize(SheetSize size),
    @required Result changeType(SheetType type),
    @required Result changeView(int uid),
    @required Result changeTypeSize(SheetType type, SheetSize size),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeSize(SheetSize size),
    Result changeType(SheetType type),
    Result changeView(int uid),
    Result changeTypeSize(SheetType type, SheetSize size),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeSize(_ChangeSize value),
    @required Result changeType(_ChangeType value),
    @required Result changeView(_ChangeView value),
    @required Result changeTypeSize(_ChangeTypeSize value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeSize(_ChangeSize value),
    Result changeType(_ChangeType value),
    Result changeView(_ChangeView value),
    Result changeTypeSize(_ChangeTypeSize value),
    @required Result orElse(),
  });
}

abstract class $SheetEventCopyWith<$Res> {
  factory $SheetEventCopyWith(
          SheetEvent value, $Res Function(SheetEvent) then) =
      _$SheetEventCopyWithImpl<$Res>;
}

class _$SheetEventCopyWithImpl<$Res> implements $SheetEventCopyWith<$Res> {
  _$SheetEventCopyWithImpl(this._value, this._then);

  final SheetEvent _value;
  // ignore: unused_field
  final $Res Function(SheetEvent) _then;
}

abstract class _$ChangeSizeCopyWith<$Res> {
  factory _$ChangeSizeCopyWith(
          _ChangeSize value, $Res Function(_ChangeSize) then) =
      __$ChangeSizeCopyWithImpl<$Res>;
  $Res call({SheetSize size});
}

class __$ChangeSizeCopyWithImpl<$Res> extends _$SheetEventCopyWithImpl<$Res>
    implements _$ChangeSizeCopyWith<$Res> {
  __$ChangeSizeCopyWithImpl(
      _ChangeSize _value, $Res Function(_ChangeSize) _then)
      : super(_value, (v) => _then(v as _ChangeSize));

  @override
  _ChangeSize get _value => super._value as _ChangeSize;

  @override
  $Res call({
    Object size = freezed,
  }) {
    return _then(_ChangeSize(
      size == freezed ? _value.size : size as SheetSize,
    ));
  }
}

class _$_ChangeSize with DiagnosticableTreeMixin implements _ChangeSize {
  const _$_ChangeSize(this.size) : assert(size != null);

  @override
  final SheetSize size;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SheetEvent.changeSize(size: $size)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SheetEvent.changeSize'))
      ..add(DiagnosticsProperty('size', size));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ChangeSize &&
            (identical(other.size, size) ||
                const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(size);

  @override
  _$ChangeSizeCopyWith<_ChangeSize> get copyWith =>
      __$ChangeSizeCopyWithImpl<_ChangeSize>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeSize(SheetSize size),
    @required Result changeType(SheetType type),
    @required Result changeView(int uid),
    @required Result changeTypeSize(SheetType type, SheetSize size),
  }) {
    assert(changeSize != null);
    assert(changeType != null);
    assert(changeView != null);
    assert(changeTypeSize != null);
    return changeSize(size);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeSize(SheetSize size),
    Result changeType(SheetType type),
    Result changeView(int uid),
    Result changeTypeSize(SheetType type, SheetSize size),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeSize != null) {
      return changeSize(size);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeSize(_ChangeSize value),
    @required Result changeType(_ChangeType value),
    @required Result changeView(_ChangeView value),
    @required Result changeTypeSize(_ChangeTypeSize value),
  }) {
    assert(changeSize != null);
    assert(changeType != null);
    assert(changeView != null);
    assert(changeTypeSize != null);
    return changeSize(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeSize(_ChangeSize value),
    Result changeType(_ChangeType value),
    Result changeView(_ChangeView value),
    Result changeTypeSize(_ChangeTypeSize value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeSize != null) {
      return changeSize(this);
    }
    return orElse();
  }
}

abstract class _ChangeSize implements SheetEvent {
  const factory _ChangeSize(SheetSize size) = _$_ChangeSize;

  SheetSize get size;
  _$ChangeSizeCopyWith<_ChangeSize> get copyWith;
}

abstract class _$ChangeTypeCopyWith<$Res> {
  factory _$ChangeTypeCopyWith(
          _ChangeType value, $Res Function(_ChangeType) then) =
      __$ChangeTypeCopyWithImpl<$Res>;
  $Res call({SheetType type});
}

class __$ChangeTypeCopyWithImpl<$Res> extends _$SheetEventCopyWithImpl<$Res>
    implements _$ChangeTypeCopyWith<$Res> {
  __$ChangeTypeCopyWithImpl(
      _ChangeType _value, $Res Function(_ChangeType) _then)
      : super(_value, (v) => _then(v as _ChangeType));

  @override
  _ChangeType get _value => super._value as _ChangeType;

  @override
  $Res call({
    Object type = freezed,
  }) {
    return _then(_ChangeType(
      type == freezed ? _value.type : type as SheetType,
    ));
  }
}

class _$_ChangeType with DiagnosticableTreeMixin implements _ChangeType {
  const _$_ChangeType(this.type) : assert(type != null);

  @override
  final SheetType type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SheetEvent.changeType(type: $type)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SheetEvent.changeType'))
      ..add(DiagnosticsProperty('type', type));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ChangeType &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(type);

  @override
  _$ChangeTypeCopyWith<_ChangeType> get copyWith =>
      __$ChangeTypeCopyWithImpl<_ChangeType>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeSize(SheetSize size),
    @required Result changeType(SheetType type),
    @required Result changeView(int uid),
    @required Result changeTypeSize(SheetType type, SheetSize size),
  }) {
    assert(changeSize != null);
    assert(changeType != null);
    assert(changeView != null);
    assert(changeTypeSize != null);
    return changeType(type);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeSize(SheetSize size),
    Result changeType(SheetType type),
    Result changeView(int uid),
    Result changeTypeSize(SheetType type, SheetSize size),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeType != null) {
      return changeType(type);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeSize(_ChangeSize value),
    @required Result changeType(_ChangeType value),
    @required Result changeView(_ChangeView value),
    @required Result changeTypeSize(_ChangeTypeSize value),
  }) {
    assert(changeSize != null);
    assert(changeType != null);
    assert(changeView != null);
    assert(changeTypeSize != null);
    return changeType(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeSize(_ChangeSize value),
    Result changeType(_ChangeType value),
    Result changeView(_ChangeView value),
    Result changeTypeSize(_ChangeTypeSize value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeType != null) {
      return changeType(this);
    }
    return orElse();
  }
}

abstract class _ChangeType implements SheetEvent {
  const factory _ChangeType(SheetType type) = _$_ChangeType;

  SheetType get type;
  _$ChangeTypeCopyWith<_ChangeType> get copyWith;
}

abstract class _$ChangeViewCopyWith<$Res> {
  factory _$ChangeViewCopyWith(
          _ChangeView value, $Res Function(_ChangeView) then) =
      __$ChangeViewCopyWithImpl<$Res>;
  $Res call({int uid});
}

class __$ChangeViewCopyWithImpl<$Res> extends _$SheetEventCopyWithImpl<$Res>
    implements _$ChangeViewCopyWith<$Res> {
  __$ChangeViewCopyWithImpl(
      _ChangeView _value, $Res Function(_ChangeView) _then)
      : super(_value, (v) => _then(v as _ChangeView));

  @override
  _ChangeView get _value => super._value as _ChangeView;

  @override
  $Res call({
    Object uid = freezed,
  }) {
    return _then(_ChangeView(
      uid == freezed ? _value.uid : uid as int,
    ));
  }
}

class _$_ChangeView with DiagnosticableTreeMixin implements _ChangeView {
  const _$_ChangeView(this.uid) : assert(uid != null);

  @override
  final int uid;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SheetEvent.changeView(uid: $uid)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SheetEvent.changeView'))
      ..add(DiagnosticsProperty('uid', uid));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ChangeView &&
            (identical(other.uid, uid) ||
                const DeepCollectionEquality().equals(other.uid, uid)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(uid);

  @override
  _$ChangeViewCopyWith<_ChangeView> get copyWith =>
      __$ChangeViewCopyWithImpl<_ChangeView>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeSize(SheetSize size),
    @required Result changeType(SheetType type),
    @required Result changeView(int uid),
    @required Result changeTypeSize(SheetType type, SheetSize size),
  }) {
    assert(changeSize != null);
    assert(changeType != null);
    assert(changeView != null);
    assert(changeTypeSize != null);
    return changeView(uid);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeSize(SheetSize size),
    Result changeType(SheetType type),
    Result changeView(int uid),
    Result changeTypeSize(SheetType type, SheetSize size),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeView != null) {
      return changeView(uid);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeSize(_ChangeSize value),
    @required Result changeType(_ChangeType value),
    @required Result changeView(_ChangeView value),
    @required Result changeTypeSize(_ChangeTypeSize value),
  }) {
    assert(changeSize != null);
    assert(changeType != null);
    assert(changeView != null);
    assert(changeTypeSize != null);
    return changeView(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeSize(_ChangeSize value),
    Result changeType(_ChangeType value),
    Result changeView(_ChangeView value),
    Result changeTypeSize(_ChangeTypeSize value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeView != null) {
      return changeView(this);
    }
    return orElse();
  }
}

abstract class _ChangeView implements SheetEvent {
  const factory _ChangeView(int uid) = _$_ChangeView;

  int get uid;
  _$ChangeViewCopyWith<_ChangeView> get copyWith;
}

abstract class _$ChangeTypeSizeCopyWith<$Res> {
  factory _$ChangeTypeSizeCopyWith(
          _ChangeTypeSize value, $Res Function(_ChangeTypeSize) then) =
      __$ChangeTypeSizeCopyWithImpl<$Res>;
  $Res call({SheetType type, SheetSize size});
}

class __$ChangeTypeSizeCopyWithImpl<$Res> extends _$SheetEventCopyWithImpl<$Res>
    implements _$ChangeTypeSizeCopyWith<$Res> {
  __$ChangeTypeSizeCopyWithImpl(
      _ChangeTypeSize _value, $Res Function(_ChangeTypeSize) _then)
      : super(_value, (v) => _then(v as _ChangeTypeSize));

  @override
  _ChangeTypeSize get _value => super._value as _ChangeTypeSize;

  @override
  $Res call({
    Object type = freezed,
    Object size = freezed,
  }) {
    return _then(_ChangeTypeSize(
      type == freezed ? _value.type : type as SheetType,
      size == freezed ? _value.size : size as SheetSize,
    ));
  }
}

class _$_ChangeTypeSize
    with DiagnosticableTreeMixin
    implements _ChangeTypeSize {
  const _$_ChangeTypeSize(this.type, this.size)
      : assert(type != null),
        assert(size != null);

  @override
  final SheetType type;
  @override
  final SheetSize size;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SheetEvent.changeTypeSize(type: $type, size: $size)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SheetEvent.changeTypeSize'))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('size', size));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ChangeTypeSize &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.size, size) ||
                const DeepCollectionEquality().equals(other.size, size)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(size);

  @override
  _$ChangeTypeSizeCopyWith<_ChangeTypeSize> get copyWith =>
      __$ChangeTypeSizeCopyWithImpl<_ChangeTypeSize>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeSize(SheetSize size),
    @required Result changeType(SheetType type),
    @required Result changeView(int uid),
    @required Result changeTypeSize(SheetType type, SheetSize size),
  }) {
    assert(changeSize != null);
    assert(changeType != null);
    assert(changeView != null);
    assert(changeTypeSize != null);
    return changeTypeSize(type, size);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeSize(SheetSize size),
    Result changeType(SheetType type),
    Result changeView(int uid),
    Result changeTypeSize(SheetType type, SheetSize size),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeTypeSize != null) {
      return changeTypeSize(type, size);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeSize(_ChangeSize value),
    @required Result changeType(_ChangeType value),
    @required Result changeView(_ChangeView value),
    @required Result changeTypeSize(_ChangeTypeSize value),
  }) {
    assert(changeSize != null);
    assert(changeType != null);
    assert(changeView != null);
    assert(changeTypeSize != null);
    return changeTypeSize(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeSize(_ChangeSize value),
    Result changeType(_ChangeType value),
    Result changeView(_ChangeView value),
    Result changeTypeSize(_ChangeTypeSize value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeTypeSize != null) {
      return changeTypeSize(this);
    }
    return orElse();
  }
}

abstract class _ChangeTypeSize implements SheetEvent {
  const factory _ChangeTypeSize(SheetType type, SheetSize size) =
      _$_ChangeTypeSize;

  SheetType get type;
  SheetSize get size;
  _$ChangeTypeSizeCopyWith<_ChangeTypeSize> get copyWith;
}

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'nav_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$NavEventTearOff {
  const _$NavEventTearOff();

// ignore: unused_element
  _ChangeIndex changeIndex({int index}) {
    return _ChangeIndex(
      index: index,
    );
  }

// ignore: unused_element
  _SetBCV setBookChapterVerse({BookChapterVerse bcv}) {
    return _SetBCV(
      bcv: bcv,
    );
  }
}

// ignore: unused_element
const $NavEvent = _$NavEventTearOff();

mixin _$NavEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeIndex(int index),
    @required Result setBookChapterVerse(BookChapterVerse bcv),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeIndex(int index),
    Result setBookChapterVerse(BookChapterVerse bcv),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeIndex(_ChangeIndex value),
    @required Result setBookChapterVerse(_SetBCV value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeIndex(_ChangeIndex value),
    Result setBookChapterVerse(_SetBCV value),
    @required Result orElse(),
  });
}

abstract class $NavEventCopyWith<$Res> {
  factory $NavEventCopyWith(NavEvent value, $Res Function(NavEvent) then) =
      _$NavEventCopyWithImpl<$Res>;
}

class _$NavEventCopyWithImpl<$Res> implements $NavEventCopyWith<$Res> {
  _$NavEventCopyWithImpl(this._value, this._then);

  final NavEvent _value;
  // ignore: unused_field
  final $Res Function(NavEvent) _then;
}

abstract class _$ChangeIndexCopyWith<$Res> {
  factory _$ChangeIndexCopyWith(
          _ChangeIndex value, $Res Function(_ChangeIndex) then) =
      __$ChangeIndexCopyWithImpl<$Res>;
  $Res call({int index});
}

class __$ChangeIndexCopyWithImpl<$Res> extends _$NavEventCopyWithImpl<$Res>
    implements _$ChangeIndexCopyWith<$Res> {
  __$ChangeIndexCopyWithImpl(
      _ChangeIndex _value, $Res Function(_ChangeIndex) _then)
      : super(_value, (v) => _then(v as _ChangeIndex));

  @override
  _ChangeIndex get _value => super._value as _ChangeIndex;

  @override
  $Res call({
    Object index = freezed,
  }) {
    return _then(_ChangeIndex(
      index: index == freezed ? _value.index : index as int,
    ));
  }
}

class _$_ChangeIndex implements _ChangeIndex {
  const _$_ChangeIndex({this.index});

  @override
  final int index;

  @override
  String toString() {
    return 'NavEvent.changeIndex(index: $index)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ChangeIndex &&
            (identical(other.index, index) ||
                const DeepCollectionEquality().equals(other.index, index)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(index);

  @override
  _$ChangeIndexCopyWith<_ChangeIndex> get copyWith =>
      __$ChangeIndexCopyWithImpl<_ChangeIndex>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeIndex(int index),
    @required Result setBookChapterVerse(BookChapterVerse bcv),
  }) {
    assert(changeIndex != null);
    assert(setBookChapterVerse != null);
    return changeIndex(index);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeIndex(int index),
    Result setBookChapterVerse(BookChapterVerse bcv),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeIndex != null) {
      return changeIndex(index);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeIndex(_ChangeIndex value),
    @required Result setBookChapterVerse(_SetBCV value),
  }) {
    assert(changeIndex != null);
    assert(setBookChapterVerse != null);
    return changeIndex(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeIndex(_ChangeIndex value),
    Result setBookChapterVerse(_SetBCV value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeIndex != null) {
      return changeIndex(this);
    }
    return orElse();
  }
}

abstract class _ChangeIndex implements NavEvent {
  const factory _ChangeIndex({int index}) = _$_ChangeIndex;

  int get index;
  _$ChangeIndexCopyWith<_ChangeIndex> get copyWith;
}

abstract class _$SetBCVCopyWith<$Res> {
  factory _$SetBCVCopyWith(_SetBCV value, $Res Function(_SetBCV) then) =
      __$SetBCVCopyWithImpl<$Res>;
  $Res call({BookChapterVerse bcv});
}

class __$SetBCVCopyWithImpl<$Res> extends _$NavEventCopyWithImpl<$Res>
    implements _$SetBCVCopyWith<$Res> {
  __$SetBCVCopyWithImpl(_SetBCV _value, $Res Function(_SetBCV) _then)
      : super(_value, (v) => _then(v as _SetBCV));

  @override
  _SetBCV get _value => super._value as _SetBCV;

  @override
  $Res call({
    Object bcv = freezed,
  }) {
    return _then(_SetBCV(
      bcv: bcv == freezed ? _value.bcv : bcv as BookChapterVerse,
    ));
  }
}

class _$_SetBCV implements _SetBCV {
  const _$_SetBCV({this.bcv});

  @override
  final BookChapterVerse bcv;

  @override
  String toString() {
    return 'NavEvent.setBookChapterVerse(bcv: $bcv)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SetBCV &&
            (identical(other.bcv, bcv) ||
                const DeepCollectionEquality().equals(other.bcv, bcv)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(bcv);

  @override
  _$SetBCVCopyWith<_SetBCV> get copyWith =>
      __$SetBCVCopyWithImpl<_SetBCV>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeIndex(int index),
    @required Result setBookChapterVerse(BookChapterVerse bcv),
  }) {
    assert(changeIndex != null);
    assert(setBookChapterVerse != null);
    return setBookChapterVerse(bcv);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeIndex(int index),
    Result setBookChapterVerse(BookChapterVerse bcv),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setBookChapterVerse != null) {
      return setBookChapterVerse(bcv);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeIndex(_ChangeIndex value),
    @required Result setBookChapterVerse(_SetBCV value),
  }) {
    assert(changeIndex != null);
    assert(setBookChapterVerse != null);
    return setBookChapterVerse(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeIndex(_ChangeIndex value),
    Result setBookChapterVerse(_SetBCV value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setBookChapterVerse != null) {
      return setBookChapterVerse(this);
    }
    return orElse();
  }
}

abstract class _SetBCV implements NavEvent {
  const factory _SetBCV({BookChapterVerse bcv}) = _$_SetBCV;

  BookChapterVerse get bcv;
  _$SetBCVCopyWith<_SetBCV> get copyWith;
}

class _$NavStateTearOff {
  const _$NavStateTearOff();

// ignore: unused_element
  _NavState call({int tabIndex, BookChapterVerse bcv}) {
    return _NavState(
      tabIndex: tabIndex,
      bcv: bcv,
    );
  }
}

// ignore: unused_element
const $NavState = _$NavStateTearOff();

mixin _$NavState {
  int get tabIndex;
  BookChapterVerse get bcv;

  $NavStateCopyWith<NavState> get copyWith;
}

abstract class $NavStateCopyWith<$Res> {
  factory $NavStateCopyWith(NavState value, $Res Function(NavState) then) =
      _$NavStateCopyWithImpl<$Res>;
  $Res call({int tabIndex, BookChapterVerse bcv});
}

class _$NavStateCopyWithImpl<$Res> implements $NavStateCopyWith<$Res> {
  _$NavStateCopyWithImpl(this._value, this._then);

  final NavState _value;
  // ignore: unused_field
  final $Res Function(NavState) _then;

  @override
  $Res call({
    Object tabIndex = freezed,
    Object bcv = freezed,
  }) {
    return _then(_value.copyWith(
      tabIndex: tabIndex == freezed ? _value.tabIndex : tabIndex as int,
      bcv: bcv == freezed ? _value.bcv : bcv as BookChapterVerse,
    ));
  }
}

abstract class _$NavStateCopyWith<$Res> implements $NavStateCopyWith<$Res> {
  factory _$NavStateCopyWith(_NavState value, $Res Function(_NavState) then) =
      __$NavStateCopyWithImpl<$Res>;
  @override
  $Res call({int tabIndex, BookChapterVerse bcv});
}

class __$NavStateCopyWithImpl<$Res> extends _$NavStateCopyWithImpl<$Res>
    implements _$NavStateCopyWith<$Res> {
  __$NavStateCopyWithImpl(_NavState _value, $Res Function(_NavState) _then)
      : super(_value, (v) => _then(v as _NavState));

  @override
  _NavState get _value => super._value as _NavState;

  @override
  $Res call({
    Object tabIndex = freezed,
    Object bcv = freezed,
  }) {
    return _then(_NavState(
      tabIndex: tabIndex == freezed ? _value.tabIndex : tabIndex as int,
      bcv: bcv == freezed ? _value.bcv : bcv as BookChapterVerse,
    ));
  }
}

class _$_NavState implements _NavState {
  const _$_NavState({this.tabIndex, this.bcv});

  @override
  final int tabIndex;
  @override
  final BookChapterVerse bcv;

  @override
  String toString() {
    return 'NavState(tabIndex: $tabIndex, bcv: $bcv)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _NavState &&
            (identical(other.tabIndex, tabIndex) ||
                const DeepCollectionEquality()
                    .equals(other.tabIndex, tabIndex)) &&
            (identical(other.bcv, bcv) ||
                const DeepCollectionEquality().equals(other.bcv, bcv)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(tabIndex) ^
      const DeepCollectionEquality().hash(bcv);

  @override
  _$NavStateCopyWith<_NavState> get copyWith =>
      __$NavStateCopyWithImpl<_NavState>(this, _$identity);
}

abstract class _NavState implements NavState {
  const factory _NavState({int tabIndex, BookChapterVerse bcv}) = _$_NavState;

  @override
  int get tabIndex;
  @override
  BookChapterVerse get bcv;
  @override
  _$NavStateCopyWith<_NavState> get copyWith;
}

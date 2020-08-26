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
  _ChangeIndex changeTabIndex({int index}) {
    return _ChangeIndex(
      index: index,
    );
  }

// ignore: unused_element
  _SetRef setRef({Reference ref}) {
    return _SetRef(
      ref: ref,
    );
  }

// ignore: unused_element
  _OnSearchChange onSearchChange({String search}) {
    return _OnSearchChange(
      search: search,
    );
  }

// ignore: unused_element
  _LoadHistory loadHistory() {
    return const _LoadHistory();
  }

// ignore: unused_element
  _LoadWordSuggestions loadWordSuggestions({String search}) {
    return _LoadWordSuggestions(
      search: search,
    );
  }

// ignore: unused_element
  _ChangeNavView changeNavView({NavViewState state}) {
    return _ChangeNavView(
      state: state,
    );
  }

// ignore: unused_element
  _OnSearchFinished onSearchFinished() {
    return const _OnSearchFinished();
  }

// ignore: unused_element
  _ChangeNavState changeState(NavState state) {
    return _ChangeNavState(
      state,
    );
  }
}

// ignore: unused_element
const $NavEvent = _$NavEventTearOff();

mixin _$NavEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeTabIndex(int index),
    @required Result setRef(Reference ref),
    @required Result onSearchChange(String search),
    @required Result loadHistory(),
    @required Result loadWordSuggestions(String search),
    @required Result changeNavView(NavViewState state),
    @required Result onSearchFinished(),
    @required Result changeState(NavState state),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeTabIndex(int index),
    Result setRef(Reference ref),
    Result onSearchChange(String search),
    Result loadHistory(),
    Result loadWordSuggestions(String search),
    Result changeNavView(NavViewState state),
    Result onSearchFinished(),
    Result changeState(NavState state),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeTabIndex(_ChangeIndex value),
    @required Result setRef(_SetRef value),
    @required Result onSearchChange(_OnSearchChange value),
    @required Result loadHistory(_LoadHistory value),
    @required Result loadWordSuggestions(_LoadWordSuggestions value),
    @required Result changeNavView(_ChangeNavView value),
    @required Result onSearchFinished(_OnSearchFinished value),
    @required Result changeState(_ChangeNavState value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeTabIndex(_ChangeIndex value),
    Result setRef(_SetRef value),
    Result onSearchChange(_OnSearchChange value),
    Result loadHistory(_LoadHistory value),
    Result loadWordSuggestions(_LoadWordSuggestions value),
    Result changeNavView(_ChangeNavView value),
    Result onSearchFinished(_OnSearchFinished value),
    Result changeState(_ChangeNavState value),
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

class _$_ChangeIndex with DiagnosticableTreeMixin implements _ChangeIndex {
  const _$_ChangeIndex({this.index});

  @override
  final int index;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NavEvent.changeTabIndex(index: $index)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NavEvent.changeTabIndex'))
      ..add(DiagnosticsProperty('index', index));
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
    @required Result changeTabIndex(int index),
    @required Result setRef(Reference ref),
    @required Result onSearchChange(String search),
    @required Result loadHistory(),
    @required Result loadWordSuggestions(String search),
    @required Result changeNavView(NavViewState state),
    @required Result onSearchFinished(),
    @required Result changeState(NavState state),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return changeTabIndex(index);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeTabIndex(int index),
    Result setRef(Reference ref),
    Result onSearchChange(String search),
    Result loadHistory(),
    Result loadWordSuggestions(String search),
    Result changeNavView(NavViewState state),
    Result onSearchFinished(),
    Result changeState(NavState state),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeTabIndex != null) {
      return changeTabIndex(index);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeTabIndex(_ChangeIndex value),
    @required Result setRef(_SetRef value),
    @required Result onSearchChange(_OnSearchChange value),
    @required Result loadHistory(_LoadHistory value),
    @required Result loadWordSuggestions(_LoadWordSuggestions value),
    @required Result changeNavView(_ChangeNavView value),
    @required Result onSearchFinished(_OnSearchFinished value),
    @required Result changeState(_ChangeNavState value),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return changeTabIndex(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeTabIndex(_ChangeIndex value),
    Result setRef(_SetRef value),
    Result onSearchChange(_OnSearchChange value),
    Result loadHistory(_LoadHistory value),
    Result loadWordSuggestions(_LoadWordSuggestions value),
    Result changeNavView(_ChangeNavView value),
    Result onSearchFinished(_OnSearchFinished value),
    Result changeState(_ChangeNavState value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeTabIndex != null) {
      return changeTabIndex(this);
    }
    return orElse();
  }
}

abstract class _ChangeIndex implements NavEvent {
  const factory _ChangeIndex({int index}) = _$_ChangeIndex;

  int get index;
  _$ChangeIndexCopyWith<_ChangeIndex> get copyWith;
}

abstract class _$SetRefCopyWith<$Res> {
  factory _$SetRefCopyWith(_SetRef value, $Res Function(_SetRef) then) =
      __$SetRefCopyWithImpl<$Res>;
  $Res call({Reference ref});
}

class __$SetRefCopyWithImpl<$Res> extends _$NavEventCopyWithImpl<$Res>
    implements _$SetRefCopyWith<$Res> {
  __$SetRefCopyWithImpl(_SetRef _value, $Res Function(_SetRef) _then)
      : super(_value, (v) => _then(v as _SetRef));

  @override
  _SetRef get _value => super._value as _SetRef;

  @override
  $Res call({
    Object ref = freezed,
  }) {
    return _then(_SetRef(
      ref: ref == freezed ? _value.ref : ref as Reference,
    ));
  }
}

class _$_SetRef with DiagnosticableTreeMixin implements _SetRef {
  const _$_SetRef({this.ref});

  @override
  final Reference ref;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NavEvent.setRef(ref: $ref)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NavEvent.setRef'))
      ..add(DiagnosticsProperty('ref', ref));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SetRef &&
            (identical(other.ref, ref) ||
                const DeepCollectionEquality().equals(other.ref, ref)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(ref);

  @override
  _$SetRefCopyWith<_SetRef> get copyWith =>
      __$SetRefCopyWithImpl<_SetRef>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeTabIndex(int index),
    @required Result setRef(Reference ref),
    @required Result onSearchChange(String search),
    @required Result loadHistory(),
    @required Result loadWordSuggestions(String search),
    @required Result changeNavView(NavViewState state),
    @required Result onSearchFinished(),
    @required Result changeState(NavState state),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return setRef(ref);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeTabIndex(int index),
    Result setRef(Reference ref),
    Result onSearchChange(String search),
    Result loadHistory(),
    Result loadWordSuggestions(String search),
    Result changeNavView(NavViewState state),
    Result onSearchFinished(),
    Result changeState(NavState state),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setRef != null) {
      return setRef(ref);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeTabIndex(_ChangeIndex value),
    @required Result setRef(_SetRef value),
    @required Result onSearchChange(_OnSearchChange value),
    @required Result loadHistory(_LoadHistory value),
    @required Result loadWordSuggestions(_LoadWordSuggestions value),
    @required Result changeNavView(_ChangeNavView value),
    @required Result onSearchFinished(_OnSearchFinished value),
    @required Result changeState(_ChangeNavState value),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return setRef(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeTabIndex(_ChangeIndex value),
    Result setRef(_SetRef value),
    Result onSearchChange(_OnSearchChange value),
    Result loadHistory(_LoadHistory value),
    Result loadWordSuggestions(_LoadWordSuggestions value),
    Result changeNavView(_ChangeNavView value),
    Result onSearchFinished(_OnSearchFinished value),
    Result changeState(_ChangeNavState value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (setRef != null) {
      return setRef(this);
    }
    return orElse();
  }
}

abstract class _SetRef implements NavEvent {
  const factory _SetRef({Reference ref}) = _$_SetRef;

  Reference get ref;
  _$SetRefCopyWith<_SetRef> get copyWith;
}

abstract class _$OnSearchChangeCopyWith<$Res> {
  factory _$OnSearchChangeCopyWith(
          _OnSearchChange value, $Res Function(_OnSearchChange) then) =
      __$OnSearchChangeCopyWithImpl<$Res>;
  $Res call({String search});
}

class __$OnSearchChangeCopyWithImpl<$Res> extends _$NavEventCopyWithImpl<$Res>
    implements _$OnSearchChangeCopyWith<$Res> {
  __$OnSearchChangeCopyWithImpl(
      _OnSearchChange _value, $Res Function(_OnSearchChange) _then)
      : super(_value, (v) => _then(v as _OnSearchChange));

  @override
  _OnSearchChange get _value => super._value as _OnSearchChange;

  @override
  $Res call({
    Object search = freezed,
  }) {
    return _then(_OnSearchChange(
      search: search == freezed ? _value.search : search as String,
    ));
  }
}

class _$_OnSearchChange
    with DiagnosticableTreeMixin
    implements _OnSearchChange {
  const _$_OnSearchChange({this.search});

  @override
  final String search;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NavEvent.onSearchChange(search: $search)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NavEvent.onSearchChange'))
      ..add(DiagnosticsProperty('search', search));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _OnSearchChange &&
            (identical(other.search, search) ||
                const DeepCollectionEquality().equals(other.search, search)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(search);

  @override
  _$OnSearchChangeCopyWith<_OnSearchChange> get copyWith =>
      __$OnSearchChangeCopyWithImpl<_OnSearchChange>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeTabIndex(int index),
    @required Result setRef(Reference ref),
    @required Result onSearchChange(String search),
    @required Result loadHistory(),
    @required Result loadWordSuggestions(String search),
    @required Result changeNavView(NavViewState state),
    @required Result onSearchFinished(),
    @required Result changeState(NavState state),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return onSearchChange(search);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeTabIndex(int index),
    Result setRef(Reference ref),
    Result onSearchChange(String search),
    Result loadHistory(),
    Result loadWordSuggestions(String search),
    Result changeNavView(NavViewState state),
    Result onSearchFinished(),
    Result changeState(NavState state),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (onSearchChange != null) {
      return onSearchChange(search);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeTabIndex(_ChangeIndex value),
    @required Result setRef(_SetRef value),
    @required Result onSearchChange(_OnSearchChange value),
    @required Result loadHistory(_LoadHistory value),
    @required Result loadWordSuggestions(_LoadWordSuggestions value),
    @required Result changeNavView(_ChangeNavView value),
    @required Result onSearchFinished(_OnSearchFinished value),
    @required Result changeState(_ChangeNavState value),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return onSearchChange(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeTabIndex(_ChangeIndex value),
    Result setRef(_SetRef value),
    Result onSearchChange(_OnSearchChange value),
    Result loadHistory(_LoadHistory value),
    Result loadWordSuggestions(_LoadWordSuggestions value),
    Result changeNavView(_ChangeNavView value),
    Result onSearchFinished(_OnSearchFinished value),
    Result changeState(_ChangeNavState value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (onSearchChange != null) {
      return onSearchChange(this);
    }
    return orElse();
  }
}

abstract class _OnSearchChange implements NavEvent {
  const factory _OnSearchChange({String search}) = _$_OnSearchChange;

  String get search;
  _$OnSearchChangeCopyWith<_OnSearchChange> get copyWith;
}

abstract class _$LoadHistoryCopyWith<$Res> {
  factory _$LoadHistoryCopyWith(
          _LoadHistory value, $Res Function(_LoadHistory) then) =
      __$LoadHistoryCopyWithImpl<$Res>;
}

class __$LoadHistoryCopyWithImpl<$Res> extends _$NavEventCopyWithImpl<$Res>
    implements _$LoadHistoryCopyWith<$Res> {
  __$LoadHistoryCopyWithImpl(
      _LoadHistory _value, $Res Function(_LoadHistory) _then)
      : super(_value, (v) => _then(v as _LoadHistory));

  @override
  _LoadHistory get _value => super._value as _LoadHistory;
}

class _$_LoadHistory with DiagnosticableTreeMixin implements _LoadHistory {
  const _$_LoadHistory();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NavEvent.loadHistory()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'NavEvent.loadHistory'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _LoadHistory);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeTabIndex(int index),
    @required Result setRef(Reference ref),
    @required Result onSearchChange(String search),
    @required Result loadHistory(),
    @required Result loadWordSuggestions(String search),
    @required Result changeNavView(NavViewState state),
    @required Result onSearchFinished(),
    @required Result changeState(NavState state),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return loadHistory();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeTabIndex(int index),
    Result setRef(Reference ref),
    Result onSearchChange(String search),
    Result loadHistory(),
    Result loadWordSuggestions(String search),
    Result changeNavView(NavViewState state),
    Result onSearchFinished(),
    Result changeState(NavState state),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (loadHistory != null) {
      return loadHistory();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeTabIndex(_ChangeIndex value),
    @required Result setRef(_SetRef value),
    @required Result onSearchChange(_OnSearchChange value),
    @required Result loadHistory(_LoadHistory value),
    @required Result loadWordSuggestions(_LoadWordSuggestions value),
    @required Result changeNavView(_ChangeNavView value),
    @required Result onSearchFinished(_OnSearchFinished value),
    @required Result changeState(_ChangeNavState value),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return loadHistory(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeTabIndex(_ChangeIndex value),
    Result setRef(_SetRef value),
    Result onSearchChange(_OnSearchChange value),
    Result loadHistory(_LoadHistory value),
    Result loadWordSuggestions(_LoadWordSuggestions value),
    Result changeNavView(_ChangeNavView value),
    Result onSearchFinished(_OnSearchFinished value),
    Result changeState(_ChangeNavState value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (loadHistory != null) {
      return loadHistory(this);
    }
    return orElse();
  }
}

abstract class _LoadHistory implements NavEvent {
  const factory _LoadHistory() = _$_LoadHistory;
}

abstract class _$LoadWordSuggestionsCopyWith<$Res> {
  factory _$LoadWordSuggestionsCopyWith(_LoadWordSuggestions value,
          $Res Function(_LoadWordSuggestions) then) =
      __$LoadWordSuggestionsCopyWithImpl<$Res>;
  $Res call({String search});
}

class __$LoadWordSuggestionsCopyWithImpl<$Res>
    extends _$NavEventCopyWithImpl<$Res>
    implements _$LoadWordSuggestionsCopyWith<$Res> {
  __$LoadWordSuggestionsCopyWithImpl(
      _LoadWordSuggestions _value, $Res Function(_LoadWordSuggestions) _then)
      : super(_value, (v) => _then(v as _LoadWordSuggestions));

  @override
  _LoadWordSuggestions get _value => super._value as _LoadWordSuggestions;

  @override
  $Res call({
    Object search = freezed,
  }) {
    return _then(_LoadWordSuggestions(
      search: search == freezed ? _value.search : search as String,
    ));
  }
}

class _$_LoadWordSuggestions
    with DiagnosticableTreeMixin
    implements _LoadWordSuggestions {
  const _$_LoadWordSuggestions({this.search});

  @override
  final String search;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NavEvent.loadWordSuggestions(search: $search)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NavEvent.loadWordSuggestions'))
      ..add(DiagnosticsProperty('search', search));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _LoadWordSuggestions &&
            (identical(other.search, search) ||
                const DeepCollectionEquality().equals(other.search, search)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(search);

  @override
  _$LoadWordSuggestionsCopyWith<_LoadWordSuggestions> get copyWith =>
      __$LoadWordSuggestionsCopyWithImpl<_LoadWordSuggestions>(
          this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeTabIndex(int index),
    @required Result setRef(Reference ref),
    @required Result onSearchChange(String search),
    @required Result loadHistory(),
    @required Result loadWordSuggestions(String search),
    @required Result changeNavView(NavViewState state),
    @required Result onSearchFinished(),
    @required Result changeState(NavState state),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return loadWordSuggestions(search);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeTabIndex(int index),
    Result setRef(Reference ref),
    Result onSearchChange(String search),
    Result loadHistory(),
    Result loadWordSuggestions(String search),
    Result changeNavView(NavViewState state),
    Result onSearchFinished(),
    Result changeState(NavState state),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (loadWordSuggestions != null) {
      return loadWordSuggestions(search);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeTabIndex(_ChangeIndex value),
    @required Result setRef(_SetRef value),
    @required Result onSearchChange(_OnSearchChange value),
    @required Result loadHistory(_LoadHistory value),
    @required Result loadWordSuggestions(_LoadWordSuggestions value),
    @required Result changeNavView(_ChangeNavView value),
    @required Result onSearchFinished(_OnSearchFinished value),
    @required Result changeState(_ChangeNavState value),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return loadWordSuggestions(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeTabIndex(_ChangeIndex value),
    Result setRef(_SetRef value),
    Result onSearchChange(_OnSearchChange value),
    Result loadHistory(_LoadHistory value),
    Result loadWordSuggestions(_LoadWordSuggestions value),
    Result changeNavView(_ChangeNavView value),
    Result onSearchFinished(_OnSearchFinished value),
    Result changeState(_ChangeNavState value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (loadWordSuggestions != null) {
      return loadWordSuggestions(this);
    }
    return orElse();
  }
}

abstract class _LoadWordSuggestions implements NavEvent {
  const factory _LoadWordSuggestions({String search}) = _$_LoadWordSuggestions;

  String get search;
  _$LoadWordSuggestionsCopyWith<_LoadWordSuggestions> get copyWith;
}

abstract class _$ChangeNavViewCopyWith<$Res> {
  factory _$ChangeNavViewCopyWith(
          _ChangeNavView value, $Res Function(_ChangeNavView) then) =
      __$ChangeNavViewCopyWithImpl<$Res>;
  $Res call({NavViewState state});
}

class __$ChangeNavViewCopyWithImpl<$Res> extends _$NavEventCopyWithImpl<$Res>
    implements _$ChangeNavViewCopyWith<$Res> {
  __$ChangeNavViewCopyWithImpl(
      _ChangeNavView _value, $Res Function(_ChangeNavView) _then)
      : super(_value, (v) => _then(v as _ChangeNavView));

  @override
  _ChangeNavView get _value => super._value as _ChangeNavView;

  @override
  $Res call({
    Object state = freezed,
  }) {
    return _then(_ChangeNavView(
      state: state == freezed ? _value.state : state as NavViewState,
    ));
  }
}

class _$_ChangeNavView with DiagnosticableTreeMixin implements _ChangeNavView {
  const _$_ChangeNavView({this.state});

  @override
  final NavViewState state;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NavEvent.changeNavView(state: $state)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NavEvent.changeNavView'))
      ..add(DiagnosticsProperty('state', state));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ChangeNavView &&
            (identical(other.state, state) ||
                const DeepCollectionEquality().equals(other.state, state)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(state);

  @override
  _$ChangeNavViewCopyWith<_ChangeNavView> get copyWith =>
      __$ChangeNavViewCopyWithImpl<_ChangeNavView>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeTabIndex(int index),
    @required Result setRef(Reference ref),
    @required Result onSearchChange(String search),
    @required Result loadHistory(),
    @required Result loadWordSuggestions(String search),
    @required Result changeNavView(NavViewState state),
    @required Result onSearchFinished(),
    @required Result changeState(NavState state),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return changeNavView(state);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeTabIndex(int index),
    Result setRef(Reference ref),
    Result onSearchChange(String search),
    Result loadHistory(),
    Result loadWordSuggestions(String search),
    Result changeNavView(NavViewState state),
    Result onSearchFinished(),
    Result changeState(NavState state),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeNavView != null) {
      return changeNavView(state);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeTabIndex(_ChangeIndex value),
    @required Result setRef(_SetRef value),
    @required Result onSearchChange(_OnSearchChange value),
    @required Result loadHistory(_LoadHistory value),
    @required Result loadWordSuggestions(_LoadWordSuggestions value),
    @required Result changeNavView(_ChangeNavView value),
    @required Result onSearchFinished(_OnSearchFinished value),
    @required Result changeState(_ChangeNavState value),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return changeNavView(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeTabIndex(_ChangeIndex value),
    Result setRef(_SetRef value),
    Result onSearchChange(_OnSearchChange value),
    Result loadHistory(_LoadHistory value),
    Result loadWordSuggestions(_LoadWordSuggestions value),
    Result changeNavView(_ChangeNavView value),
    Result onSearchFinished(_OnSearchFinished value),
    Result changeState(_ChangeNavState value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeNavView != null) {
      return changeNavView(this);
    }
    return orElse();
  }
}

abstract class _ChangeNavView implements NavEvent {
  const factory _ChangeNavView({NavViewState state}) = _$_ChangeNavView;

  NavViewState get state;
  _$ChangeNavViewCopyWith<_ChangeNavView> get copyWith;
}

abstract class _$OnSearchFinishedCopyWith<$Res> {
  factory _$OnSearchFinishedCopyWith(
          _OnSearchFinished value, $Res Function(_OnSearchFinished) then) =
      __$OnSearchFinishedCopyWithImpl<$Res>;
}

class __$OnSearchFinishedCopyWithImpl<$Res> extends _$NavEventCopyWithImpl<$Res>
    implements _$OnSearchFinishedCopyWith<$Res> {
  __$OnSearchFinishedCopyWithImpl(
      _OnSearchFinished _value, $Res Function(_OnSearchFinished) _then)
      : super(_value, (v) => _then(v as _OnSearchFinished));

  @override
  _OnSearchFinished get _value => super._value as _OnSearchFinished;
}

class _$_OnSearchFinished
    with DiagnosticableTreeMixin
    implements _OnSearchFinished {
  const _$_OnSearchFinished();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NavEvent.onSearchFinished()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'NavEvent.onSearchFinished'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _OnSearchFinished);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeTabIndex(int index),
    @required Result setRef(Reference ref),
    @required Result onSearchChange(String search),
    @required Result loadHistory(),
    @required Result loadWordSuggestions(String search),
    @required Result changeNavView(NavViewState state),
    @required Result onSearchFinished(),
    @required Result changeState(NavState state),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return onSearchFinished();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeTabIndex(int index),
    Result setRef(Reference ref),
    Result onSearchChange(String search),
    Result loadHistory(),
    Result loadWordSuggestions(String search),
    Result changeNavView(NavViewState state),
    Result onSearchFinished(),
    Result changeState(NavState state),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (onSearchFinished != null) {
      return onSearchFinished();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeTabIndex(_ChangeIndex value),
    @required Result setRef(_SetRef value),
    @required Result onSearchChange(_OnSearchChange value),
    @required Result loadHistory(_LoadHistory value),
    @required Result loadWordSuggestions(_LoadWordSuggestions value),
    @required Result changeNavView(_ChangeNavView value),
    @required Result onSearchFinished(_OnSearchFinished value),
    @required Result changeState(_ChangeNavState value),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return onSearchFinished(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeTabIndex(_ChangeIndex value),
    Result setRef(_SetRef value),
    Result onSearchChange(_OnSearchChange value),
    Result loadHistory(_LoadHistory value),
    Result loadWordSuggestions(_LoadWordSuggestions value),
    Result changeNavView(_ChangeNavView value),
    Result onSearchFinished(_OnSearchFinished value),
    Result changeState(_ChangeNavState value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (onSearchFinished != null) {
      return onSearchFinished(this);
    }
    return orElse();
  }
}

abstract class _OnSearchFinished implements NavEvent {
  const factory _OnSearchFinished() = _$_OnSearchFinished;
}

abstract class _$ChangeNavStateCopyWith<$Res> {
  factory _$ChangeNavStateCopyWith(
          _ChangeNavState value, $Res Function(_ChangeNavState) then) =
      __$ChangeNavStateCopyWithImpl<$Res>;
  $Res call({NavState state});

  $NavStateCopyWith<$Res> get state;
}

class __$ChangeNavStateCopyWithImpl<$Res> extends _$NavEventCopyWithImpl<$Res>
    implements _$ChangeNavStateCopyWith<$Res> {
  __$ChangeNavStateCopyWithImpl(
      _ChangeNavState _value, $Res Function(_ChangeNavState) _then)
      : super(_value, (v) => _then(v as _ChangeNavState));

  @override
  _ChangeNavState get _value => super._value as _ChangeNavState;

  @override
  $Res call({
    Object state = freezed,
  }) {
    return _then(_ChangeNavState(
      state == freezed ? _value.state : state as NavState,
    ));
  }

  @override
  $NavStateCopyWith<$Res> get state {
    if (_value.state == null) {
      return null;
    }
    return $NavStateCopyWith<$Res>(_value.state, (value) {
      return _then(_value.copyWith(state: value));
    });
  }
}

class _$_ChangeNavState
    with DiagnosticableTreeMixin
    implements _ChangeNavState {
  const _$_ChangeNavState(this.state) : assert(state != null);

  @override
  final NavState state;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NavEvent.changeState(state: $state)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NavEvent.changeState'))
      ..add(DiagnosticsProperty('state', state));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ChangeNavState &&
            (identical(other.state, state) ||
                const DeepCollectionEquality().equals(other.state, state)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(state);

  @override
  _$ChangeNavStateCopyWith<_ChangeNavState> get copyWith =>
      __$ChangeNavStateCopyWithImpl<_ChangeNavState>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result changeTabIndex(int index),
    @required Result setRef(Reference ref),
    @required Result onSearchChange(String search),
    @required Result loadHistory(),
    @required Result loadWordSuggestions(String search),
    @required Result changeNavView(NavViewState state),
    @required Result onSearchFinished(),
    @required Result changeState(NavState state),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return changeState(state);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result changeTabIndex(int index),
    Result setRef(Reference ref),
    Result onSearchChange(String search),
    Result loadHistory(),
    Result loadWordSuggestions(String search),
    Result changeNavView(NavViewState state),
    Result onSearchFinished(),
    Result changeState(NavState state),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeState != null) {
      return changeState(state);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result changeTabIndex(_ChangeIndex value),
    @required Result setRef(_SetRef value),
    @required Result onSearchChange(_OnSearchChange value),
    @required Result loadHistory(_LoadHistory value),
    @required Result loadWordSuggestions(_LoadWordSuggestions value),
    @required Result changeNavView(_ChangeNavView value),
    @required Result onSearchFinished(_OnSearchFinished value),
    @required Result changeState(_ChangeNavState value),
  }) {
    assert(changeTabIndex != null);
    assert(setRef != null);
    assert(onSearchChange != null);
    assert(loadHistory != null);
    assert(loadWordSuggestions != null);
    assert(changeNavView != null);
    assert(onSearchFinished != null);
    assert(changeState != null);
    return changeState(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result changeTabIndex(_ChangeIndex value),
    Result setRef(_SetRef value),
    Result onSearchChange(_OnSearchChange value),
    Result loadHistory(_LoadHistory value),
    Result loadWordSuggestions(_LoadWordSuggestions value),
    Result changeNavView(_ChangeNavView value),
    Result onSearchFinished(_OnSearchFinished value),
    Result changeState(_ChangeNavState value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (changeState != null) {
      return changeState(this);
    }
    return orElse();
  }
}

abstract class _ChangeNavState implements NavEvent {
  const factory _ChangeNavState(NavState state) = _$_ChangeNavState;

  NavState get state;
  _$ChangeNavStateCopyWith<_ChangeNavState> get copyWith;
}

class _$NavStateTearOff {
  const _$NavStateTearOff();

// ignore: unused_element
  _NavState call(
      {NavViewState navViewState,
      int tabIndex,
      Reference ref,
      String search,
      List<int> bookSuggestions,
      List<String> wordSuggestions,
      List<Reference> history}) {
    return _NavState(
      navViewState: navViewState,
      tabIndex: tabIndex,
      ref: ref,
      search: search,
      bookSuggestions: bookSuggestions,
      wordSuggestions: wordSuggestions,
      history: history,
    );
  }
}

// ignore: unused_element
const $NavState = _$NavStateTearOff();

mixin _$NavState {
  NavViewState get navViewState;
  int get tabIndex;
  Reference get ref;
  String get search;
  List<int> get bookSuggestions;
  List<String> get wordSuggestions;
  List<Reference> get history;

  $NavStateCopyWith<NavState> get copyWith;
}

abstract class $NavStateCopyWith<$Res> {
  factory $NavStateCopyWith(NavState value, $Res Function(NavState) then) =
      _$NavStateCopyWithImpl<$Res>;
  $Res call(
      {NavViewState navViewState,
      int tabIndex,
      Reference ref,
      String search,
      List<int> bookSuggestions,
      List<String> wordSuggestions,
      List<Reference> history});
}

class _$NavStateCopyWithImpl<$Res> implements $NavStateCopyWith<$Res> {
  _$NavStateCopyWithImpl(this._value, this._then);

  final NavState _value;
  // ignore: unused_field
  final $Res Function(NavState) _then;

  @override
  $Res call({
    Object navViewState = freezed,
    Object tabIndex = freezed,
    Object ref = freezed,
    Object search = freezed,
    Object bookSuggestions = freezed,
    Object wordSuggestions = freezed,
    Object history = freezed,
  }) {
    return _then(_value.copyWith(
      navViewState: navViewState == freezed
          ? _value.navViewState
          : navViewState as NavViewState,
      tabIndex: tabIndex == freezed ? _value.tabIndex : tabIndex as int,
      ref: ref == freezed ? _value.ref : ref as Reference,
      search: search == freezed ? _value.search : search as String,
      bookSuggestions: bookSuggestions == freezed
          ? _value.bookSuggestions
          : bookSuggestions as List<int>,
      wordSuggestions: wordSuggestions == freezed
          ? _value.wordSuggestions
          : wordSuggestions as List<String>,
      history: history == freezed ? _value.history : history as List<Reference>,
    ));
  }
}

abstract class _$NavStateCopyWith<$Res> implements $NavStateCopyWith<$Res> {
  factory _$NavStateCopyWith(_NavState value, $Res Function(_NavState) then) =
      __$NavStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {NavViewState navViewState,
      int tabIndex,
      Reference ref,
      String search,
      List<int> bookSuggestions,
      List<String> wordSuggestions,
      List<Reference> history});
}

class __$NavStateCopyWithImpl<$Res> extends _$NavStateCopyWithImpl<$Res>
    implements _$NavStateCopyWith<$Res> {
  __$NavStateCopyWithImpl(_NavState _value, $Res Function(_NavState) _then)
      : super(_value, (v) => _then(v as _NavState));

  @override
  _NavState get _value => super._value as _NavState;

  @override
  $Res call({
    Object navViewState = freezed,
    Object tabIndex = freezed,
    Object ref = freezed,
    Object search = freezed,
    Object bookSuggestions = freezed,
    Object wordSuggestions = freezed,
    Object history = freezed,
  }) {
    return _then(_NavState(
      navViewState: navViewState == freezed
          ? _value.navViewState
          : navViewState as NavViewState,
      tabIndex: tabIndex == freezed ? _value.tabIndex : tabIndex as int,
      ref: ref == freezed ? _value.ref : ref as Reference,
      search: search == freezed ? _value.search : search as String,
      bookSuggestions: bookSuggestions == freezed
          ? _value.bookSuggestions
          : bookSuggestions as List<int>,
      wordSuggestions: wordSuggestions == freezed
          ? _value.wordSuggestions
          : wordSuggestions as List<String>,
      history: history == freezed ? _value.history : history as List<Reference>,
    ));
  }
}

class _$_NavState with DiagnosticableTreeMixin implements _NavState {
  const _$_NavState(
      {this.navViewState,
      this.tabIndex,
      this.ref,
      this.search,
      this.bookSuggestions,
      this.wordSuggestions,
      this.history});

  @override
  final NavViewState navViewState;
  @override
  final int tabIndex;
  @override
  final Reference ref;
  @override
  final String search;
  @override
  final List<int> bookSuggestions;
  @override
  final List<String> wordSuggestions;
  @override
  final List<Reference> history;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NavState(navViewState: $navViewState, tabIndex: $tabIndex, ref: $ref, search: $search, bookSuggestions: $bookSuggestions, wordSuggestions: $wordSuggestions, history: $history)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'NavState'))
      ..add(DiagnosticsProperty('navViewState', navViewState))
      ..add(DiagnosticsProperty('tabIndex', tabIndex))
      ..add(DiagnosticsProperty('ref', ref))
      ..add(DiagnosticsProperty('search', search))
      ..add(DiagnosticsProperty('bookSuggestions', bookSuggestions))
      ..add(DiagnosticsProperty('wordSuggestions', wordSuggestions))
      ..add(DiagnosticsProperty('history', history));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _NavState &&
            (identical(other.navViewState, navViewState) ||
                const DeepCollectionEquality()
                    .equals(other.navViewState, navViewState)) &&
            (identical(other.tabIndex, tabIndex) ||
                const DeepCollectionEquality()
                    .equals(other.tabIndex, tabIndex)) &&
            (identical(other.ref, ref) ||
                const DeepCollectionEquality().equals(other.ref, ref)) &&
            (identical(other.search, search) ||
                const DeepCollectionEquality().equals(other.search, search)) &&
            (identical(other.bookSuggestions, bookSuggestions) ||
                const DeepCollectionEquality()
                    .equals(other.bookSuggestions, bookSuggestions)) &&
            (identical(other.wordSuggestions, wordSuggestions) ||
                const DeepCollectionEquality()
                    .equals(other.wordSuggestions, wordSuggestions)) &&
            (identical(other.history, history) ||
                const DeepCollectionEquality().equals(other.history, history)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(navViewState) ^
      const DeepCollectionEquality().hash(tabIndex) ^
      const DeepCollectionEquality().hash(ref) ^
      const DeepCollectionEquality().hash(search) ^
      const DeepCollectionEquality().hash(bookSuggestions) ^
      const DeepCollectionEquality().hash(wordSuggestions) ^
      const DeepCollectionEquality().hash(history);

  @override
  _$NavStateCopyWith<_NavState> get copyWith =>
      __$NavStateCopyWithImpl<_NavState>(this, _$identity);
}

abstract class _NavState implements NavState {
  const factory _NavState(
      {NavViewState navViewState,
      int tabIndex,
      Reference ref,
      String search,
      List<int> bookSuggestions,
      List<String> wordSuggestions,
      List<Reference> history}) = _$_NavState;

  @override
  NavViewState get navViewState;
  @override
  int get tabIndex;
  @override
  Reference get ref;
  @override
  String get search;
  @override
  List<int> get bookSuggestions;
  @override
  List<String> get wordSuggestions;
  @override
  List<Reference> get history;
  @override
  _$NavStateCopyWith<_NavState> get copyWith;
}

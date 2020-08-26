// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'search_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$SearchEventTearOff {
  const _$SearchEventTearOff();

// ignore: unused_element
  _Requested request({String search, List<int> translations}) {
    return _Requested(
      search: search,
      translations: translations,
    );
  }

// ignore: unused_element
  _SelectionMode selectionModeToggle() {
    return const _SelectionMode();
  }

// ignore: unused_element
  _SelectResult selectResult({SearchResult searchResult}) {
    return _SelectResult(
      searchResult: searchResult,
    );
  }
}

// ignore: unused_element
const $SearchEvent = _$SearchEventTearOff();

mixin _$SearchEvent {
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result request(String search, List<int> translations),
    @required Result selectionModeToggle(),
    @required Result selectResult(SearchResult searchResult),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result request(String search, List<int> translations),
    Result selectionModeToggle(),
    Result selectResult(SearchResult searchResult),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result request(_Requested value),
    @required Result selectionModeToggle(_SelectionMode value),
    @required Result selectResult(_SelectResult value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result request(_Requested value),
    Result selectionModeToggle(_SelectionMode value),
    Result selectResult(_SelectResult value),
    @required Result orElse(),
  });
}

abstract class $SearchEventCopyWith<$Res> {
  factory $SearchEventCopyWith(
          SearchEvent value, $Res Function(SearchEvent) then) =
      _$SearchEventCopyWithImpl<$Res>;
}

class _$SearchEventCopyWithImpl<$Res> implements $SearchEventCopyWith<$Res> {
  _$SearchEventCopyWithImpl(this._value, this._then);

  final SearchEvent _value;
  // ignore: unused_field
  final $Res Function(SearchEvent) _then;
}

abstract class _$RequestedCopyWith<$Res> {
  factory _$RequestedCopyWith(
          _Requested value, $Res Function(_Requested) then) =
      __$RequestedCopyWithImpl<$Res>;
  $Res call({String search, List<int> translations});
}

class __$RequestedCopyWithImpl<$Res> extends _$SearchEventCopyWithImpl<$Res>
    implements _$RequestedCopyWith<$Res> {
  __$RequestedCopyWithImpl(_Requested _value, $Res Function(_Requested) _then)
      : super(_value, (v) => _then(v as _Requested));

  @override
  _Requested get _value => super._value as _Requested;

  @override
  $Res call({
    Object search = freezed,
    Object translations = freezed,
  }) {
    return _then(_Requested(
      search: search == freezed ? _value.search : search as String,
      translations: translations == freezed
          ? _value.translations
          : translations as List<int>,
    ));
  }
}

class _$_Requested with DiagnosticableTreeMixin implements _Requested {
  const _$_Requested({this.search, this.translations});

  @override
  final String search;
  @override
  final List<int> translations;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchEvent.request(search: $search, translations: $translations)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SearchEvent.request'))
      ..add(DiagnosticsProperty('search', search))
      ..add(DiagnosticsProperty('translations', translations));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Requested &&
            (identical(other.search, search) ||
                const DeepCollectionEquality().equals(other.search, search)) &&
            (identical(other.translations, translations) ||
                const DeepCollectionEquality()
                    .equals(other.translations, translations)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(search) ^
      const DeepCollectionEquality().hash(translations);

  @override
  _$RequestedCopyWith<_Requested> get copyWith =>
      __$RequestedCopyWithImpl<_Requested>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result request(String search, List<int> translations),
    @required Result selectionModeToggle(),
    @required Result selectResult(SearchResult searchResult),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(selectResult != null);
    return request(search, translations);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result request(String search, List<int> translations),
    Result selectionModeToggle(),
    Result selectResult(SearchResult searchResult),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (request != null) {
      return request(search, translations);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result request(_Requested value),
    @required Result selectionModeToggle(_SelectionMode value),
    @required Result selectResult(_SelectResult value),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(selectResult != null);
    return request(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result request(_Requested value),
    Result selectionModeToggle(_SelectionMode value),
    Result selectResult(_SelectResult value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (request != null) {
      return request(this);
    }
    return orElse();
  }
}

abstract class _Requested implements SearchEvent {
  const factory _Requested({String search, List<int> translations}) =
      _$_Requested;

  String get search;
  List<int> get translations;
  _$RequestedCopyWith<_Requested> get copyWith;
}

abstract class _$SelectionModeCopyWith<$Res> {
  factory _$SelectionModeCopyWith(
          _SelectionMode value, $Res Function(_SelectionMode) then) =
      __$SelectionModeCopyWithImpl<$Res>;
}

class __$SelectionModeCopyWithImpl<$Res> extends _$SearchEventCopyWithImpl<$Res>
    implements _$SelectionModeCopyWith<$Res> {
  __$SelectionModeCopyWithImpl(
      _SelectionMode _value, $Res Function(_SelectionMode) _then)
      : super(_value, (v) => _then(v as _SelectionMode));

  @override
  _SelectionMode get _value => super._value as _SelectionMode;
}

class _$_SelectionMode with DiagnosticableTreeMixin implements _SelectionMode {
  const _$_SelectionMode();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchEvent.selectionModeToggle()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SearchEvent.selectionModeToggle'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _SelectionMode);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result request(String search, List<int> translations),
    @required Result selectionModeToggle(),
    @required Result selectResult(SearchResult searchResult),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(selectResult != null);
    return selectionModeToggle();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result request(String search, List<int> translations),
    Result selectionModeToggle(),
    Result selectResult(SearchResult searchResult),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (selectionModeToggle != null) {
      return selectionModeToggle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result request(_Requested value),
    @required Result selectionModeToggle(_SelectionMode value),
    @required Result selectResult(_SelectResult value),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(selectResult != null);
    return selectionModeToggle(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result request(_Requested value),
    Result selectionModeToggle(_SelectionMode value),
    Result selectResult(_SelectResult value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (selectionModeToggle != null) {
      return selectionModeToggle(this);
    }
    return orElse();
  }
}

abstract class _SelectionMode implements SearchEvent {
  const factory _SelectionMode() = _$_SelectionMode;
}

abstract class _$SelectResultCopyWith<$Res> {
  factory _$SelectResultCopyWith(
          _SelectResult value, $Res Function(_SelectResult) then) =
      __$SelectResultCopyWithImpl<$Res>;
  $Res call({SearchResult searchResult});
}

class __$SelectResultCopyWithImpl<$Res> extends _$SearchEventCopyWithImpl<$Res>
    implements _$SelectResultCopyWith<$Res> {
  __$SelectResultCopyWithImpl(
      _SelectResult _value, $Res Function(_SelectResult) _then)
      : super(_value, (v) => _then(v as _SelectResult));

  @override
  _SelectResult get _value => super._value as _SelectResult;

  @override
  $Res call({
    Object searchResult = freezed,
  }) {
    return _then(_SelectResult(
      searchResult: searchResult == freezed
          ? _value.searchResult
          : searchResult as SearchResult,
    ));
  }
}

class _$_SelectResult with DiagnosticableTreeMixin implements _SelectResult {
  const _$_SelectResult({this.searchResult});

  @override
  final SearchResult searchResult;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchEvent.selectResult(searchResult: $searchResult)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SearchEvent.selectResult'))
      ..add(DiagnosticsProperty('searchResult', searchResult));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SelectResult &&
            (identical(other.searchResult, searchResult) ||
                const DeepCollectionEquality()
                    .equals(other.searchResult, searchResult)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(searchResult);

  @override
  _$SelectResultCopyWith<_SelectResult> get copyWith =>
      __$SelectResultCopyWithImpl<_SelectResult>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result request(String search, List<int> translations),
    @required Result selectionModeToggle(),
    @required Result selectResult(SearchResult searchResult),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(selectResult != null);
    return selectResult(searchResult);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result request(String search, List<int> translations),
    Result selectionModeToggle(),
    Result selectResult(SearchResult searchResult),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (selectResult != null) {
      return selectResult(searchResult);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result request(_Requested value),
    @required Result selectionModeToggle(_SelectionMode value),
    @required Result selectResult(_SelectResult value),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(selectResult != null);
    return selectResult(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result request(_Requested value),
    Result selectionModeToggle(_SelectionMode value),
    Result selectResult(_SelectResult value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (selectResult != null) {
      return selectResult(this);
    }
    return orElse();
  }
}

abstract class _SelectResult implements SearchEvent {
  const factory _SelectResult({SearchResult searchResult}) = _$_SelectResult;

  SearchResult get searchResult;
  _$SelectResultCopyWith<_SelectResult> get copyWith;
}

class _$SearchStateTearOff {
  const _$SearchStateTearOff();

// ignore: unused_element
  _SearchState call(
      {String search,
      List<SearchResult> searchResults,
      Map<String, bool> selected,
      List<int> defaultTranslations,
      bool loading,
      bool error,
      bool selectionMode}) {
    return _SearchState(
      search: search,
      searchResults: searchResults,
      selected: selected,
      defaultTranslations: defaultTranslations,
      loading: loading,
      error: error,
      selectionMode: selectionMode,
    );
  }
}

// ignore: unused_element
const $SearchState = _$SearchStateTearOff();

mixin _$SearchState {
  String get search;
  List<SearchResult> get searchResults;
  Map<String, bool> get selected;
  List<int> get defaultTranslations;
  bool get loading;
  bool get error;
  bool get selectionMode;

  $SearchStateCopyWith<SearchState> get copyWith;
}

abstract class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
          SearchState value, $Res Function(SearchState) then) =
      _$SearchStateCopyWithImpl<$Res>;
  $Res call(
      {String search,
      List<SearchResult> searchResults,
      Map<String, bool> selected,
      List<int> defaultTranslations,
      bool loading,
      bool error,
      bool selectionMode});
}

class _$SearchStateCopyWithImpl<$Res> implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._value, this._then);

  final SearchState _value;
  // ignore: unused_field
  final $Res Function(SearchState) _then;

  @override
  $Res call({
    Object search = freezed,
    Object searchResults = freezed,
    Object selected = freezed,
    Object defaultTranslations = freezed,
    Object loading = freezed,
    Object error = freezed,
    Object selectionMode = freezed,
  }) {
    return _then(_value.copyWith(
      search: search == freezed ? _value.search : search as String,
      searchResults: searchResults == freezed
          ? _value.searchResults
          : searchResults as List<SearchResult>,
      selected:
          selected == freezed ? _value.selected : selected as Map<String, bool>,
      defaultTranslations: defaultTranslations == freezed
          ? _value.defaultTranslations
          : defaultTranslations as List<int>,
      loading: loading == freezed ? _value.loading : loading as bool,
      error: error == freezed ? _value.error : error as bool,
      selectionMode: selectionMode == freezed
          ? _value.selectionMode
          : selectionMode as bool,
    ));
  }
}

abstract class _$SearchStateCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$SearchStateCopyWith(
          _SearchState value, $Res Function(_SearchState) then) =
      __$SearchStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {String search,
      List<SearchResult> searchResults,
      Map<String, bool> selected,
      List<int> defaultTranslations,
      bool loading,
      bool error,
      bool selectionMode});
}

class __$SearchStateCopyWithImpl<$Res> extends _$SearchStateCopyWithImpl<$Res>
    implements _$SearchStateCopyWith<$Res> {
  __$SearchStateCopyWithImpl(
      _SearchState _value, $Res Function(_SearchState) _then)
      : super(_value, (v) => _then(v as _SearchState));

  @override
  _SearchState get _value => super._value as _SearchState;

  @override
  $Res call({
    Object search = freezed,
    Object searchResults = freezed,
    Object selected = freezed,
    Object defaultTranslations = freezed,
    Object loading = freezed,
    Object error = freezed,
    Object selectionMode = freezed,
  }) {
    return _then(_SearchState(
      search: search == freezed ? _value.search : search as String,
      searchResults: searchResults == freezed
          ? _value.searchResults
          : searchResults as List<SearchResult>,
      selected:
          selected == freezed ? _value.selected : selected as Map<String, bool>,
      defaultTranslations: defaultTranslations == freezed
          ? _value.defaultTranslations
          : defaultTranslations as List<int>,
      loading: loading == freezed ? _value.loading : loading as bool,
      error: error == freezed ? _value.error : error as bool,
      selectionMode: selectionMode == freezed
          ? _value.selectionMode
          : selectionMode as bool,
    ));
  }
}

class _$_SearchState with DiagnosticableTreeMixin implements _SearchState {
  const _$_SearchState(
      {this.search,
      this.searchResults,
      this.selected,
      this.defaultTranslations,
      this.loading,
      this.error,
      this.selectionMode});

  @override
  final String search;
  @override
  final List<SearchResult> searchResults;
  @override
  final Map<String, bool> selected;
  @override
  final List<int> defaultTranslations;
  @override
  final bool loading;
  @override
  final bool error;
  @override
  final bool selectionMode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchState(search: $search, searchResults: $searchResults, selected: $selected, defaultTranslations: $defaultTranslations, loading: $loading, error: $error, selectionMode: $selectionMode)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SearchState'))
      ..add(DiagnosticsProperty('search', search))
      ..add(DiagnosticsProperty('searchResults', searchResults))
      ..add(DiagnosticsProperty('selected', selected))
      ..add(DiagnosticsProperty('defaultTranslations', defaultTranslations))
      ..add(DiagnosticsProperty('loading', loading))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('selectionMode', selectionMode));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SearchState &&
            (identical(other.search, search) ||
                const DeepCollectionEquality().equals(other.search, search)) &&
            (identical(other.searchResults, searchResults) ||
                const DeepCollectionEquality()
                    .equals(other.searchResults, searchResults)) &&
            (identical(other.selected, selected) ||
                const DeepCollectionEquality()
                    .equals(other.selected, selected)) &&
            (identical(other.defaultTranslations, defaultTranslations) ||
                const DeepCollectionEquality()
                    .equals(other.defaultTranslations, defaultTranslations)) &&
            (identical(other.loading, loading) ||
                const DeepCollectionEquality()
                    .equals(other.loading, loading)) &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)) &&
            (identical(other.selectionMode, selectionMode) ||
                const DeepCollectionEquality()
                    .equals(other.selectionMode, selectionMode)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(search) ^
      const DeepCollectionEquality().hash(searchResults) ^
      const DeepCollectionEquality().hash(selected) ^
      const DeepCollectionEquality().hash(defaultTranslations) ^
      const DeepCollectionEquality().hash(loading) ^
      const DeepCollectionEquality().hash(error) ^
      const DeepCollectionEquality().hash(selectionMode);

  @override
  _$SearchStateCopyWith<_SearchState> get copyWith =>
      __$SearchStateCopyWithImpl<_SearchState>(this, _$identity);
}

abstract class _SearchState implements SearchState {
  const factory _SearchState(
      {String search,
      List<SearchResult> searchResults,
      Map<String, bool> selected,
      List<int> defaultTranslations,
      bool loading,
      bool error,
      bool selectionMode}) = _$_SearchState;

  @override
  String get search;
  @override
  List<SearchResult> get searchResults;
  @override
  Map<String, bool> get selected;
  @override
  List<int> get defaultTranslations;
  @override
  bool get loading;
  @override
  bool get error;
  @override
  bool get selectionMode;
  @override
  _$SearchStateCopyWith<_SearchState> get copyWith;
}

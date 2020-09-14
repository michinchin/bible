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
  _ModifySearchResult modifySearchResult({SearchResultInfo searchResult}) {
    return _ModifySearchResult(
      searchResult: searchResult,
    );
  }

// ignore: unused_element
  _FilterBooks filterBooks(List<int> excludedBooks) {
    return _FilterBooks(
      excludedBooks,
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
    @required Result modifySearchResult(SearchResultInfo searchResult),
    @required Result filterBooks(List<int> excludedBooks),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result request(String search, List<int> translations),
    Result selectionModeToggle(),
    Result modifySearchResult(SearchResultInfo searchResult),
    Result filterBooks(List<int> excludedBooks),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result request(_Requested value),
    @required Result selectionModeToggle(_SelectionMode value),
    @required Result modifySearchResult(_ModifySearchResult value),
    @required Result filterBooks(_FilterBooks value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result request(_Requested value),
    Result selectionModeToggle(_SelectionMode value),
    Result modifySearchResult(_ModifySearchResult value),
    Result filterBooks(_FilterBooks value),
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
    @required Result modifySearchResult(SearchResultInfo searchResult),
    @required Result filterBooks(List<int> excludedBooks),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(modifySearchResult != null);
    assert(filterBooks != null);
    return request(search, translations);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result request(String search, List<int> translations),
    Result selectionModeToggle(),
    Result modifySearchResult(SearchResultInfo searchResult),
    Result filterBooks(List<int> excludedBooks),
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
    @required Result modifySearchResult(_ModifySearchResult value),
    @required Result filterBooks(_FilterBooks value),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(modifySearchResult != null);
    assert(filterBooks != null);
    return request(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result request(_Requested value),
    Result selectionModeToggle(_SelectionMode value),
    Result modifySearchResult(_ModifySearchResult value),
    Result filterBooks(_FilterBooks value),
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
    @required Result modifySearchResult(SearchResultInfo searchResult),
    @required Result filterBooks(List<int> excludedBooks),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(modifySearchResult != null);
    assert(filterBooks != null);
    return selectionModeToggle();
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result request(String search, List<int> translations),
    Result selectionModeToggle(),
    Result modifySearchResult(SearchResultInfo searchResult),
    Result filterBooks(List<int> excludedBooks),
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
    @required Result modifySearchResult(_ModifySearchResult value),
    @required Result filterBooks(_FilterBooks value),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(modifySearchResult != null);
    assert(filterBooks != null);
    return selectionModeToggle(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result request(_Requested value),
    Result selectionModeToggle(_SelectionMode value),
    Result modifySearchResult(_ModifySearchResult value),
    Result filterBooks(_FilterBooks value),
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

abstract class _$ModifySearchResultCopyWith<$Res> {
  factory _$ModifySearchResultCopyWith(
          _ModifySearchResult value, $Res Function(_ModifySearchResult) then) =
      __$ModifySearchResultCopyWithImpl<$Res>;
  $Res call({SearchResultInfo searchResult});

  $SearchResultInfoCopyWith<$Res> get searchResult;
}

class __$ModifySearchResultCopyWithImpl<$Res>
    extends _$SearchEventCopyWithImpl<$Res>
    implements _$ModifySearchResultCopyWith<$Res> {
  __$ModifySearchResultCopyWithImpl(
      _ModifySearchResult _value, $Res Function(_ModifySearchResult) _then)
      : super(_value, (v) => _then(v as _ModifySearchResult));

  @override
  _ModifySearchResult get _value => super._value as _ModifySearchResult;

  @override
  $Res call({
    Object searchResult = freezed,
  }) {
    return _then(_ModifySearchResult(
      searchResult: searchResult == freezed
          ? _value.searchResult
          : searchResult as SearchResultInfo,
    ));
  }

  @override
  $SearchResultInfoCopyWith<$Res> get searchResult {
    if (_value.searchResult == null) {
      return null;
    }
    return $SearchResultInfoCopyWith<$Res>(_value.searchResult, (value) {
      return _then(_value.copyWith(searchResult: value));
    });
  }
}

class _$_ModifySearchResult
    with DiagnosticableTreeMixin
    implements _ModifySearchResult {
  const _$_ModifySearchResult({this.searchResult});

  @override
  final SearchResultInfo searchResult;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchEvent.modifySearchResult(searchResult: $searchResult)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SearchEvent.modifySearchResult'))
      ..add(DiagnosticsProperty('searchResult', searchResult));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _ModifySearchResult &&
            (identical(other.searchResult, searchResult) ||
                const DeepCollectionEquality()
                    .equals(other.searchResult, searchResult)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(searchResult);

  @override
  _$ModifySearchResultCopyWith<_ModifySearchResult> get copyWith =>
      __$ModifySearchResultCopyWithImpl<_ModifySearchResult>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result request(String search, List<int> translations),
    @required Result selectionModeToggle(),
    @required Result modifySearchResult(SearchResultInfo searchResult),
    @required Result filterBooks(List<int> excludedBooks),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(modifySearchResult != null);
    assert(filterBooks != null);
    return modifySearchResult(searchResult);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result request(String search, List<int> translations),
    Result selectionModeToggle(),
    Result modifySearchResult(SearchResultInfo searchResult),
    Result filterBooks(List<int> excludedBooks),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (modifySearchResult != null) {
      return modifySearchResult(searchResult);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result request(_Requested value),
    @required Result selectionModeToggle(_SelectionMode value),
    @required Result modifySearchResult(_ModifySearchResult value),
    @required Result filterBooks(_FilterBooks value),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(modifySearchResult != null);
    assert(filterBooks != null);
    return modifySearchResult(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result request(_Requested value),
    Result selectionModeToggle(_SelectionMode value),
    Result modifySearchResult(_ModifySearchResult value),
    Result filterBooks(_FilterBooks value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (modifySearchResult != null) {
      return modifySearchResult(this);
    }
    return orElse();
  }
}

abstract class _ModifySearchResult implements SearchEvent {
  const factory _ModifySearchResult({SearchResultInfo searchResult}) =
      _$_ModifySearchResult;

  SearchResultInfo get searchResult;
  _$ModifySearchResultCopyWith<_ModifySearchResult> get copyWith;
}

abstract class _$FilterBooksCopyWith<$Res> {
  factory _$FilterBooksCopyWith(
          _FilterBooks value, $Res Function(_FilterBooks) then) =
      __$FilterBooksCopyWithImpl<$Res>;
  $Res call({List<int> excludedBooks});
}

class __$FilterBooksCopyWithImpl<$Res> extends _$SearchEventCopyWithImpl<$Res>
    implements _$FilterBooksCopyWith<$Res> {
  __$FilterBooksCopyWithImpl(
      _FilterBooks _value, $Res Function(_FilterBooks) _then)
      : super(_value, (v) => _then(v as _FilterBooks));

  @override
  _FilterBooks get _value => super._value as _FilterBooks;

  @override
  $Res call({
    Object excludedBooks = freezed,
  }) {
    return _then(_FilterBooks(
      excludedBooks == freezed
          ? _value.excludedBooks
          : excludedBooks as List<int>,
    ));
  }
}

class _$_FilterBooks with DiagnosticableTreeMixin implements _FilterBooks {
  const _$_FilterBooks(this.excludedBooks) : assert(excludedBooks != null);

  @override
  final List<int> excludedBooks;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchEvent.filterBooks(excludedBooks: $excludedBooks)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SearchEvent.filterBooks'))
      ..add(DiagnosticsProperty('excludedBooks', excludedBooks));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _FilterBooks &&
            (identical(other.excludedBooks, excludedBooks) ||
                const DeepCollectionEquality()
                    .equals(other.excludedBooks, excludedBooks)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(excludedBooks);

  @override
  _$FilterBooksCopyWith<_FilterBooks> get copyWith =>
      __$FilterBooksCopyWithImpl<_FilterBooks>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result request(String search, List<int> translations),
    @required Result selectionModeToggle(),
    @required Result modifySearchResult(SearchResultInfo searchResult),
    @required Result filterBooks(List<int> excludedBooks),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(modifySearchResult != null);
    assert(filterBooks != null);
    return filterBooks(excludedBooks);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result request(String search, List<int> translations),
    Result selectionModeToggle(),
    Result modifySearchResult(SearchResultInfo searchResult),
    Result filterBooks(List<int> excludedBooks),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (filterBooks != null) {
      return filterBooks(excludedBooks);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result request(_Requested value),
    @required Result selectionModeToggle(_SelectionMode value),
    @required Result modifySearchResult(_ModifySearchResult value),
    @required Result filterBooks(_FilterBooks value),
  }) {
    assert(request != null);
    assert(selectionModeToggle != null);
    assert(modifySearchResult != null);
    assert(filterBooks != null);
    return filterBooks(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result request(_Requested value),
    Result selectionModeToggle(_SelectionMode value),
    Result modifySearchResult(_ModifySearchResult value),
    Result filterBooks(_FilterBooks value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (filterBooks != null) {
      return filterBooks(this);
    }
    return orElse();
  }
}

abstract class _FilterBooks implements SearchEvent {
  const factory _FilterBooks(List<int> excludedBooks) = _$_FilterBooks;

  List<int> get excludedBooks;
  _$FilterBooksCopyWith<_FilterBooks> get copyWith;
}

class _$SearchStateTearOff {
  const _$SearchStateTearOff();

// ignore: unused_element
  _SearchState call(
      {String search,
      List<SearchResultInfo> searchResults,
      List<SearchResultInfo> filteredResults,
      List<int> filteredTranslations,
      List<int> excludedBooks,
      bool loading,
      bool error,
      bool selectionMode}) {
    return _SearchState(
      search: search,
      searchResults: searchResults,
      filteredResults: filteredResults,
      filteredTranslations: filteredTranslations,
      excludedBooks: excludedBooks,
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
  List<SearchResultInfo> get searchResults;
  List<SearchResultInfo> get filteredResults;
  List<int> get filteredTranslations;
  List<int> get excludedBooks;
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
      List<SearchResultInfo> searchResults,
      List<SearchResultInfo> filteredResults,
      List<int> filteredTranslations,
      List<int> excludedBooks,
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
    Object filteredResults = freezed,
    Object filteredTranslations = freezed,
    Object excludedBooks = freezed,
    Object loading = freezed,
    Object error = freezed,
    Object selectionMode = freezed,
  }) {
    return _then(_value.copyWith(
      search: search == freezed ? _value.search : search as String,
      searchResults: searchResults == freezed
          ? _value.searchResults
          : searchResults as List<SearchResultInfo>,
      filteredResults: filteredResults == freezed
          ? _value.filteredResults
          : filteredResults as List<SearchResultInfo>,
      filteredTranslations: filteredTranslations == freezed
          ? _value.filteredTranslations
          : filteredTranslations as List<int>,
      excludedBooks: excludedBooks == freezed
          ? _value.excludedBooks
          : excludedBooks as List<int>,
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
      List<SearchResultInfo> searchResults,
      List<SearchResultInfo> filteredResults,
      List<int> filteredTranslations,
      List<int> excludedBooks,
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
    Object filteredResults = freezed,
    Object filteredTranslations = freezed,
    Object excludedBooks = freezed,
    Object loading = freezed,
    Object error = freezed,
    Object selectionMode = freezed,
  }) {
    return _then(_SearchState(
      search: search == freezed ? _value.search : search as String,
      searchResults: searchResults == freezed
          ? _value.searchResults
          : searchResults as List<SearchResultInfo>,
      filteredResults: filteredResults == freezed
          ? _value.filteredResults
          : filteredResults as List<SearchResultInfo>,
      filteredTranslations: filteredTranslations == freezed
          ? _value.filteredTranslations
          : filteredTranslations as List<int>,
      excludedBooks: excludedBooks == freezed
          ? _value.excludedBooks
          : excludedBooks as List<int>,
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
      this.filteredResults,
      this.filteredTranslations,
      this.excludedBooks,
      this.loading,
      this.error,
      this.selectionMode});

  @override
  final String search;
  @override
  final List<SearchResultInfo> searchResults;
  @override
  final List<SearchResultInfo> filteredResults;
  @override
  final List<int> filteredTranslations;
  @override
  final List<int> excludedBooks;
  @override
  final bool loading;
  @override
  final bool error;
  @override
  final bool selectionMode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchState(search: $search, searchResults: $searchResults, filteredResults: $filteredResults, filteredTranslations: $filteredTranslations, excludedBooks: $excludedBooks, loading: $loading, error: $error, selectionMode: $selectionMode)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SearchState'))
      ..add(DiagnosticsProperty('search', search))
      ..add(DiagnosticsProperty('searchResults', searchResults))
      ..add(DiagnosticsProperty('filteredResults', filteredResults))
      ..add(DiagnosticsProperty('filteredTranslations', filteredTranslations))
      ..add(DiagnosticsProperty('excludedBooks', excludedBooks))
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
            (identical(other.filteredResults, filteredResults) ||
                const DeepCollectionEquality()
                    .equals(other.filteredResults, filteredResults)) &&
            (identical(other.filteredTranslations, filteredTranslations) ||
                const DeepCollectionEquality().equals(
                    other.filteredTranslations, filteredTranslations)) &&
            (identical(other.excludedBooks, excludedBooks) ||
                const DeepCollectionEquality()
                    .equals(other.excludedBooks, excludedBooks)) &&
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
      const DeepCollectionEquality().hash(filteredResults) ^
      const DeepCollectionEquality().hash(filteredTranslations) ^
      const DeepCollectionEquality().hash(excludedBooks) ^
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
      List<SearchResultInfo> searchResults,
      List<SearchResultInfo> filteredResults,
      List<int> filteredTranslations,
      List<int> excludedBooks,
      bool loading,
      bool error,
      bool selectionMode}) = _$_SearchState;

  @override
  String get search;
  @override
  List<SearchResultInfo> get searchResults;
  @override
  List<SearchResultInfo> get filteredResults;
  @override
  List<int> get filteredTranslations;
  @override
  List<int> get excludedBooks;
  @override
  bool get loading;
  @override
  bool get error;
  @override
  bool get selectionMode;
  @override
  _$SearchStateCopyWith<_SearchState> get copyWith;
}

class _$SearchResultInfoTearOff {
  const _$SearchResultInfoTearOff();

// ignore: unused_element
  _SearchResultInfo call(SearchResult searchResult,
      {bool contextExpanded = false,
      int currentVerseIndex = 0,
      bool selected = false,
      bool expanded = false,
      Map<int, Context> contextMap = const <int, Context>{}}) {
    return _SearchResultInfo(
      searchResult,
      contextExpanded: contextExpanded,
      currentVerseIndex: currentVerseIndex,
      selected: selected,
      expanded: expanded,
      contextMap: contextMap,
    );
  }
}

// ignore: unused_element
const $SearchResultInfo = _$SearchResultInfoTearOff();

mixin _$SearchResultInfo {
  SearchResult get searchResult;
  bool get contextExpanded;
  int get currentVerseIndex;
  bool get selected;
  bool get expanded;
  Map<int, Context> get contextMap;

  $SearchResultInfoCopyWith<SearchResultInfo> get copyWith;
}

abstract class $SearchResultInfoCopyWith<$Res> {
  factory $SearchResultInfoCopyWith(
          SearchResultInfo value, $Res Function(SearchResultInfo) then) =
      _$SearchResultInfoCopyWithImpl<$Res>;
  $Res call(
      {SearchResult searchResult,
      bool contextExpanded,
      int currentVerseIndex,
      bool selected,
      bool expanded,
      Map<int, Context> contextMap});
}

class _$SearchResultInfoCopyWithImpl<$Res>
    implements $SearchResultInfoCopyWith<$Res> {
  _$SearchResultInfoCopyWithImpl(this._value, this._then);

  final SearchResultInfo _value;
  // ignore: unused_field
  final $Res Function(SearchResultInfo) _then;

  @override
  $Res call({
    Object searchResult = freezed,
    Object contextExpanded = freezed,
    Object currentVerseIndex = freezed,
    Object selected = freezed,
    Object expanded = freezed,
    Object contextMap = freezed,
  }) {
    return _then(_value.copyWith(
      searchResult: searchResult == freezed
          ? _value.searchResult
          : searchResult as SearchResult,
      contextExpanded: contextExpanded == freezed
          ? _value.contextExpanded
          : contextExpanded as bool,
      currentVerseIndex: currentVerseIndex == freezed
          ? _value.currentVerseIndex
          : currentVerseIndex as int,
      selected: selected == freezed ? _value.selected : selected as bool,
      expanded: expanded == freezed ? _value.expanded : expanded as bool,
      contextMap: contextMap == freezed
          ? _value.contextMap
          : contextMap as Map<int, Context>,
    ));
  }
}

abstract class _$SearchResultInfoCopyWith<$Res>
    implements $SearchResultInfoCopyWith<$Res> {
  factory _$SearchResultInfoCopyWith(
          _SearchResultInfo value, $Res Function(_SearchResultInfo) then) =
      __$SearchResultInfoCopyWithImpl<$Res>;
  @override
  $Res call(
      {SearchResult searchResult,
      bool contextExpanded,
      int currentVerseIndex,
      bool selected,
      bool expanded,
      Map<int, Context> contextMap});
}

class __$SearchResultInfoCopyWithImpl<$Res>
    extends _$SearchResultInfoCopyWithImpl<$Res>
    implements _$SearchResultInfoCopyWith<$Res> {
  __$SearchResultInfoCopyWithImpl(
      _SearchResultInfo _value, $Res Function(_SearchResultInfo) _then)
      : super(_value, (v) => _then(v as _SearchResultInfo));

  @override
  _SearchResultInfo get _value => super._value as _SearchResultInfo;

  @override
  $Res call({
    Object searchResult = freezed,
    Object contextExpanded = freezed,
    Object currentVerseIndex = freezed,
    Object selected = freezed,
    Object expanded = freezed,
    Object contextMap = freezed,
  }) {
    return _then(_SearchResultInfo(
      searchResult == freezed
          ? _value.searchResult
          : searchResult as SearchResult,
      contextExpanded: contextExpanded == freezed
          ? _value.contextExpanded
          : contextExpanded as bool,
      currentVerseIndex: currentVerseIndex == freezed
          ? _value.currentVerseIndex
          : currentVerseIndex as int,
      selected: selected == freezed ? _value.selected : selected as bool,
      expanded: expanded == freezed ? _value.expanded : expanded as bool,
      contextMap: contextMap == freezed
          ? _value.contextMap
          : contextMap as Map<int, Context>,
    ));
  }
}

class _$_SearchResultInfo extends _SearchResultInfo
    with DiagnosticableTreeMixin {
  const _$_SearchResultInfo(this.searchResult,
      {this.contextExpanded = false,
      this.currentVerseIndex = 0,
      this.selected = false,
      this.expanded = false,
      this.contextMap = const <int, Context>{}})
      : assert(searchResult != null),
        assert(contextExpanded != null),
        assert(currentVerseIndex != null),
        assert(selected != null),
        assert(expanded != null),
        assert(contextMap != null),
        super._();

  @override
  final SearchResult searchResult;
  @JsonKey(defaultValue: false)
  @override
  final bool contextExpanded;
  @JsonKey(defaultValue: 0)
  @override
  final int currentVerseIndex;
  @JsonKey(defaultValue: false)
  @override
  final bool selected;
  @JsonKey(defaultValue: false)
  @override
  final bool expanded;
  @JsonKey(defaultValue: const <int, Context>{})
  @override
  final Map<int, Context> contextMap;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchResultInfo(searchResult: $searchResult, contextExpanded: $contextExpanded, currentVerseIndex: $currentVerseIndex, selected: $selected, expanded: $expanded, contextMap: $contextMap)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SearchResultInfo'))
      ..add(DiagnosticsProperty('searchResult', searchResult))
      ..add(DiagnosticsProperty('contextExpanded', contextExpanded))
      ..add(DiagnosticsProperty('currentVerseIndex', currentVerseIndex))
      ..add(DiagnosticsProperty('selected', selected))
      ..add(DiagnosticsProperty('expanded', expanded))
      ..add(DiagnosticsProperty('contextMap', contextMap));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SearchResultInfo &&
            (identical(other.searchResult, searchResult) ||
                const DeepCollectionEquality()
                    .equals(other.searchResult, searchResult)) &&
            (identical(other.contextExpanded, contextExpanded) ||
                const DeepCollectionEquality()
                    .equals(other.contextExpanded, contextExpanded)) &&
            (identical(other.currentVerseIndex, currentVerseIndex) ||
                const DeepCollectionEquality()
                    .equals(other.currentVerseIndex, currentVerseIndex)) &&
            (identical(other.selected, selected) ||
                const DeepCollectionEquality()
                    .equals(other.selected, selected)) &&
            (identical(other.expanded, expanded) ||
                const DeepCollectionEquality()
                    .equals(other.expanded, expanded)) &&
            (identical(other.contextMap, contextMap) ||
                const DeepCollectionEquality()
                    .equals(other.contextMap, contextMap)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(searchResult) ^
      const DeepCollectionEquality().hash(contextExpanded) ^
      const DeepCollectionEquality().hash(currentVerseIndex) ^
      const DeepCollectionEquality().hash(selected) ^
      const DeepCollectionEquality().hash(expanded) ^
      const DeepCollectionEquality().hash(contextMap);

  @override
  _$SearchResultInfoCopyWith<_SearchResultInfo> get copyWith =>
      __$SearchResultInfoCopyWithImpl<_SearchResultInfo>(this, _$identity);
}

abstract class _SearchResultInfo extends SearchResultInfo {
  const _SearchResultInfo._() : super._();
  const factory _SearchResultInfo(SearchResult searchResult,
      {bool contextExpanded,
      int currentVerseIndex,
      bool selected,
      bool expanded,
      Map<int, Context> contextMap}) = _$_SearchResultInfo;

  @override
  SearchResult get searchResult;
  @override
  bool get contextExpanded;
  @override
  int get currentVerseIndex;
  @override
  bool get selected;
  @override
  bool get expanded;
  @override
  Map<int, Context> get contextMap;
  @override
  _$SearchResultInfoCopyWith<_SearchResultInfo> get copyWith;
}

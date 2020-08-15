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
}

// ignore: unused_element
const $SearchEvent = _$SearchEventTearOff();

mixin _$SearchEvent {
  String get search;
  List<int> get translations;

  @optionalTypeArgs
  Result when<Result extends Object>({
    @required Result request(String search, List<int> translations),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result request(String search, List<int> translations),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result request(_Requested value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result request(_Requested value),
    @required Result orElse(),
  });

  $SearchEventCopyWith<SearchEvent> get copyWith;
}

abstract class $SearchEventCopyWith<$Res> {
  factory $SearchEventCopyWith(
          SearchEvent value, $Res Function(SearchEvent) then) =
      _$SearchEventCopyWithImpl<$Res>;
  $Res call({String search, List<int> translations});
}

class _$SearchEventCopyWithImpl<$Res> implements $SearchEventCopyWith<$Res> {
  _$SearchEventCopyWithImpl(this._value, this._then);

  final SearchEvent _value;
  // ignore: unused_field
  final $Res Function(SearchEvent) _then;

  @override
  $Res call({
    Object search = freezed,
    Object translations = freezed,
  }) {
    return _then(_value.copyWith(
      search: search == freezed ? _value.search : search as String,
      translations: translations == freezed
          ? _value.translations
          : translations as List<int>,
    ));
  }
}

abstract class _$RequestedCopyWith<$Res> implements $SearchEventCopyWith<$Res> {
  factory _$RequestedCopyWith(
          _Requested value, $Res Function(_Requested) then) =
      __$RequestedCopyWithImpl<$Res>;
  @override
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
  }) {
    assert(request != null);
    return request(search, translations);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result request(String search, List<int> translations),
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
  }) {
    assert(request != null);
    return request(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result request(_Requested value),
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

  @override
  String get search;
  @override
  List<int> get translations;
  @override
  _$RequestedCopyWith<_Requested> get copyWith;
}

class _$SearchStateTearOff {
  const _$SearchStateTearOff();

// ignore: unused_element
  _SearchState call(
      {String search,
      List<SearchResult> searchResults,
      List<int> defaultTranslations,
      bool loading,
      bool error}) {
    return _SearchState(
      search: search,
      searchResults: searchResults,
      defaultTranslations: defaultTranslations,
      loading: loading,
      error: error,
    );
  }
}

// ignore: unused_element
const $SearchState = _$SearchStateTearOff();

mixin _$SearchState {
  String get search;
  List<SearchResult> get searchResults;
  List<int> get defaultTranslations;
  bool get loading;
  bool get error;

  $SearchStateCopyWith<SearchState> get copyWith;
}

abstract class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
          SearchState value, $Res Function(SearchState) then) =
      _$SearchStateCopyWithImpl<$Res>;
  $Res call(
      {String search,
      List<SearchResult> searchResults,
      List<int> defaultTranslations,
      bool loading,
      bool error});
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
    Object defaultTranslations = freezed,
    Object loading = freezed,
    Object error = freezed,
  }) {
    return _then(_value.copyWith(
      search: search == freezed ? _value.search : search as String,
      searchResults: searchResults == freezed
          ? _value.searchResults
          : searchResults as List<SearchResult>,
      defaultTranslations: defaultTranslations == freezed
          ? _value.defaultTranslations
          : defaultTranslations as List<int>,
      loading: loading == freezed ? _value.loading : loading as bool,
      error: error == freezed ? _value.error : error as bool,
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
      List<int> defaultTranslations,
      bool loading,
      bool error});
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
    Object defaultTranslations = freezed,
    Object loading = freezed,
    Object error = freezed,
  }) {
    return _then(_SearchState(
      search: search == freezed ? _value.search : search as String,
      searchResults: searchResults == freezed
          ? _value.searchResults
          : searchResults as List<SearchResult>,
      defaultTranslations: defaultTranslations == freezed
          ? _value.defaultTranslations
          : defaultTranslations as List<int>,
      loading: loading == freezed ? _value.loading : loading as bool,
      error: error == freezed ? _value.error : error as bool,
    ));
  }
}

class _$_SearchState with DiagnosticableTreeMixin implements _SearchState {
  const _$_SearchState(
      {this.search,
      this.searchResults,
      this.defaultTranslations,
      this.loading,
      this.error});

  @override
  final String search;
  @override
  final List<SearchResult> searchResults;
  @override
  final List<int> defaultTranslations;
  @override
  final bool loading;
  @override
  final bool error;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchState(search: $search, searchResults: $searchResults, defaultTranslations: $defaultTranslations, loading: $loading, error: $error)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SearchState'))
      ..add(DiagnosticsProperty('search', search))
      ..add(DiagnosticsProperty('searchResults', searchResults))
      ..add(DiagnosticsProperty('defaultTranslations', defaultTranslations))
      ..add(DiagnosticsProperty('loading', loading))
      ..add(DiagnosticsProperty('error', error));
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
            (identical(other.defaultTranslations, defaultTranslations) ||
                const DeepCollectionEquality()
                    .equals(other.defaultTranslations, defaultTranslations)) &&
            (identical(other.loading, loading) ||
                const DeepCollectionEquality()
                    .equals(other.loading, loading)) &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(search) ^
      const DeepCollectionEquality().hash(searchResults) ^
      const DeepCollectionEquality().hash(defaultTranslations) ^
      const DeepCollectionEquality().hash(loading) ^
      const DeepCollectionEquality().hash(error);

  @override
  _$SearchStateCopyWith<_SearchState> get copyWith =>
      __$SearchStateCopyWithImpl<_SearchState>(this, _$identity);
}

abstract class _SearchState implements SearchState {
  const factory _SearchState(
      {String search,
      List<SearchResult> searchResults,
      List<int> defaultTranslations,
      bool loading,
      bool error}) = _$_SearchState;

  @override
  String get search;
  @override
  List<SearchResult> get searchResults;
  @override
  List<int> get defaultTranslations;
  @override
  bool get loading;
  @override
  bool get error;
  @override
  _$SearchStateCopyWith<_SearchState> get copyWith;
}

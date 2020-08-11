import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tec_util/tec_util.dart' as tec;

import '../../models/search/search_result.dart';

part 'search_bloc.freezed.dart';

@freezed
abstract class SearchEvent with _$SearchEvent {
  const factory SearchEvent.request({String search, List<int> translations}) = _Requested;
}

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    String search,
    List<SearchResult> searchResults,
    List<int> defaultTranslations,
    bool loading,
    bool error,
  }) = _SearchState;
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  @override
  SearchState get initialState => const SearchState(
      search: '', searchResults: [], defaultTranslations: [], loading: false, error: false);

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is _Requested) {
      yield state.copyWith(loading: true);
      tec.dmPrint('Loading search: ${event.search}');
      try {
        final res = await SearchResults.fetch(
            words: event.search, translationIds: event.translations.join('|'));
        tec.dmPrint('Completed search "${event.search}" with ${res.length} result(s)');
        yield state.copyWith(
            searchResults: res,
            loading: false,
            search: event.search,
            defaultTranslations: event.translations);
      } catch (_) {
        tec.dmPrint('Error with search "${event.search}"');
        yield state.copyWith(
            error: true,
            loading: false,
            search: event.search,
            defaultTranslations: event.translations);
      }
    }
  }
}

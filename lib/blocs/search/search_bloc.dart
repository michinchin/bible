import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../models/search/search_result.dart';

part 'search_bloc.freezed.dart';

@freezed
abstract class SearchEvent with _$SearchEvent {
  const factory SearchEvent.request({String search, List<int> translations}) = _Requested;
  const factory SearchEvent.selectionModeToggle() = _SelectionMode;
  // const factory SearchEvent.selectResult({SearchResult searchResult}) = _SelectResult;
}

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    String search,
    List<SearchResult> searchResults,
    // List<int> selected,
    List<int> defaultTranslations,
    bool loading,
    bool error,
    bool selectionMode,
  }) = _SearchState;
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  @override
  SearchState get initialState => const SearchState(
      search: '',
      searchResults: [],
      // selected: [],
      defaultTranslations: [],
      loading: false,
      error: false,
      selectionMode: false);

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is _Requested) {
      yield state.copyWith(loading: true);
      tec.dmPrint('Loading search: ${event.search}');
      try {
        final res = await SearchResults.fetch(
            words: event.search, translationIds: event.translations.join('|'));
        // if (res.isNotEmpty) {
        //   await _saveToSearchHistory(event.search);
        // }
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
    } else if (event is _SelectResult) {
      final ref = event.searchResult.ref;
      // final selected = Map<String, bool>.from(state.selected);
      // if (selected.containsKey(ref)) {
      //   selected[ref] = !selected[ref];
      // } else {
      //   selected[ref] = true;
      // }
      // tec.dmPrint('${(selected[ref] ? 'Selected' : 'Deselected')}' ' $ref');
      // yield state.copyWith(selected: selected);
    } else if (event is _SelectionMode) {
      tec.dmPrint('Selection Mode in search: ${!state.selectionMode ? 'ON' : 'OFF'}');
      if (!state.selectionMode) {
        yield state.copyWith(selectionMode: !state.selectionMode);
      } else {
        yield state.copyWith(selectionMode: !state.selectionMode, selected: []);
      }
    }
  }

  // TODO(abby): save to search history
  // Future<void> _saveToSearchHistory(String search) async {
  //   final item = UserItemHelper.searchHistoryItem(search);
  //   await AppSettings.shared.userAccount.userDb.saveItem(item);
  // }
}

class SearchResultInfo {
  final bool contextExpanded;
  final int currentVerseIndex;
  const SearchResultInfo({this.contextExpanded, this.currentVerseIndex});
}

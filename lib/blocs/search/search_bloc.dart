import 'dart:async';

import 'package:async/async.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../models/search/context.dart';
import '../../models/search/search_history_item.dart';
import '../../models/search/search_result.dart';
import '../../models/user_item_helper.dart';

part 'search_bloc.freezed.dart';

@freezed
abstract class SearchEvent with _$SearchEvent {
  const factory SearchEvent.request({String search, List<int> translations}) = _Requested;
  const factory SearchEvent.selectionModeToggle() = _SelectionMode;
  const factory SearchEvent.modifySearchResult({SearchResultInfo searchResult}) =
      _ModifySearchResult;
}

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    String search,
    List<SearchResultInfo> searchResults,
    List<int> filteredTranslations,
    List<int> filteredBooks,
    bool loading,
    bool error,
    bool selectionMode,
  }) = _SearchState;
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  CancelableOperation<List<SearchResult>> searchOperation;
  int scrollIndex = 0;

  SearchBloc()
      : super(const SearchState(
          search: '',
          searchResults: [],
          filteredBooks: [],
          filteredTranslations: [],
          loading: false,
          error: false,
          selectionMode: false,
        ));

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is _Requested) {
      // make sure any still-pending prior request never gets processed
      await searchOperation?.cancel();
      yield state.copyWith(loading: true);
      tec.dmPrint('Loading search: ${event.search}');
      try {
        final translations = event.translations.join('|');
        final futureRes = SearchResults.fetch(words: event.search, translationIds: translations);
        searchOperation = CancelableOperation<List<SearchResult>>.fromFuture(futureRes,
            onCancel: () => tec.dmPrint('Cancelled search query'));
        final res = await searchOperation.value;
        tec.dmPrint('Completed search "${event.search}" with ${res.length} result(s)');
        await _saveToSearchHistory(event.search, translations);
        yield state.copyWith(
            searchResults: res.map((r) => SearchResultInfo(r)).toList(),
            loading: false,
            error: false,
            search: event.search,
            filteredTranslations: event.translations);
      } catch (_) {
        tec.dmPrint('Error with search "${event.search}"');
        yield state.copyWith(
            error: true,
            loading: false,
            search: event.search,
            filteredTranslations: event.translations);
      }
    } else if (event is _ModifySearchResult) {
      yield _modifySearchResult(event.searchResult);
    } else if (event is _SelectionMode) {
      tec.dmPrint('Selection Mode in search: ${!state.selectionMode ? 'ON' : 'OFF'}');
      if (!state.selectionMode) {
        yield state.copyWith(selectionMode: !state.selectionMode);
      } else {
        // clear selected
        final results = state.searchResults.map((r) => r.copyWith(selected: false)).toList();
        yield state.copyWith(selectionMode: !state.selectionMode, searchResults: results);
      }
    }
  }

  SearchState _modifySearchResult(SearchResultInfo info) {
    final res = List<SearchResultInfo>.from(state.searchResults);
    final index = res.indexWhere((i) => i.searchResult == info.searchResult);
    if (index != -1) {
      res[index] = info;
      return state.copyWith(searchResults: res);
    }
    return state;
  }

  Future<void> _saveToSearchHistory(String search, String translations) async {
    // check to make sure u haven't saved it already
    final s = SearchHistoryItem(
        search: search,
        volumesFiltered: translations,
        booksFiltered: state.filteredBooks.join('|'),
        index: scrollIndex,
        modified: DateTime.now());
    await UserItemHelper.saveSearchHistoryItem(s);
  }
}

@freezed
abstract class SearchResultInfo with _$SearchResultInfo {
  const factory SearchResultInfo(SearchResult searchResult,
      {@Default(false) bool contextExpanded,
      @Default(0) int currentVerseIndex,
      @Default(false) bool selected,
      @Default(false) bool expanded,
      @Default(<int, Context>{}) Map<int, Context> contextMap}) = _SearchResultInfo;
  const SearchResultInfo._();

  String get shareText => '$label\n$currentText';
  String get label => contextExpanded && contextMap[currentVerseIndex] != null
      ? '${searchResult.ref.split(':')[0]}:'
          '${contextMap[currentVerseIndex].initialVerse}-${contextMap[currentVerseIndex].finalVerse}'
          ' ${searchResult.verses[currentVerseIndex].a}'
      : '${searchResult.ref} ${searchResult.verses[currentVerseIndex].a}';
  String get currentText => contextExpanded && contextMap[currentVerseIndex] != null
      ? contextMap[currentVerseIndex].text
      : searchResult.verses[currentVerseIndex].verseContent;
}

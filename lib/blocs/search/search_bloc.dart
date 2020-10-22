import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
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
  const factory SearchEvent.filterBooks(List<int> excludedBooks) = _FilterBooks;
  const factory SearchEvent.setScrollIndex(int scrollIndex) = _SetScrollIndex;
}

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    String search,
    List<SearchResultInfo> searchResults,
    List<SearchResultInfo> filteredResults,
    List<int> filteredTranslations,
    List<int> excludedBooks,
    int scrollIndex,
    bool loading,
    bool error,
    bool selectionMode,
  }) = _SearchState;
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc()
      : super(const SearchState(
          search: '',
          searchResults: [],
          filteredResults: [],
          excludedBooks: [],
          filteredTranslations: [],
          scrollIndex: 0,
          loading: false,
          error: false,
          selectionMode: false,
        ));

  @override
  Stream<Transition<SearchEvent, SearchState>> transformEvents(Stream<SearchEvent> events,
      Stream<Transition<SearchEvent, SearchState>> Function(SearchEvent) transitionFn) {
    final nonDebounceStream = events.where((event) {
      return (event is! _Requested);
    });
    // debounce request streams
    final debounceStream = events.where((event) {
      return (event is _Requested);
    }).debounceTime(const Duration(milliseconds: 250));

    return super.transformEvents(nonDebounceStream.mergeWith([debounceStream]), transitionFn);
  }

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is _Requested) {
      yield state.copyWith(loading: true);
      tec.dmPrint('Loading search: ${event.search}');

      try {
        final translations = event.translations?.join('|') ?? '';
        final res = await SearchResults.fetch(words: event.search, translationIds: translations);
        tec.dmPrint('Completed search "${event.search}" with ${res.length} result(s)');

        yield state.copyWith(
            searchResults: res.map((r) => SearchResultInfo(r)).toList(),
            filteredResults: res
                .map((r) => SearchResultInfo(r))
                .where((s) => !state.excludedBooks.contains(s.searchResult.bookId))
                .toList(),
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
        final results = state.filteredResults.map((r) => r.copyWith(selected: false)).toList();
        yield state.copyWith(selectionMode: !state.selectionMode, filteredResults: results);
      }
    } else if (event is _FilterBooks) {
      yield _filterBooks(event.excludedBooks);
    } else if (event is _SetScrollIndex) {
      yield _setScrollIndex(event.scrollIndex);
    }
  }

  SearchState _setScrollIndex(int index) => state.copyWith(scrollIndex: index);

  SearchState _filterBooks(List<int> excludedBooks) {
    final filteredResults =
        state.searchResults.where((s) => !excludedBooks.contains(s.searchResult.bookId)).toList();
    return state.copyWith(filteredResults: filteredResults, excludedBooks: excludedBooks);
  }

  SearchState _modifySearchResult(SearchResultInfo info) {
    final res = List<SearchResultInfo>.from(state.filteredResults);
    final index = res.indexWhere((i) => i.searchResult == info.searchResult);
    var s = state;
    if (index != -1) {
      res[index] = info;
      s = state.copyWith(filteredResults: res);
    }

    if (s.selectionMode && s.filteredResults.where((r) => r.selected).isEmpty) {
      add(const SearchEvent.selectionModeToggle());
    }
    return s;
  }

  /// save search when navigating away or entering new search
  Future<void> saveToSearchHistory(String search,
      {String translations, String booksExcluded, int scrollIndex}) async {
    final s = SearchHistoryItem(
        search: search,
        volumesFiltered: translations,
        booksFiltered: booksExcluded,
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

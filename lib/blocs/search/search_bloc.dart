import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tec_util/tec_util.dart';

import '../../models/search/context.dart';
import '../../models/search/search_history_item.dart';
import '../../models/search/search_result.dart';
import '../../models/user_item_helper.dart';

@immutable
class SearchState extends Equatable {
  final String search;
  final List<SearchResultInfo> searchResults;
  final List<SearchResultInfo> filteredResults;
  final List<int> filteredTranslations;
  final List<int> excludedBooks;
  final int scrollIndex;
  final bool loading;
  final bool error;
  final bool selectionMode;

  const SearchState({
    @required this.search,
    @required this.searchResults,
    @required this.filteredResults,
    @required this.filteredTranslations,
    @required this.excludedBooks,
    @required this.scrollIndex,
    this.loading = false,
    this.error = false,
    this.selectionMode = false,
  });

  @override
  List<Object> get props => [
        search,
        searchResults,
        filteredResults,
        filteredTranslations,
        excludedBooks,
        scrollIndex,
        loading,
        error,
        selectionMode
      ];

  SearchState copyWith({
    String search,
    List<SearchResultInfo> searchResults,
    List<SearchResultInfo> filteredResults,
    List<int> filteredTranslations,
    List<int> excludedBooks,
    int scrollIndex,
    bool loading,
    bool error,
    bool selectionMode,
  }) =>
      SearchState(
        search: search ?? this.search,
        searchResults: searchResults ?? this.searchResults,
        filteredResults: filteredResults ?? this.filteredResults,
        filteredTranslations: filteredTranslations ?? this.filteredTranslations,
        excludedBooks: excludedBooks ?? this.excludedBooks,
        scrollIndex: scrollIndex ?? this.scrollIndex,
        loading: loading ?? this.loading,
        error: error ?? this.error,
        selectionMode: selectionMode ?? this.selectionMode,
      );
}

class SearchBloc extends Cubit<SearchState> {
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

  Future<void> search(String search, List<int> translations) async {
    emit(state.copyWith(loading: true));
    dmPrint('Loading search: "$search"');

    try {
      final translationIds = translations?.join('|') ?? state.filteredTranslations?.join('|') ?? '';
      final res = await SearchResults.fetch(words: search, translationIds: translationIds);
      dmPrint('Completed search "$search" with ${res.length} result(s)');

      emit(state.copyWith(
          searchResults: res.map((r) => SearchResultInfo(r)).toList(),
          filteredResults: res
              .map((r) => SearchResultInfo(r))
              .where((s) => !state.excludedBooks.contains(s.searchResult.bookId))
              .toList(),
          loading: false,
          error: false,
          search: search,
          filteredTranslations: translations));
    } catch (_) {
      dmPrint('Error with search "$search"');
      emit(state.copyWith(
          error: true, loading: false, search: search, filteredTranslations: translations));
    }
  }

  void selectionModeToggle() {
    dmPrint('Selection Mode in search: ${!state.selectionMode ? 'ON' : 'OFF'}');
    if (!state.selectionMode) {
      emit(state.copyWith(selectionMode: !state.selectionMode));
    } else {
      // clear selected
      final results = state.filteredResults.map((r) => r.copyWith(selected: false)).toList();
      emit(state.copyWith(selectionMode: !state.selectionMode, filteredResults: results));
    }
  }

  void setScrollIndex(int index) => emit(state.copyWith(scrollIndex: index));

  void filterBooks(List<int> excludedBooks) {
    final filteredResults =
        state.searchResults.where((s) => !excludedBooks.contains(s.searchResult.bookId)).toList();
    emit(state.copyWith(filteredResults: filteredResults, excludedBooks: excludedBooks));
  }

  void modifySearchResult(SearchResultInfo info) {
    final res = List<SearchResultInfo>.from(state.filteredResults);
    final index = res.indexWhere((i) => i.searchResult.ref == info.searchResult.ref);
    var s = state;
    if (index != -1) {
      res[index] = info;
      s = state.copyWith(filteredResults: res);
    }

    if (s.selectionMode && s.filteredResults.where((r) => r.selected).isEmpty) {
      selectionModeToggle();
    }

    emit(s);
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

  void refresh() {
    selectionModeToggle();
    selectionModeToggle();
  }
}

@immutable
class SearchResultInfo extends Equatable {
  final SearchResult searchResult;
  final bool contextExpanded;
  final int currentVerseIndex;
  final bool selected;
  final bool expanded;
  final Map<int, Context> contextMap;

  const SearchResultInfo(
    this.searchResult, {
    this.contextExpanded = false,
    this.currentVerseIndex = 0,
    this.selected = false,
    this.expanded = false,
    this.contextMap = const <int, Context>{},
  });

  @override
  List<Object> get props =>
      [searchResult, contextExpanded, currentVerseIndex, selected, expanded, contextMap];

  SearchResultInfo copyWith({
    SearchResult searchResult,
    bool contextExpanded,
    int currentVerseIndex,
    bool selected,
    bool expanded,
    Map<int, Context> contextMap,
  }) =>
      SearchResultInfo(
        searchResult ?? this.searchResult,
        contextExpanded: contextExpanded ?? this.contextExpanded,
        currentVerseIndex: currentVerseIndex ?? this.currentVerseIndex,
        selected: selected ?? this.selected,
        expanded: expanded ?? this.expanded,
        contextMap: contextMap ?? this.contextMap,
      );

  String get shareText => '$label\n$currentText';
  String get label => contextExpanded && contextMap[currentVerseIndex] != null
      ? '${searchResult.ref.split(':')[0]}:'
          '${contextMap[currentVerseIndex].initialVerse}-${contextMap[currentVerseIndex].finalVerse}'
          ' ${searchResult.verses[currentVerseIndex].abbreviation}'
      : '${searchResult.ref} ${searchResult.verses[currentVerseIndex].abbreviation}';
  String get currentText => contextExpanded && contextMap[currentVerseIndex] != null
      ? contextMap[currentVerseIndex].text
      : searchResult.verses[currentVerseIndex].verseContent;
}

import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../models/search/autocomplete.dart';

enum NavViewState { bcvTabs, searchSuggestions, searchResults }
enum NavTabs { book, chapter, verse }

@immutable
class NavState extends Equatable {
  final NavViewState navViewState;
  final int tabIndex;
  final Reference ref;
  final String search;
  final List<int> bookSuggestions;
  final List<String> wordSuggestions;

  const NavState(this.navViewState, this.tabIndex, this.ref, this.search, this.bookSuggestions,
      this.wordSuggestions);

  @override
  List<Object> get props => [navViewState, tabIndex, ref, search, bookSuggestions, wordSuggestions];

  NavState copyWith({
    NavViewState navViewState,
    int tabIndex,
    Reference ref,
    String search,
    List<int> bookSuggestions,
    List<String> wordSuggestions,
  }) =>
      NavState(
        navViewState ?? this.navViewState,
        tabIndex ?? this.tabIndex,
        ref ?? this.ref,
        search ?? this.search,
        bookSuggestions ?? this.bookSuggestions,
        wordSuggestions ?? this.wordSuggestions,
      );
}

class NavBloc extends Cubit<NavState> {
  final Reference initialRef;
  final int initialTabIndex;

  NavBloc(this.initialRef, {this.initialTabIndex = 1})
      : super(NavState(NavViewState.bcvTabs, initialTabIndex,
            initialRef ?? Reference.fromHref('50/1/1', volume: 9), '', const [], const []));

  void changeNavView(NavViewState vs) => emit(state.copyWith(navViewState: vs));

  void onSearchChange(String s) {
    // dmPrint('SEARCH CHANGE: $s');
    var newState = state.copyWith(search: s);

    if (s.isNotEmpty && s != null) {
      final bible = VolumesRepository.shared.bibleWithId(state.ref.volume);
      final lastChar = s.isNotEmpty ? s[s.length - 1] : null;
      final selectedBook = bible.nameOfBook(state.ref.book);

      final check = s.toLowerCase();
      // book tab
      final endsWithSpaceDigit = lastChar == ' ';
      final matches = <int, String>{};

      final m = RegExp(r'(\w+)? ([0-9]+):?([0-9]+)?').firstMatch(check);

      var ref = state.ref;

      if (m != null) {
        var correctBook = false;
        if (m.group(1) != null) {
          var book = bible.firstBook;
          while (book != 0) {
            final name = bible.nameOfBook(book).toLowerCase();
            if (name == m.group(1).trim()) {
              correctBook = true;
              ref = ref.copyWith(book: book);
              break;
            }
            final nextBook = bible.bookAfter(book);
            book = (nextBook == book ? 0 : nextBook);
          }
        } // the entry is a # or a #: or a #:#?
        if (correctBook) {
          if (m.group(2) != null) {
            final chapter = int.parse(m.group(2));
            if (chapter > 0 && chapter <= bible.chaptersIn(book: ref.book)) {
              newState = newState.copyWith(tabIndex: NavTabs.verse.index);
              ref = ref.copyWith(chapter: chapter);
              // chapter is ok...
              if (m.group(3) != null) {
                // check verse
                final verse = int.parse(m.group(3));
                if (verse > 0 && verse <= bible.versesIn(book: ref.book, chapter: chapter)) {
                  newState = newState.copyWith(tabIndex: NavTabs.verse.index);
                  ref = ref.copyWith(verse: verse, endVerse: verse);
                }
              }

              emit(newState.copyWith(ref: ref));
              return;
            }
          }
        }
      }
      if (newState.tabIndex == NavTabs.book.index) {
        var book = bible.firstBook;
        while (book != 0) {
          final name = bible.nameOfBook(book).toLowerCase();
          if (name == check.trim()) {
            emit(newState.copyWith(
                navViewState: NavViewState.bcvTabs,
                tabIndex: NavTabs.chapter.index,
                ref: state.ref.copyWith(book: book),
                search: '${bible.nameOfBook(book)} '));
            return;
          } else if (name.startsWith(s.toLowerCase())) {
            matches[book] = bible.nameOfBook(book);
          }
          final nextBook = bible.bookAfter(book);
          book = (nextBook == book ? 0 : nextBook);
        }

        if (matches.length == 1) {
          if (endsWithSpaceDigit) {
            emit(newState.copyWith(
                ref: state.ref.copyWith(book: matches.keys.first),
                search: '${matches.values.first} '));
            return;
          }
        }
        loadWordSuggestions(s);

        newState = newState.copyWith(
          search: s,
          bookSuggestions: matches.keys.toList(),
          // navViewState: NavViewState.searchSuggestions
        );
      } else if (newState.tabIndex == NavTabs.chapter.index) {
        // chapter tab
        newState = newState.copyWith(navViewState: NavViewState.bcvTabs);
        if (lastChar == ':') {
          int chapter;
          try {
            chapter = int.parse(
              s.trim().substring(selectedBook.length).replaceAll(':', '').trim(),
            );
          } catch (e) {
            chapter = -1;
            dmPrint(e.toString());
          }

          if (chapter > 0 && s.toLowerCase().trim() == '${selectedBook.toLowerCase()} $chapter:') {
            emit(newState.copyWith(
              ref: newState.ref.copyWith(chapter: chapter),
              tabIndex: NavTabs.verse.index,
              search: s,
            ));
            return;
          }
        } else if (!s
            .toLowerCase()
            .startsWith(selectedBook.toLowerCase()) /*|| s.length == selectedBook.length */) {
          loadWordSuggestions(s);
          // newState = newState.copyWith(search: s, navViewState: NavViewState.searchSuggestions);
        }
      } else if (newState.tabIndex == NavTabs.verse.index) {
        //verse tab
        // did the colon get deleted...
        if (!s.toLowerCase().startsWith(selectedBook.toLowerCase()) ||
            s.length <= selectedBook.length) {
          newState =
              newState.copyWith(tabIndex: NavTabs.book.index, navViewState: NavViewState.bcvTabs);
        } else if (!s.contains(':')) {
          newState = newState.copyWith(
              tabIndex: NavTabs.chapter.index,
              navViewState: NavViewState.bcvTabs,
              search: '${bible.nameOfBook(newState.ref.book)} ');
        }
      }
    } else {
      newState = newState.copyWith(navViewState: NavViewState.bcvTabs, search: '');
    }

    emit(newState);
  }

  void onSearchFinished(String s) {
    dmPrint('Search Submitted: $s');
    emit(state.copyWith(search: s, navViewState: NavViewState.searchResults));
  }

  Future<void> loadWordSuggestions(String s) async {
    final suggestions =
        (await AutoComplete.fetch(phrase: s, translationIds: '${state.ref.volume}')).possibles;

    // TODO(abby): fix word suggest
    emit(
        state.copyWith(wordSuggestions: suggestions, navViewState: NavViewState.searchSuggestions));
  }

  void changeTabIndex(int index) {
    var search = '';
    if (state.navViewState == NavViewState.bcvTabs && index > NavTabs.book.index) {
      final bible = VolumesRepository.shared.bibleWithId(initialRef.volume);
      final bookName = bible.nameOfBook(state.ref.book);
      search += bookName;
      if (index == NavTabs.verse.index) {
        search += ' ${state.ref.chapter}:';
      }
    }
    emit(state.copyWith(search: search, tabIndex: index));
  }

  void setReference(Reference ref) => emit(state.copyWith(ref: ref));

  void selectBook(int bookId, String bookName) {
    // need to set ref before changing tab index or else will cause issues
    var ref = state.ref.copyWith(book: bookId);
    if (state.ref.book != bookId) {
      // if changed book, init with first chapter
      ref = ref.copyWith(chapter: 1, verse: 1, endVerse: 1);
    }
    emit(state.copyWith(ref: ref, tabIndex: NavTabs.chapter.index, search: bookName));
  }

  void selectChapter(int bookId, String bookName, int chapter) {
    final ref = state.ref.copyWith(book: bookId, chapter: chapter);
    final search = '$bookName $chapter:';
    emit(state.copyWith(ref: ref, tabIndex: NavTabs.verse.index, search: search));
  }
}

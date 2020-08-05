import 'package:bible/models/autocomplete.dart';
import 'package:flutter/foundation.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'nav_bloc.freezed.dart';

enum NavViewState { bcvTabs, searchSuggestions, searchResults }
enum NavTabs { book, chapter, verse }

@freezed
abstract class NavEvent with _$NavEvent {
  const factory NavEvent.changeTabIndex({int index}) = _ChangeIndex;
  const factory NavEvent.setRef({Reference ref}) = _SetRef;
  const factory NavEvent.onSearchChange({String search}) = _OnSearchChange;
  const factory NavEvent.loadHistory() = _LoadHistory;
  const factory NavEvent.loadWordSuggestions({String search}) = _LoadWordSuggestions;
  const factory NavEvent.changeNavView({NavViewState state}) = _ChangeNavView;
  const factory NavEvent.onSearchFinished() = _OnSearchFinished;
  const factory NavEvent.changeState(NavState state) = _ChangeNavState;
}

@freezed
abstract class NavState with _$NavState {
  const factory NavState({
    NavViewState navViewState,
    int tabIndex,
    Reference ref,
    String search,
    List<int> bookSuggestions,
    List<String> wordSuggestions,
    List<String> history,
  }) = _NavState;
}

class NavBloc extends Bloc<NavEvent, NavState> {
  final Reference initialRef;
  NavBloc(this.initialRef);

  @override
  NavState get initialState => NavState(
      ref: initialRef ?? Reference.fromHref('50/1/1', volume: 51),
      tabIndex: 0,
      search: '',
      bookSuggestions: [],
      wordSuggestions: [],
      history: [],
      navViewState: NavViewState.bcvTabs);

  @override
  Stream<NavState> mapEventToState(NavEvent event) async* {
    if (event is _LoadWordSuggestions) {
      final suggestions = await _loadWordSuggestions(event.search);
      yield state.copyWith(wordSuggestions: suggestions);
    } else {
      final newState = event.when(
          changeNavView: _changeNavView,
          onSearchChange: _onSearchChange,
          onSearchFinished: _onSearchFinished,
          loadHistory: _loadHistory,
          loadWordSuggestions: (_) {},
          changeTabIndex: _changeTabIndex,
          changeState: _changeState,
          setRef: _setReference);
      // debugPrint('$newState');
      yield newState;
    }
  }

  NavState _changeNavView(NavViewState vs) => state.copyWith(navViewState: vs);

  NavState _onSearchChange(String s) {
    final bible = VolumesRepository.shared.bibleWithId(state.ref.volume);
    final lastChar = s.isNotEmpty ? s[s.length - 1] : null;
    final selectedBook = bible.nameOfBook(state.ref.book);

    var currState = state;

    if (s.isNotEmpty && s != null) {
      final check = s.toLowerCase();

      switch (state.tabIndex) {
        case 0: // book tab
          final endsWithSpaceDigit = lastChar == ' ';
          final matches = <int, String>{};
          var addCurrentRef = false;

          final m = RegExp('([0-9]+):?([0-9]+)?').firstMatch(check);

          final ref = state.ref;

          if (m != null) {
            // the entry is a # or a #: or a #:#?
            final chapter = int.parse(m.group(1));
            if (chapter > 0 && chapter <= bible.chaptersIn(book: ref.book)) {
              var refOk = true;

              // chapter is ok...
              if (m.group(2) != null) {
                // check verse
                final verse = int.parse(m.group(2));
                if (verse < 0 || verse > bible.versesIn(book: ref.book, chapter: chapter)) {
                  refOk = false;
                }
              }

              if (refOk) {
                final b = '${bible.nameOfBook(ref.book)} $check';
                matches[ref.book] = b;
                addCurrentRef = true;
              }
            }
          }

          var book = bible.firstBook;
          while (book != 0) {
            final name = bible.nameOfBook(book).toLowerCase();
            if (name == check.trim()) {
              return currState.copyWith(
                  navViewState: NavViewState.bcvTabs,
                  tabIndex: 1,
                  ref: state.ref.copyWith(book: book),
                  search: '${bible.nameOfBook(book)} ');
            } else if (name.startsWith(s.toLowerCase())) {
              matches[book] = bible.nameOfBook(book);
            }
            final nextBook = bible.bookAfter(book);
            book = (nextBook == book ? 0 : nextBook);
          }

          if (matches.length == 1 && !addCurrentRef) {
            if (endsWithSpaceDigit) {
              return currState.copyWith(
                  ref: state.ref.copyWith(book: matches.keys.first),
                  search: '${matches.values.first} ');
            }
          }
          add(NavEvent.loadWordSuggestions(search: s));

          currState = currState.copyWith(
              search: s,
              bookSuggestions: matches.keys.toList(),
              navViewState: NavViewState.searchSuggestions);

          break;
        case 1: // chapter tab
          currState = currState.copyWith(navViewState: NavViewState.bcvTabs);
          if (lastChar == ':' && state.tabIndex == 1) {
            int chapter;
            try {
              chapter = int.parse(
                s.trim().substring(selectedBook.length).replaceAll(':', '').trim(),
              );
            } catch (e) {
              chapter = -1;
              debugPrint(e.toString());
            }

            if (chapter > 0 && s.trim() == '$selectedBook $chapter:') {
              return currState.copyWith(
                ref: currState.ref.copyWith(chapter: chapter),
                tabIndex: 2,
                search: s,
              );
            }
          } else if (!s.startsWith(selectedBook) || s.length == selectedBook.length) {
            currState = currState.copyWith(tabIndex: 0, search: '');
          }
          break;
        case 2: //verse tab
          // did the colon get deleted...
          if (!s.startsWith(selectedBook) || s.length <= selectedBook.length) {
            currState = currState.copyWith(tabIndex: 0, navViewState: NavViewState.bcvTabs);
          } else if (!s.contains(':')) {
            currState = currState.copyWith(
                tabIndex: 1,
                navViewState: NavViewState.bcvTabs,
                search: '${bible.nameOfBook(currState.ref.book)} ');
          }
          break;
      }
    } else {
      currState = currState.copyWith(navViewState: NavViewState.bcvTabs, search: '');
    }
    return currState;
  }

  NavState _onSearchFinished() {
    // TODO(abby): on submit typing 'judges 3' will not go to correct place...
    // check to see if bible ref and ask to navigate appropriately
    //
    return state.copyWith(navViewState: NavViewState.searchResults);
  }

  NavState _changeState(NavState s) => s;

  NavState _loadHistory() {
    // TODO(abby): implement
    return state;
  }

  Future<List<String>> _loadWordSuggestions(String s) async {
    final ac = await AutoComplete.fetch(phrase: s, translationIds: '${state.ref.volume}');
    return ac?.possibles;
  }

  NavState _changeTabIndex(int index) {
    final bible = VolumesRepository.shared.bibleWithId(initialRef.volume);
    final bookName = bible.nameOfBook(state.ref.book);
    var search = '';
    if (index > NavTabs.book.index) {
      search += bookName;
      if (index == NavTabs.verse.index) {
        search += ' ${state.ref.chapter}:';
      }
    }
    return state.copyWith(search: search, tabIndex: index);
  }

  NavState _setReference(Reference ref) => state.copyWith(ref: ref);

  void selectBook(int bookId, String bookName) {
    // need to set ref before changing tab index or else will cause issues
    final ref = state.ref.copyWith(book: bookId);
    add(NavEvent.changeState(
        state.copyWith(ref: ref, tabIndex: NavTabs.chapter.index, search: bookName)));
  }

  void selectChapter(int bookId, String bookName, int chapter) {
    final ref = state.ref.copyWith(book: bookId, chapter: chapter);
    final search = '$bookName $chapter:';
    add(NavEvent.changeState(
        state.copyWith(ref: ref, tabIndex: NavTabs.verse.index, search: search)));
  }
}

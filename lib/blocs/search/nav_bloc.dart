import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../models/search/autocomplete.dart';

part 'nav_bloc.freezed.dart';

enum NavViewState { bcvTabs, searchSuggestions, searchResults }
enum NavTabs { book, chapter, verse }

@freezed
abstract class NavEvent with _$NavEvent {
  const factory NavEvent.changeTabIndex({int index}) = _ChangeIndex;
  const factory NavEvent.setRef({Reference ref}) = _SetRef;
  const factory NavEvent.onSearchChange({String search}) = _OnSearchChange;
  const factory NavEvent.loadWordSuggestions({String search}) = _LoadWordSuggestions;
  const factory NavEvent.changeNavView({NavViewState state}) = _ChangeNavView;
  const factory NavEvent.onSearchFinished({String search}) = _OnSearchFinished;
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
  }) = _NavState;
}

class NavBloc extends Bloc<NavEvent, NavState> {
  final Reference initialRef;
  final int initialTabIndex;
  NavBloc(this.initialRef, {this.initialTabIndex = 1})
      : super(NavState(
          ref: initialRef ?? Reference.fromHref('50/1/1', volume: 9),
          tabIndex: initialTabIndex,
          search: '',
          bookSuggestions: [],
          wordSuggestions: [],
          navViewState: NavViewState.bcvTabs,
        ));

  // @override
  // // ignore: type_annotate_public_apis
  // Stream<Transition<NavEvent, NavState>> transformEvents(Stream<NavEvent> events, transitionFn) {
  //   final nonDebounceStream = events.where((event) {
  //     return (event is! _OnSearchChange);
  //   });

  //   // debounce request streams
  //   final debounceStream = events.where((event) {
  //     return (event is _OnSearchChange);
  //   }).debounceTime(const Duration(milliseconds: 250));

  //   return super.transformEvents(nonDebounceStream.mergeWith([debounceStream]), transitionFn);
  // }

  // @override
  // void onTransition(Transition<NavEvent, NavState> transition) {
  //   // tec.dmPrint(transition);
  //   super.onTransition(transition);
  // }

  @override
  Stream<NavState> mapEventToState(NavEvent event) async* {
    if (event is _LoadWordSuggestions) {
      final suggestions = await _loadWordSuggestions(event.search);
      yield state.copyWith(
          wordSuggestions: suggestions, navViewState: NavViewState.searchSuggestions);
    } else {
      final newState = event.when(
          changeNavView: _changeNavView,
          onSearchChange: _onSearchChange,
          onSearchFinished: _onSearchFinished,
          loadWordSuggestions: (_) {},
          changeTabIndex: _changeTabIndex,
          changeState: _changeState,
          setRef: _setReference);
      // tec.dmPrint('$newState');
      tec.dmPrint(NavViewState.values[newState.navViewState.index]);
      yield newState;
    }
  }

  NavState _changeNavView(NavViewState vs) => state.copyWith(navViewState: vs);

  NavState _onSearchChange(String s) {
    // tec.dmPrint('SEARCH CHANGE: $s');
    var currState = state.copyWith(search: s);

    if (s.isNotEmpty && s != null) {
      final bible = VolumesRepository.shared.bibleWithId(state.ref.volume);
      final lastChar = s.isNotEmpty ? s[s.length - 1] : null;
      final selectedBook = bible.nameOfBook(state.ref.book);

      final check = s.toLowerCase();
      if (currState.tabIndex == NavTabs.book.index) {
        // book tab
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
                tabIndex: NavTabs.chapter.index,
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
          // navViewState: NavViewState.searchSuggestions
        );
      } else if (currState.tabIndex == NavTabs.chapter.index) {
        // chapter tab
        currState = currState.copyWith(navViewState: NavViewState.bcvTabs);
        if (lastChar == ':') {
          int chapter;
          try {
            chapter = int.parse(
              s.trim().substring(selectedBook.length).replaceAll(':', '').trim(),
            );
          } catch (e) {
            chapter = -1;
            tec.dmPrint(e.toString());
          }

          if (chapter > 0 && s.trim() == '$selectedBook $chapter:') {
            return currState.copyWith(
              ref: currState.ref.copyWith(chapter: chapter),
              tabIndex: NavTabs.verse.index,
              search: s,
            );
          }
        } else if (!s
            .toLowerCase()
            .startsWith(selectedBook.toLowerCase()) /*|| s.length == selectedBook.length */) {
          add(NavEvent.loadWordSuggestions(search: s));
          // currState = currState.copyWith(search: s, navViewState: NavViewState.searchSuggestions);
        }
      } else if (currState.tabIndex == NavTabs.verse.index) {
        //verse tab
        // did the colon get deleted...
        if (!s.startsWith(selectedBook) || s.length <= selectedBook.length) {
          currState =
              currState.copyWith(tabIndex: NavTabs.book.index, navViewState: NavViewState.bcvTabs);
        } else if (!s.contains(':')) {
          currState = currState.copyWith(
              tabIndex: NavTabs.chapter.index,
              navViewState: NavViewState.bcvTabs,
              search: '${bible.nameOfBook(currState.ref.book)} ');
        }
      }
    } else {
      currState = currState.copyWith(navViewState: NavViewState.bcvTabs, search: '');
    }
    return currState;
  }

  NavState _onSearchFinished(String s) {
    tec.dmPrint('Search Submitted: $s');
    return state.copyWith(search: s, navViewState: NavViewState.searchResults);
  }

  NavState _changeState(NavState s) => s;

  Future<List<String>> _loadWordSuggestions(String s) async =>
      (await AutoComplete.fetch(phrase: s, translationIds: '${state.ref.volume}')).possibles;

  NavState _changeTabIndex(int index) {
    var search = '';
    if (state.navViewState == NavViewState.bcvTabs && index > NavTabs.book.index) {
      final bible = VolumesRepository.shared.bibleWithId(initialRef.volume);
      final bookName = bible.nameOfBook(state.ref.book);
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
    var ref = state.ref.copyWith(book: bookId);
    if (state.ref.book != bookId) {
      // if changed book, init with first chapter
      ref = ref.copyWith(chapter: 1, verse: 1, endVerse: 1);
    }
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

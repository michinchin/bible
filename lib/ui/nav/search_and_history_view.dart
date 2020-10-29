import 'dart:collection';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/search/nav_bloc.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../models/pref_item.dart';
import '../../models/search/context.dart';
import '../../models/search/search_history_item.dart';
import '../../models/search/search_result.dart';
import '../../models/search/tec_share.dart';
import '../../models/search/verse.dart';
import '../../models/user_item_helper.dart';
import '../common/common.dart';
import '../sheet/compare_verse.dart';

const searchThemeColor = Colors.orange;

class SearchAndHistoryView extends StatelessWidget {
  final TextEditingController searchController;
  final TabController tabController;
  const SearchAndHistoryView(this.searchController, this.tabController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Center(
          child: TabBar(
              controller: tabController,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BubbleTabIndicator(color: searchThemeColor.withOpacity(0.5)),
              labelColor: Theme.of(context).textColor.withOpacity(0.7),
              unselectedLabelColor: Theme.of(context).textColor.withOpacity(0.7),
              tabs: const [Tab(child: Text('HISTORY')), Tab(child: Text('SEARCH RESULTS'))]),
        ),
      ),
      body: TabBarView(
          controller: tabController,
          children: [HistoryView(searchController, tabController), SearchResultsView()]),
    );
  }
}

class HistoryView extends StatefulWidget {
  final TextEditingController searchController;
  final TabController tabController;
  const HistoryView(this.searchController, this.tabController);

  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  void _onSearchTap(BuildContext c, SearchHistoryItem searchHistoryItem) {
    c.bloc<SearchBloc>()
      ..add(SearchEvent.request(
        search: searchHistoryItem.search,
        translations: searchHistoryItem.volumesFiltered.isNotEmpty
            ? searchHistoryItem.volumesFiltered.split('|').map(int.parse).toList()
            : [],
      ))
      ..add(SearchEvent.filterBooks(searchHistoryItem.booksFiltered.isNotEmpty
          ? searchHistoryItem.booksFiltered.split('|').map(int.parse).toList()
          : []))
      ..add(SearchEvent.setScrollIndex(searchHistoryItem?.index ?? 0));

    c.bloc<NavBloc>().add(NavEvent.onSearchFinished(search: searchHistoryItem.search));
    widget.searchController
      ..text = searchHistoryItem.search
      ..selection = TextSelection.collapsed(offset: searchHistoryItem.search.length);
    widget.tabController.animateTo(1);
  }

  void _onNavHistoryTap(BuildContext c, Reference ref, int volume) =>
      Navigator.of(c).maybePop<Reference>(ref?.copyWith(volume: volume));

  Future<List<dynamic>> _future() => Future.wait<List<dynamic>>(
      [UserItemHelper.navHistoryItemsFromDb(), UserItemHelper.searchHistoryItemsFromDb()]);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: _future(),
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }
          if (s.hasError) {
            return const Center(child: Text('Error'));
          }
          if (s.hasData) {
            final navHistory = tec.as<List<Reference>>(s.data[0])
              ..sort((a, b) => b.modified.compareTo(a.modified));
            final searchHistory = tec.as<List<SearchHistoryItem>>(s.data[1])
              ..sort((a, b) => b.modified.compareTo(a.modified));
            return searchHistory.isEmpty && navHistory.isEmpty
                ? const Center(child: Text('Search or navigate to view history'))
                : SingleChildScrollView(
                    child: Column(children: [
                      InkWell(
                        onTap: () async {
                          final ref = await Navigator.of(c).push(MaterialPageRoute<Reference>(
                              builder: (c) => _NavHistoryView(navHistory)));
                          if (ref != null) {
                            _onNavHistoryTap(c, ref, context.bloc<NavBloc>().state.ref.volume);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const ListLabel('Navigation History'),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.chevron_right,
                                  color: Theme.of(context).textTheme.caption.color),
                            ),
                          ]),
                        ),
                      ),
                      ...ListTile.divideTiles(context: context, tiles: [
                        for (final navHistoryItem in navHistory.take(5))
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.history),
                            // remove translation from label
                            title: Text(navHistoryItem
                                .label()
                                .split(' ')
                                .take(navHistoryItem.label().split(' ').length - 1)
                                .join(' ')),
                            onTap: () => _onNavHistoryTap(
                                c, navHistoryItem, context.bloc<NavBloc>().state.ref.volume),
                          )
                      ]),
                      InkWell(
                          onTap: () async {
                            final searchChosen = await Navigator.of(c).push(
                                MaterialPageRoute<SearchHistoryItem>(
                                    builder: (c) => _SearchHistoryView(searchHistory)));
                            if (searchChosen != null) {
                              _onSearchTap(c, searchChosen);
                            }
                          },
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child:
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const ListLabel('Search History'),
                                Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.chevron_right,
                                        color: Theme.of(c).textTheme.caption.color)),
                              ]))),
                      ...ListTile.divideTiles(context: context, tiles: [
                        for (final searchHistoryItem in searchHistory.take(5))
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.search),
                            title: Text(searchHistoryItem.search),
                            onTap: () => _onSearchTap(c, searchHistoryItem),
                          )
                      ]),
                    ]),
                  );
          }
          return const Center(child: Text('Unable to load currently'));
        });
  }
}

class _SearchHistoryView extends StatelessWidget {
  final List<SearchHistoryItem> searchHistory;
  const _SearchHistoryView(this.searchHistory);
  @override
  Widget build(BuildContext context) {
    String _subtitle(int i) {
      final localizations = MaterialLocalizations.of(context);
      final formattedTimeOfDay = localizations.formatTimeOfDay(TimeOfDay(
          hour: searchHistory[i].modified.hour, minute: searchHistory[i].modified.minute));
      return '${tec.shortDate(searchHistory[i].modified)}, $formattedTimeOfDay';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search History'),
      ),
      body: searchHistory.isEmpty
          ? const Center(
              child: Text('No search history to show yet'),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: searchHistory.length,
              separatorBuilder: (c, i) => const Divider(height: 5),
              itemBuilder: (c, i) => ListTile(
                dense: true,
                leading: const Icon(Icons.search),
                title: Text(searchHistory[i].search),
                subtitle: Text(_subtitle(i)),
                onTap: () => Navigator.of(c).pop<SearchHistoryItem>(searchHistory[i]),
              ),
            ),
    );
  }
}

class _NavHistoryView extends StatelessWidget {
  final List<Reference> navHistory;
  const _NavHistoryView(this.navHistory);
  @override
  Widget build(BuildContext context) {
    String _subtitle(int i) {
      final localizations = MaterialLocalizations.of(context);
      final formattedTimeOfDay = localizations.formatTimeOfDay(
          TimeOfDay(hour: navHistory[i].modified.hour, minute: navHistory[i].modified.minute));
      return '${tec.shortDate(navHistory[i].modified)}, $formattedTimeOfDay';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation History'),
      ),
      body: navHistory.isEmpty
          ? const Center(
              child: Text('No navigation history to show yet'),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: navHistory.length,
              separatorBuilder: (c, i) => const Divider(height: 5),
              itemBuilder: (c, i) => ListTile(
                dense: true,
                leading: const Icon(Icons.history),
                title: Text(navHistory[i].label()),
                subtitle: Text(_subtitle(i)),
                onTap: () {
                  Navigator.of(context).maybePop<Reference>(navHistory[i]);
                },
              ),
            ),
    );
  }
}

class SearchResultsView extends StatefulWidget {
  @override
  _SearchResultsViewState createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  ItemScrollController scrollController;
  ItemPositionsListener positionListener;

  @override
  void initState() {
    final s = context.bloc<SearchBloc>().state;
    scrollController = ItemScrollController();
    if (s.scrollIndex > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.isAttached) {
          scrollController.scrollTo(
              index: s.scrollIndex, duration: const Duration(milliseconds: 250));
          TecToast.show(context, 'Scrolled to last saved place');
        }
      });
    }
    positionListener = ItemPositionsListener.create();
    super.initState();
  }

  @override
  void deactivate() {
    _saveSearch(context.bloc<SearchBloc>().state);
    super.deactivate();
  }

  SearchResultInfo orderByDefaultTranslation(SearchResultInfo res) {
    final defaultTranslations =
        context.bloc<PrefItemsBloc>().itemWithId(PrefItemId.priorityTranslations).info;
    final dts = (defaultTranslations?.split('|')?.map(int.tryParse)?.toList() ?? [])
      ..removeWhere((p) => p == null);

    final verses = res.searchResult.verses;
    final ids = verses.map((v) => v.id).toList();
    final orderedVerses = List<Verse>.from(verses);
    for (final dt in dts.reversed) {
      if (ids.contains(dt)) {
        final idx = orderedVerses.indexWhere((v) => v.id == dt);
        final verse = orderedVerses.removeAt(idx);
        orderedVerses.insert(0, verse);
      }
    }
    return res.copyWith(searchResult: res.searchResult.copyWith(verses: orderedVerses));
  }

  Future<void> _saveSearch(SearchState s) async {
    if (positionListener.itemPositions.value.isNotEmpty) {
      if (s.filteredResults.isNotEmpty) {
        // this is where we save the search result...once user exits page
        await context.bloc<SearchBloc>().saveToSearchHistory(s.search,
            translations: s.filteredTranslations.join('|'),
            booksExcluded: s.excludedBooks.join('|'),
            scrollIndex: positionListener.itemPositions.value.first.index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchBloc, SearchState>(
        listener: (c, s) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.isAttached) {
              scrollController.scrollTo(index: 0, duration: const Duration(milliseconds: 250));
            }
          });
        },
        listenWhen: (p, c) => !tec.areEqualLists(p.excludedBooks, c.excludedBooks),
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: LoadingIndicator());
          } else if (state.error) {
            return const Center(
              child: Text('Error'),
            );
          } else if (state.filteredResults.isEmpty) {
            return const Center(
              child: Text('No Results'),
            );
          }
          final results = state.filteredResults.map(orderByDefaultTranslation).toList();
          return SafeArea(
            bottom: false,
            child: Scaffold(
              body: ScrollablePositionedList.separated(
                itemCount: results.length + 1,
                itemScrollController: scrollController,
                itemPositionsListener: positionListener,
                separatorBuilder: (c, i) {
                  if (i == 0) {
                    // if sized box has height: 0, causes errors in scrollable list
                    // see: https://stackoverflow.com/questions/63352010/failed-assertion-line-556-pos-15-scrolloffsetcorrection-0-0-is-not-true
                    return const SizedBox(height: 1);
                  }
                  i--;
                  return const Divider(height: 5);
                },
                itemBuilder: (c, i) {
                  if (i == 0) {
                    return SearchResultsLabel(results.map((r) => r.searchResult).toList());
                  }
                  i--;
                  final res = results[i];
                  return _SearchResultCard(res);
                },
              ),
            ),
          );
        });
  }
}

class _SearchResultCard extends StatefulWidget {
  final SearchResultInfo res;
  const _SearchResultCard(this.res);

  @override
  __SearchResultCardState createState() => __SearchResultCardState();
}

class __SearchResultCardState extends State<_SearchResultCard> {
  bool _includeShareLink;

  @override
  void initState() {
    _includeShareLink = context.bloc<PrefItemsBloc>().itemBool(PrefItemId.includeShareLink);
    super.initState();
  }

  Future<void> _changeTranslation(int verseIndex) async {
    final c = widget.res.contextMap[verseIndex];
    if (c == null && widget.res.contextExpanded) {
      final newC = await Context.fetch(
        translation: widget.res.searchResult.verses[verseIndex].id,
        book: widget.res.searchResult.bookId,
        chapter: widget.res.searchResult.chapterId,
        verse: widget.res.searchResult.verseId,
        content: widget.res.searchResult.verses[verseIndex].verseContent,
      );
      final map = Map<int, Context>.from(widget.res.contextMap);
      map[verseIndex] = newC;
      context.bloc<SearchBloc>().add(SearchEvent.modifySearchResult(
          searchResult: widget.res.copyWith(contextMap: map, currentVerseIndex: verseIndex)));
    } else {
      context.bloc<SearchBloc>().add(SearchEvent.modifySearchResult(
          searchResult: widget.res.copyWith(currentVerseIndex: verseIndex)));
    }
  }

  Future<void> _onContext() async {
    final c = widget.res.contextMap[widget.res.currentVerseIndex];
    if (c == null) {
      final newC = await Context.fetch(
        translation: widget.res.searchResult.verses[widget.res.currentVerseIndex].id,
        book: widget.res.searchResult.bookId,
        chapter: widget.res.searchResult.chapterId,
        verse: widget.res.searchResult.verseId,
        content: widget.res.searchResult.verses[widget.res.currentVerseIndex].verseContent,
      );
      final map = Map<int, Context>.from(widget.res.contextMap);
      map[widget.res.currentVerseIndex] = newC;
      context.bloc<SearchBloc>().add(SearchEvent.modifySearchResult(
          searchResult:
              widget.res.copyWith(contextMap: map, contextExpanded: !widget.res.contextExpanded)));
    } else {
      context.bloc<SearchBloc>().add(SearchEvent.modifySearchResult(
          searchResult: widget.res.copyWith(contextExpanded: !widget.res.contextExpanded)));
    }
  }

  void _onExpanded() {
    context.bloc<SearchBloc>().add(SearchEvent.modifySearchResult(
        searchResult: widget.res.copyWith(expanded: !widget.res.expanded)));
  }

  void _onShare() {
    if (_includeShareLink) {
      final volume = widget.res.searchResult.verses[widget.res.currentVerseIndex].id;
      var ref = Reference.fromHref(widget.res.searchResult.href, volume: volume);
      final c = widget.res.contextMap[widget.res.currentVerseIndex];
      if (c != null) {
        ref = ref.copyWith(verse: c.initialVerse, endVerse: c.finalVerse);
      }
      TecShare.shareWithLink(widget.res.shareText, ref);
    } else {
      TecShare.share(widget.res.shareText);
    }
  }

  void _onCopy() {
    if (_includeShareLink) {
      final volume = widget.res.searchResult.verses[widget.res.currentVerseIndex].id;
      var ref = Reference.fromHref(widget.res.searchResult.href, volume: volume);
      final c = widget.res.contextMap[widget.res.currentVerseIndex];
      if (c != null) {
        ref = ref.copyWith(verse: c.initialVerse, endVerse: c.finalVerse);
      }
      TecShare.copyWithLink(context, widget.res.shareText, ref);
    } else {
      TecShare.copy(context, widget.res.shareText);
    }
  }

  void _openInTB() {
    Navigator.of(context, rootNavigator: true).pop(Reference.fromHref(widget.res.searchResult.href,
        volume: widget.res.searchResult.verses[widget.res.currentVerseIndex].id));
    tec.dmPrint('Navigating to verse: ${widget.res.searchResult.href}');
  }

  void _onListTileTap() {
    final selectionMode = context.bloc<SearchBloc>().state.selectionMode;
    if (selectionMode) {
      context.bloc<SearchBloc>().add(SearchEvent.modifySearchResult(
          searchResult: widget.res.copyWith(selected: !widget.res.selected)));
    } else {
      _onExpanded();
    }
  }

  void _onLongPress() {
    // ignore: close_sinks
    final searchBloc = context.bloc<SearchBloc>();
    final selectionMode = searchBloc.state.selectionMode;
    if (!selectionMode) {
      searchBloc
        ..add(const SearchEvent.selectionModeToggle())
        ..add(SearchEvent.modifySearchResult(
            searchResult: widget.res.copyWith(selected: !widget.res.selected)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.res.selected ? searchThemeColor : Theme.of(context).textColor;
    Widget content() => TecText.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: '${widget.res.label}\n',
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
              WidgetSpan(child: Container(height: 3)),
              ...searchResTextSpans(
                widget.res.currentText,
                context.bloc<SearchBloc>().state.search,
              ),
            ],
            style: TextStyle(color: textColor),
          ),
          textScaleFactor: contentTextScaleFactorWith(context),
        );

    if (!widget.res.expanded) {
      return InkWell(
        onTap: _onListTileTap,
        onLongPress: _onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Expanded(child: content()),
            IconButton(
              tooltip: 'Expand Card',
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              alignment: Alignment.center,
              icon: const Icon(Icons.expand_more),
              onPressed: _onExpanded,
            ),
          ]),
        ),
      );
    } else {
      return InkWell(
          onTap: _onListTileTap,
          onLongPress: _onLongPress,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Row(children: [
                    Expanded(child: content()),
                    IconButton(
                      tooltip: 'Expand Card',
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      alignment: Alignment.center,
                      icon: const Icon(Icons.expand_less),
                      onPressed: _onExpanded,
                    ),
                  ]),
                ),
                Stack(children: [
                  ButtonBar(alignment: MainAxisAlignment.start, children: [
                    FlatButton(
                      textColor: searchThemeColor,
                      // icon: RotatedBox(
                      //   quarterTurns: 1,
                      //   child: Icon(widget.res.contextExpanded ? Icons.unfold_less : Icons.unfold_more),
                      // ),
                      child: Text(
                        widget.res.contextExpanded ? 'Hide Context' : 'Context',
                        semanticsLabel:
                            widget.res.contextExpanded ? 'Collapse Context' : 'Expand Context',
                        textScaleFactor: contentTextScaleFactorWith(context),
                      ),
                      onPressed: _onContext,
                    ),
                  ]),
                  ButtonBar(
                    children: <Widget>[
                      IconButton(
                          tooltip: 'Copy',
                          icon: const Icon(Icons.content_copy, size: 20),
                          onPressed: _onCopy),
                      IconButton(
                          tooltip: 'Share',
                          icon: const Icon(FeatherIcons.share2, size: 20),
                          onPressed: _onShare),
                      IconButton(
                          tooltip: 'Open in TecartaBible',
                          icon: const Icon(TecIcons.tbOutlineLogo),
                          onPressed: _openInTB),
                    ],
                  ),
                ]),
                _TranslationSelector(widget.res, _changeTranslation)
              ],
            ),
          ));
    }
  }
}

class _TranslationSelector extends StatefulWidget {
  final SearchResultInfo res;
  final Function(int) changeTranslation;
  const _TranslationSelector(this.res, this.changeTranslation);
  @override
  __TranslationSelectorState createState() => __TranslationSelectorState();
}

class __TranslationSelectorState extends State<_TranslationSelector> {
  @override
  void initState() {
    super.initState();
  }

  void _changeTranslation(int i) {
    widget.changeTranslation(i);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final selectedTextColor =
        Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    final allButton = ButtonTheme(
        minWidth: 50,
        child: Semantics(
          container: true,
          label: 'View all translations',
          child: FlatButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Text(
              'ALL',
              textScaleFactor: contentTextScaleFactorWith(context),
            ),
            onPressed: () async {
              final volumeId =
                  await showCompareSheet(context, Reference.fromHref(widget.res.searchResult.href));
              if (volumeId != null) {
                Navigator.of(context).pop(
                    Reference.fromHref(widget.res.searchResult.href).copyWith(volume: volumeId));
              }
            },
            textColor: selectedTextColor,
            splashColor: searchThemeColor,
          ),
        ));

    final buttons = <ButtonTheme>[];
    final verses = widget.res.searchResult.verses;
    for (var i = 0; i < verses.length; i++) {
      final each = verses[i];
      Color buttonColor;
      Color textColor;
      final curr = widget.res.searchResult.verses[widget.res.currentVerseIndex].id;

      buttonColor = curr == each.id ? searchThemeColor : Colors.transparent;
      textColor = curr == each.id ? Theme.of(context).cardColor : selectedTextColor;

      buttons.add(ButtonTheme(
        minWidth: 50,
        child: Semantics(
          container: true,
          label: curr == each.id ? '${each.a} selected' : 'Select ${each.a}',
          child: FlatButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Text(
              each.a,
              textScaleFactor: contentTextScaleFactorWith(context),
            ),
            textColor: textColor,
            color: buttonColor, //currently chosen, pass tag
            onPressed: () => _changeTranslation(i),
          ),
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Wrap(
        alignment: WrapAlignment.start,
        children: buttons..add(allButton),
      ),
    );
  }
}

class SearchResultsLabel extends StatelessWidget {
  final List<SearchResult> results;
  final bool navView;

  const SearchResultsLabel(this.results, {this.navView = false});

  @override
  Widget build(BuildContext context) {
    final searchBlocState = context.bloc<SearchBloc>().state;
    final bible = VolumesRepository.shared.bibleWithId(Const.defaultBible);
    var book = bible.firstBook;
    // ignore: prefer_collection_literals
    final booksSelected = LinkedHashMap<int, String>();
    // ignore: prefer_collection_literals
    final books = LinkedHashMap<int, String>();

    while (book != 0) {
      books[book] = bible.nameOfBook(book);
      if (!searchBlocState.excludedBooks.contains(book)) {
        booksSelected[book] = bible.nameOfBook(book);
      }
      final nextBook = bible.bookAfter(book);
      book = (nextBook == book ? 0 : nextBook);
    }

    var showOTLabel = true;
    var showNTLabel = true;
    final ot = books.keys.where(bible.isOTBook).toList();
    final nt = books.keys.where(bible.isNTBook).toList();
    for (final o in ot) {
      if (searchBlocState.excludedBooks.contains(o)) {
        showOTLabel = false;
      }
    }

    for (final n in nt) {
      if (searchBlocState.excludedBooks.contains(n)) {
        showNTLabel = false;
      }
    }

    if (showNTLabel && booksSelected.keys.any(bible.isOTBook)) {
      showNTLabel = false;
    }

    if (showOTLabel && booksSelected.keys.any(bible.isNTBook)) {
      showOTLabel = false;
    }

    if (showNTLabel && showOTLabel) {
      showNTLabel = false;
      showOTLabel = false;
    }

    return Container(
        padding: navView ? EdgeInsets.zero : const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TecText.rich(
            TextSpan(
              style: Theme.of(context).textTheme.caption,
              children: [
                TextSpan(
                    text: '${navView ? '' : 'Showing'}'
                        ' ${results.length} verse${results.length > 1 ? 's' : ''} containing '),
                TextSpan(
                    text: '${context.bloc<SearchBloc>().state.search}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (searchBlocState.excludedBooks.isNotEmpty)
                  if (showOTLabel)
                    const TextSpan(text: ' in the Old Testament')
                  else if (showNTLabel)
                    const TextSpan(text: ' in the New Testament')
                  else if (booksSelected.length <= 5)
                    TextSpan(
                      text: ' in ${booksSelected.values.join(', ')}',
                    )
                  else
                    const TextSpan(text: ' in current filter')
              ],
            ),
            textScaleFactor: contentTextScaleFactorWith(context),
          ),
        ));
  }
}

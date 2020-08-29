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
import '../../models/pref_item.dart';
import '../../models/search/context.dart';
import '../../models/search/search_result.dart';
import '../../models/search/tec_share.dart';
import '../common/common.dart';
import '../sheet/selection_sheet_model.dart';

enum SearchAndHistoryTabs { history, search }

class SearchAndHistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO(abby): if no search results currently, do most recent search or focus on textfield
    return DefaultTabController(
      initialIndex: context.bloc<NavBloc>().state.tabIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          flexibleSpace: Center(
            child: TabBar(
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BubbleTabIndicator(color: Colors.blue.withOpacity(0.5)),
                labelColor: Theme.of(context).textColor.withOpacity(0.7),
                unselectedLabelColor: Theme.of(context).textColor.withOpacity(0.7),
                tabs: const [Tab(child: Text('HISTORY')), Tab(child: Text('SEARCH RESULTS'))]),
          ),
        ),
        body: TabBarView(children: [HistoryView(), SearchResultsView()]),
      ),
    );
  }
}

class HistoryView extends StatelessWidget {
  // only showing nav history currently
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavBloc, NavState>(builder: (c, s) {
      final history = s.history..sort((a, b) => b.modified.compareTo(a.modified));
      return ListView.separated(
        itemCount: history.length,
        separatorBuilder: (c, i) => const Divider(height: 5),
        itemBuilder: (c, i) => ListTile(
          dense: true,
          leading: const Icon(Icons.history),
          title: Text(history[i].label()),
          subtitle: Text(
              '${tec.shortDate(history[i].modified)}, ${history[i].modified.hour}:${history[i].modified.minute}'),
          onTap: () {
            Navigator.of(context).maybePop<Reference>(history[i]);
          },
        ),
      );
    });
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
    positionListener = ItemPositionsListener.create();
    scrollController = ItemScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchBloc, SearchState>(
        listener: (c, s) {
          // TODO(abby): save search and scroll position
        },
        listenWhen: (s1, s2) => s1.search != s2.search,
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: LoadingIndicator());
          } else if (state.error) {
            return const Center(
              child: Text('Error'),
            );
          } else if (state.searchResults.isEmpty) {
            return const Center(
              child: Text('No Results'),
            );
          }
          return SafeArea(
            bottom: false,
            child: Scaffold(
              body: ScrollablePositionedList.separated(
                itemCount: state.searchResults.length + 1,
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
                    return SearchResultsLabel(
                        state.searchResults.map((r) => r.searchResult).toList());
                  }
                  i--;
                  final res = state.searchResults[i];
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
      TecShare.shareWithLink(
          widget.res.shareText, Reference.fromHref(widget.res.searchResult.href));
    } else {
      TecShare.share(widget.res.shareText);
    }
  }

  void _onCopy() {
    if (_includeShareLink) {
      TecShare.copyWithLink(
          context, widget.res.shareText, Reference.fromHref(widget.res.searchResult.href));
    } else {
      TecShare.copy(context, widget.res.shareText);
    }
  }

  void _openInTB() {
    Navigator.of(context).pop(Reference.fromHref(widget.res.searchResult.href,
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

  @override
  Widget build(BuildContext context) {
    final textColor =
        widget.res.selected ? Theme.of(context).accentColor : Theme.of(context).textColor;
    Widget content() => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TecText.rich(
          TextSpan(
              children: searchResTextSpans(
                widget.res.currentText,
                context.bloc<SearchBloc>().state.search,
              ),
              style: TextStyle(color: textColor)),
        ));
    Widget label() => Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 5),
        child: Text(widget.res.label,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500)));

    if (!widget.res.expanded) {
      return ListTile(
        title: label(),
        subtitle: content(),
        onTap: _onListTileTap,
        trailing: IconButton(
          tooltip: 'Expand Card',
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          alignment: Alignment.bottomRight,
          padding: const EdgeInsets.all(0),
          icon: const Icon(Icons.expand_more),
          onPressed: _onExpanded,
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: label(),
            subtitle: content(),
            onTap: _onListTileTap,
            trailing: IconButton(
              tooltip: 'Collapse Card',
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(0),
              icon: const Icon(Icons.expand_less),
              onPressed: _onExpanded,
            ),
          ),
          Stack(children: [
            ButtonBar(alignment: MainAxisAlignment.start, children: [
              FlatButton(
                // icon: RotatedBox(
                //   quarterTurns: 1,
                //   child: Icon(widget.res.contextExpanded ? Icons.unfold_less : Icons.unfold_more),
                // ),
                child: Text('Context',
                    semanticsLabel:
                        widget.res.contextExpanded ? 'Collapse Context' : 'Expand Context'),
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
      );
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
            child: const Text('ALL'),
            onPressed: () =>
                showCompareSheet(context, Reference.fromHref(widget.res.searchResult.href)),
            textColor: selectedTextColor,
            splashColor: Theme.of(context).accentColor,
          ),
        ));

    final buttons = <ButtonTheme>[];
    final verses = widget.res.searchResult.verses;
    for (var i = 0; i < verses.length; i++) {
      final each = verses[i];
      Color buttonColor;
      Color textColor;
      final curr = widget.res.searchResult.verses[widget.res.currentVerseIndex].id;

      buttonColor = curr == each.id ? Theme.of(context).accentColor : Colors.transparent;
      textColor = curr == each.id ? Theme.of(context).cardColor : selectedTextColor;

      buttons.add(ButtonTheme(
        minWidth: 50,
        child: Semantics(
          container: true,
          label: curr == each.id ? '${each.a} selected' : 'Select ${each.a}',
          child: FlatButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Text(each.a),
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
    return Container(
        padding: navView ? EdgeInsets.zero : const EdgeInsets.fromLTRB(15, 10, 15, 0),
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
                // if (vm.filterOn)
                //   if (vm.showOTLabel)
                //     const TextSpan(text: ' in the Old Testament')
                //   else if (vm.showNTLabel)
                //     const TextSpan(text: ' in the New Testament')
                //   else if (vm.booksSelected.length <= 5)
                //     TextSpan(
                //       text: ' in ${vm.booksSelected.map((b) {
                //         return b.name;
                //       }).join(', ')}',
                //     )
                //   else
                //     const TextSpan(text: ' in current filter')
              ],
            ),
          ),
        ));
  }
}

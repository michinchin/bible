import 'package:bible/models/search/context.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/search/nav_bloc.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/pref_item.dart';
import '../../models/search/search_result.dart';
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
  // void onSelected(SearchResult searchResult, {bool selected}) {
  //   final includeShareLink = context.bloc<PrefItemsBloc>().itemBool(PrefItemId.includeShareLink);
  //   if (selected) {
  //     context.bloc<SearchBloc>().addSelected();
  //   } else {
  //     context.bloc<SearchBloc>().removeSelected;
  //   }

  //   updateSelected
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(builder: (context, state) {
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
          body: ListView.separated(
            itemCount: state.searchResults.length + 1,
            separatorBuilder: (c, i) {
              if (i == 0) {
                return const SizedBox(height: 0);
              }
              i--;
              return const Divider(height: 5);
            },
            itemBuilder: (c, i) {
              if (i == 0) {
                return SearchResultsLabel(state.searchResults);
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
  final SearchResult res;
  const _SearchResultCard(this.res);

  @override
  __SearchResultCardState createState() => __SearchResultCardState();
}

class __SearchResultCardState extends State<_SearchResultCard> {
  bool _expanded;
  bool _contextShown;
  bool _selected;
  int _verseIndex;
  // Map<int, Context> _contextMap;
  // Future<Context> _contextFuture;

  @override
  void initState() {
    _expanded = false;
    _contextShown = false;
    _selected = false;
    _verseIndex = 0;
    super.initState();
  }

  void _changeTranslation(int verseIndex) {
    setState(() {
      _verseIndex = verseIndex;
    });
  }

  void _onContext() async {
    // _contextFuture ??= Context.fetch(
    //   translation: widget.res.verses[_verseIndex].id,
    //   book: widget.res.bookId,
    //   chapter: widget.res.chapterId,
    //   verse: widget.res.verseId,
    //   content: widget.res.verses[_verseIndex].verseContent,
    // );
    TecToast.show(context, 'in progress');
    setState(() {
      _contextShown = !_contextShown;
    });
  }

  void _onExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _onShare() {
    TecToast.show(context, 'in progress');
  }

  void _onCopy() {
    TecToast.show(context, 'in progress');
  }

  void _openInTB() {
    Navigator.of(context)
        .pop(Reference.fromHref(widget.res.href, volume: widget.res.verses[_verseIndex].id));
    tec.dmPrint('Navigating to verse: ${widget.res.href}');
  }

  void _onListTileTap() {
    final selectionMode = context.bloc<SearchBloc>().state.selectionMode;
    if (selectionMode) {
      setState(() {
        _selected = !_selected;
      });
    } else {
      _onExpanded();
    }
  }

  String get _label =>
      //  _contextShown && _context != null
      // ? '${widget.res.ref.split(':')[0]}:'
      // '${_context.initialVerse}-${_context.finalVerse}'
      // ' ${widget.res.verses[_verseIndex].a}'
      // :
      '${widget.res.ref} ${widget.res.verses[_verseIndex].a}';
  String get _currentText =>
      // _contextShown && _context != null
      // ? _context.text
      // :
      widget.res.verses[_verseIndex].verseContent;

  @override
  Widget build(BuildContext context) {
    final textColor = _selected ? Theme.of(context).accentColor : Theme.of(context).textColor;
    Widget content() => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TecText.rich(
          TextSpan(
              children: searchResTextSpans(
                _currentText,
                context.bloc<SearchBloc>().state.search,
              ),
              style: TextStyle(color: textColor)),
        ));
    Widget label() => Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 5),
        child: Text(_label, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)));

    if (!_expanded) {
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
                child: Text('Context',
                    semanticsLabel: _contextShown ? 'Collapse Context' : 'Expand Context'),
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
  final SearchResult res;
  final Function(int) changeTranslation;
  const _TranslationSelector(this.res, this.changeTranslation);
  @override
  __TranslationSelectorState createState() => __TranslationSelectorState();
}

class __TranslationSelectorState extends State<_TranslationSelector> {
  int verseIndex;
  @override
  void initState() {
    verseIndex = 0;
    super.initState();
  }

  void _changeTranslation(int i) {
    widget.changeTranslation(i);
    setState(() {
      verseIndex = i;
    });
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
            onPressed: () => showCompareSheet(context, Reference.fromHref(widget.res.href)),
            textColor: selectedTextColor,
            splashColor: Theme.of(context).accentColor,
          ),
        ));

    final buttons = <ButtonTheme>[];
    final verses = widget.res.verses;
    for (var i = 0; i < verses.length; i++) {
      final each = verses[i];
      Color buttonColor;
      Color textColor;
      final curr = widget.res.verses[verseIndex].id;

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

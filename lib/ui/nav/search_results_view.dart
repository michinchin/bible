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
import '../../blocs/search/search_result_bloc.dart';
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

class SearchResultsView extends StatelessWidget {
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
          body: ListView.builder(
            addAutomaticKeepAlives: false,
            itemCount: state.searchResults.length + 1,
            itemBuilder: (c, i) {
              if (i == 0) {
                return SearchResultsLabel(state.searchResults);
              }
              i--;
              final res = state.searchResults[i];
              return BlocProvider(
                  create: (_) => SearchResultBloc(
                        res,
                        shareUrl:
                            context.bloc<PrefItemsBloc>().itemBool(PrefItemId.includeShareLink),
                      ),
                  child: const _SearchResultCard());
            },
          ),
        ),
      );
    });
  }
}

class _SearchResultCard extends StatefulWidget {
  const _SearchResultCard();

  @override
  __SearchResultCardState createState() => __SearchResultCardState();
}

class __SearchResultCardState extends State<_SearchResultCard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchResultBloc, SearchResultState>(
      builder: (c, s) => TecCard(
        color: Theme.of(context).cardColor,
        padding: 10,
        builder: (c) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Theme(
              data: Theme.of(c).copyWith(
                  dividerColor: Colors.transparent,
                  accentColor: Theme.of(c).textColor,
                  iconTheme: Theme.of(c).iconTheme.copyWith(color: Theme.of(c).textColor)),
              child: ExpansionTile(
                  // leading: selectionMode
                  //     ? IconButton(
                  //         icon: s.selected
                  //             ? Icon(
                  //                 Icons.check_circle_outline,
                  //                 color: Theme.of(c).accentColor,
                  //               )
                  //             : Icon(Icons.panorama_fish_eye),
                  //         onPressed: () {
                  //           c.bloc<SearchResultBloc>().add(const SearchResultEvent.select());
                  //           c.bloc<SearchBloc>().add(SearchEvent.selectResult(searchResult: s.res));
                  //         })
                  //     : null,
                  title: Text(
                    s?.label ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  childrenPadding: EdgeInsets.zero,
                  subtitle: s.contextLoading
                      ? const LoadingIndicator()
                      : TecText.rich(TextSpan(
                          children: searchResTextSpans(c.bloc<SearchResultBloc>().currentText,
                              c.bloc<SearchBloc>().state.search))),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: RotatedBox(
                                quarterTurns: 1,
                                child:
                                    Icon(s.contextShown ? Icons.unfold_less : Icons.unfold_more)),
                            onPressed: () => c
                                .bloc<SearchResultBloc>()
                                .add(const SearchResultEvent.showContext()),
                          ),
                          ButtonBar(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  FeatherIcons.copy,
                                  size: 20,
                                ),
                                onPressed: () => c
                                    .bloc<SearchResultBloc>()
                                    .add(SearchResultEvent.copy(context: c)),
                              ),
                              IconButton(
                                icon: const Icon(
                                  FeatherIcons.share,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    c.bloc<SearchResultBloc>().add(const SearchResultEvent.share()),
                              ),
                              IconButton(
                                icon: const Icon(TecIcons.tbOutlineLogo),
                                onPressed: () => c
                                    .bloc<SearchResultBloc>()
                                    .add(SearchResultEvent.openInTB(context: c)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TranslationSelector(),
                        ]),
                  ])),
        ),
      ),
    );
  }
}

class _TranslationSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final bloc = context.bloc<SearchResultBloc>();
    final textColor = Theme.of(context).textColor;
    final selectedTextColor =
        Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    final isSelected = context.bloc<SearchBloc>().isSelected(bloc.state.res);
    final allButton = ButtonTheme(
        minWidth: 50,
        child: Semantics(
          container: true,
          label: 'View all translations',
          child: FlatButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const Text('ALL'),
            onPressed: () => showCompareSheet(context, Reference.fromHref(bloc.state.res.href)),
            textColor: isSelected ? textColor : selectedTextColor,
            splashColor: isSelected ? Colors.transparent : Theme.of(context).accentColor,
          ),
        ));

    final buttons = <ButtonTheme>[];
    final verses = bloc.state.res.verses;
    for (var i = 0; i < verses.length; i++) {
      final each = verses[i];
      Color buttonColor;
      Color textColor;
      final curr = bloc.state.res.verses[bloc.state.verseIndex].id;
      if (isSelected) {
        buttonColor = curr == each.id ? Theme.of(context).cardColor : Theme.of(context).accentColor;
        textColor = curr == each.id ? textColor : selectedTextColor;
      } else {
        buttonColor = curr == each.id ? Theme.of(context).accentColor : Colors.transparent;
        textColor = curr == each.id ? Theme.of(context).cardColor : selectedTextColor;
      }

      buttons.add(ButtonTheme(
        minWidth: 50,
        child: Semantics(
          container: true,
          label: curr == each.id ? '${each.a} selected' : 'Select ${each.a}',
          child: FlatButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(each.a),
            textColor: textColor,
            color: buttonColor, //currently chosen, pass tag
            onPressed: () => bloc.add(SearchResultEvent.onTranslationChange(idx: i)),
          ),
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Wrap(alignment: WrapAlignment.spaceAround, children: buttons..add(allButton)),
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

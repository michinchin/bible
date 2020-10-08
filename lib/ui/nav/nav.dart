import 'dart:async';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/search/nav_bloc.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/pref_item.dart';
import '../../models/search/tec_share.dart';
import '../common/common.dart';
import '../library/library.dart';
import 'bcv_tab.dart';
import 'search_and_history_view.dart';
import 'search_filter.dart';
import 'search_suggestions.dart';

const tabColors = [Colors.blue, Colors.orange, Colors.green];

Future<Reference> navigate(BuildContext context, Reference ref, {int initialIndex = 0}) {
  final isLargeScreen =
      MediaQuery.of(context).size.width > 500 && MediaQuery.of(context).size.height > 600;
  if (isLargeScreen) {
    return showTecDialog<Reference>(
      context: context,
      useRootNavigator: true,
      cornerRadius: 15,
      builder: (context) => Container(
          height: 600,
          width: 500,
          child: MultiBlocProvider(providers: [
            BlocProvider<NavBloc>(create: (_) => NavBloc(ref, initialTabIndex: initialIndex)),
          ], child: Nav())),
    );
  }

  // Other ways we could show the nav UI:
//  return showTecModalPopup<BookChapterVerse>(
//       context: context,
//       alignment: Alignment.center,
//       // useRootNavigator: false,
//       builder: (context) => TecPopupSheet(
//           child: BlocProvider(
//               create: (context) => NavBloc(bcv),
//               child: Container(height: 600, width: 500, child: Nav()))),

  return Navigator.of(context, rootNavigator: true).push<Reference>(TecPageRoute<Reference>(
    fullscreenDialog: true,
    builder: (context) => MultiBlocProvider(providers: [
      BlocProvider<NavBloc>(create: (_) => NavBloc(ref, initialTabIndex: initialIndex)),
    ], child: Nav()),
  ));
}

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

const maxTabsAvailable = 3;
const minTabsAvailable = 2;

class _NavState extends State<Nav> with TickerProviderStateMixin {
  TabController _tabController;
  TabController _searchResultsTabController;
  TextEditingController _searchController;

  NavBloc navBloc() => context.bloc<NavBloc>();

  PrefItemsBloc prefsBloc() => context.bloc<PrefItemsBloc>();

  SearchBloc searchBloc() => context.bloc<SearchBloc>();

  List<int> translations() => prefsBloc()
      .state
      .items
      .itemWithId(PrefItemId.translationsFilter)
      .info
      .split('|')
      .map(int.parse)
      .toList();

  @override
  void initState() {
    _searchController = TextEditingController(text: '');
    final nav3TapEnabled = context.bloc<PrefItemsBloc>().itemBool(PrefItemId.nav3Tap);
    final tabLength = nav3TapEnabled ? maxTabsAvailable : minTabsAvailable;

    _searchResultsTabController = TabController(length: 2, initialIndex: 0, vsync: this)
      ..addListener(() {
        if (_searchResultsTabController.index == 0) {
          if (searchBloc().state.selectionMode) {
            searchBloc().add(const SearchEvent.selectionModeToggle());
          }
        }
        setState(() {});
      });

    // tab controller that updates position based on navbloc
    _tabController =
        TabController(length: tabLength, initialIndex: navBloc().state.tabIndex, vsync: this)
          ..addListener(() {
            if (_tabController.index != navBloc().state.tabIndex) {
              navBloc().add(NavEvent.changeTabIndex(index: _tabController.index));
            }
          });
    super.initState();
  }

  @override
  void deactivate() {
    // _tabController.dispose();
    super.deactivate();
  }

  void _changeTabController() {
    final nav3TapEnabled = context.bloc<PrefItemsBloc>().itemBool(PrefItemId.nav3Tap);
    final tabLength = nav3TapEnabled ? maxTabsAvailable : minTabsAvailable;
    setState(() {
      _tabController =
          TabController(length: tabLength, initialIndex: navBloc().state.tabIndex, vsync: this)
            ..addListener(() {
              if (_tabController.index != navBloc().state.tabIndex) {
                navBloc().add(NavEvent.changeTabIndex(index: _tabController.index));
              }
            });
    });
  }

  void onSubmit({String query}) {
    final s = query ?? _searchController.text;
    navBloc().add(NavEvent.onSearchFinished(search: s));
    FocusScope.of(context).unfocus();
    if (s.isNotEmpty) {
      searchBloc()
        ..add(SearchEvent.request(search: s, translations: translations()))
        ..add(const SearchEvent.setScrollIndex(0));
    }
    _searchResultsTabController.animateTo(1);
  }

  void _selectionMode() {
    final selectionModeOn = !context.bloc<SearchBloc>().state.selectionMode;
    if (selectionModeOn) {
      TecToast.show(context, 'Entered Selection Mode');
    }
    context.bloc<SearchBloc>().add(const SearchEvent.selectionModeToggle());
  }

  void _onSelectionCopied() {
    final verses = context.bloc<SearchBloc>().state.filteredResults.where((s) => s.selected);
    if (verses.isNotEmpty) {
      TecShare.copy(context, verses.map((v) => v.shareText).join('\n\n'));
    }
  }

  void _onSelectionShared() {
    final verses = context.bloc<SearchBloc>().state.filteredResults.where((s) => s.selected);
    if (verses.isNotEmpty) {
      TecShare.share(verses.map((v) => v.shareText).join('\n\n'));
    }
  }

  Future<void> _filter() => showFilter(context,
      filter: const VolumesFilter(volumeType: VolumeType.bible),
      selectedVolumes: translations(),
      filteredBooks: searchBloc().state.excludedBooks,
      searchController: _searchController);

  void _moreButton() => showModalBottomSheet<void>(
      barrierColor: Colors.black12,
      elevation: 10,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
      context: context,
      builder: (c) => BlocBuilder<PrefItemsBloc, PrefItems>(
          cubit: prefsBloc(),
          builder: (context, state) {
            final items = state?.items ?? [];
            final navGridViewEnabled = items.boolForPrefItem(PrefItemId.navLayout);
            final nav3TapEnabled = items.boolForPrefItem(PrefItemId.nav3Tap);
            final navCanonical = items.boolForPrefItem(PrefItemId.navBookOrder);
            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Text(navCanonical
                        ? 'Show books alphabetically'
                        : 'Show books in canonical order'),
                    onTap: () {
                      navBloc()
                        ..add(NavEvent.changeTabIndex(index: NavTabs.book.index))
                        ..add(const NavEvent.onSearchChange(search: ''));
                      prefsBloc().add(PrefItemEvent.update(
                          prefItem: prefsBloc().toggledPrefItem(PrefItemId.navBookOrder)));
                    },
                  ),
                  ListTile(
                    title: Text(
                        navGridViewEnabled ? 'Show full name for books' : 'Show abbreviated books'),
                    onTap: () {
                      navBloc()
                        ..add(NavEvent.changeTabIndex(index: NavTabs.book.index))
                        ..add(const NavEvent.onSearchChange(search: ''));
                      prefsBloc().add(PrefItemEvent.update(
                          prefItem: prefsBloc().toggledPrefItem(PrefItemId.navLayout)));
                    },
                  ),
                  ListTile(
                    title: Text(
                        nav3TapEnabled ? 'Show book and chapter' : 'Show book, chapter, and verse'),
                    onTap: () {
                      prefsBloc().add(PrefItemEvent.update(
                          prefItem: prefsBloc().toggledPrefItem(PrefItemId.nav3Tap)));
                    },
                  ),
                ],
              ),
            );
          }));

  @override
  Widget build(BuildContext context) {
    Widget body(NavViewState navViewState) {
      switch (navViewState) {
        case NavViewState.bcvTabs:
          return BCVTabView(
            listener: (c, s) => _changeTabController(),
            tabController: _tabController,
            searchController: _searchController,
          );
        case NavViewState.searchSuggestions:
          return SearchSuggestionsView(
            searchController: _searchController,
            onSubmit: onSubmit,
          );
        case NavViewState.searchResults:
          return SearchAndHistoryView(_searchController, _searchResultsTabController);
      }
      return Container();
    }

    Widget leadingAppBarIcon(BuildContext c, NavViewState s, SearchState ss) {
      if (s == NavViewState.searchResults &&
          ss.selectionMode &&
          _searchResultsTabController.index == 1) {
        return CloseButton(onPressed: _selectionMode);
      } else if (s == NavViewState.bcvTabs) {
        return const CloseButton();
      } else {
        return BackButton(onPressed: () {
          c.bloc<NavBloc>()
            ..add(const NavEvent.changeNavView(state: NavViewState.bcvTabs))
            ..add(NavEvent.changeTabIndex(index: NavTabs.book.index))
            ..add(const NavEvent.onSearchChange(search: ''));
        });
      }
    }

    Widget titleAppBar(BuildContext c, NavViewState s, SearchState ss) {
      if (s == NavViewState.searchResults && ss.selectionMode) {
        final length = ss.filteredResults.where((s) => s.selected).length;
        return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$length',
              style: Theme.of(context).textTheme.bodyText1,
            ));
      } else if (s == NavViewState.searchResults && _searchResultsTabController.index == 0) {
        return const Text('History');
      } else {
        return TextField(
            onChanged: (s) => navBloc().add(NavEvent.onSearchChange(search: s)),
            onSubmitted: (s) => onSubmit(query: s),
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter references or keywords',
                hintStyle: TextStyle(fontStyle: FontStyle.italic)),
            controller: _searchController);
      }
    }

    List<Widget> appBarActions(BuildContext c, NavState s, SearchState ss) {
      if (s.navViewState == NavViewState.bcvTabs) {
        if (s.tabIndex != NavTabs.book.index) {
          return [
            FlatButton(
                child: Text(
                  'GO',
                  style: TextStyle(color: tabColors[s.tabIndex]),
                ),
                onPressed: () => Navigator.of(context).maybePop(s.ref))
          ];
        } else {
          return [
            IconButton(
                icon: const Icon(Icons.youtube_searched_for),
                onPressed: () {
                  c
                      .bloc<NavBloc>()
                      .add(const NavEvent.changeNavView(state: NavViewState.searchResults));
                  _searchResultsTabController.animateTo(0);
                }),
            IconButton(icon: Icon(platformAwareMoreIcon(context)), onPressed: _moreButton)
          ];
        }
      } else if (s.navViewState == NavViewState.searchResults) {
        if (ss.selectionMode) {
          return [
            IconButton(icon: const Icon(Icons.copy, size: 20), onPressed: _onSelectionCopied),
            IconButton(
                icon: const Icon(FeatherIcons.share2, size: 20), onPressed: _onSelectionShared)
          ];
        } else if (_searchResultsTabController.index == 1) {
          return [
            if (ss.filteredResults.isNotEmpty)
              IconButton(icon: const Icon(Icons.check_circle_outline), onPressed: _selectionMode),
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _filter)
          ];
        }
      }
      return [];
    }

    return BlocConsumer<NavBloc, NavState>(
      listener: (c, s) {
        // tec.dmPrint(
        //     'Change from listener:\nstate search:${s.search}\nsearchController:${_searchController.text}');
        if (s.tabIndex < _tabController.length && s.tabIndex != _tabController.index) {
          _tabController.animateTo(s.tabIndex);
        }
      },
      builder: (c, s) => TecScaffoldWrapper(
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (c, ss) => Scaffold(
              appBar: AppBar(
                elevation: 5,
                backgroundColor: Theme.of(context).cardColor,
                title: titleAppBar(c, s.navViewState, ss),
                titleSpacing: 0,
                leading: leadingAppBarIcon(c, s.navViewState, ss),
                actions: appBarActions(c, s, ss),
              ),
              body: body(s.navViewState)),
        ),
      ),
    );
  }
}

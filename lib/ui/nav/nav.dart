import 'dart:async';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedantic/pedantic.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/prefs_bloc.dart';
import '../../blocs/search/nav_bloc.dart';
import '../../blocs/search/search_bloc.dart';
import '../../models/pref_item.dart';
import '../../models/search/tec_share.dart';
import '../../models/user_item_helper.dart';
import '../common/common.dart';
import '../library/library.dart';
import 'bcv_tab.dart';
import 'search_and_history_view.dart';
import 'search_filter.dart';
import 'search_suggestions.dart';

const tabColors = [Colors.blue, Colors.orange, Colors.green];

Future<void> showNavigate(BuildContext context,
    {int initialIndex = 0, bool searchView = false}) async {
  TecAutoScroll.stopAutoscroll();

  final ref = await navigate(context, Reference.fromHref('50/1/1', volume: 9),
      initialIndex: initialIndex, searchView: searchView);

  if (ref != null) {
    // Save navigation ref to nav history.
    unawaited(UserItemHelper.saveNavHistoryItem(ref));

    // Small delay to allow the nav popup to clean up...
    await Future.delayed(const Duration(milliseconds: 350), () {
      // final newViewData =
      // viewData.copyWith(bcv: BookChapterVerse.fromRef(ref), volumeId: ref.volume);
      // tec.dmPrint('VolumeViewActionBar _onNavigate updating with new data: $newViewData');
      // context.read<VolumeViewDataBloc>().update(context, newViewData);
    });
  }
}

Future<Reference> navigate(BuildContext context, Reference ref,
    {int initialIndex = 0, bool searchView = false}) {
  // dummy tec reference to remove import warning
  tec.today;

  final hasSearchResults = context.tbloc<SearchBloc>().state.searchResults.isNotEmpty;
  return showTecDialog<Reference>(
    context: context,
    useRootNavigator: true,
    makeScrollable: false,
    padding: EdgeInsets.zero,
    maxWidth: 500,
    maxHeight: 600,
    builder: (context) => MultiBlocProvider(providers: [
      BlocProvider<NavBloc>(
          create: (_) => NavBloc(ref, initialTabIndex: initialIndex)
            ..add(NavEvent.changeNavView(
                state: searchView && hasSearchResults
                    ? NavViewState.searchResults
                    : NavViewState.bcvTabs))),
    ], child: Nav(searchView: searchView)),
  );
}

/// show search with requested search string, returns `Reference` in case of nav
Future<Reference> showBibleSearch(BuildContext context, Reference ref,
    {String search = '', bool showHistory = false}) {
  if (search.isNotEmpty) {
    final translations =
        PrefsBloc.getString(PrefItemId.translationsFilter).split('|').map(int.parse).toList();
    context
        .tbloc<SearchBloc>()
        ?.add(SearchEvent.request(search: search, translations: translations));
  }
  return showTecDialog<Reference>(
      context: context,
      useRootNavigator: true,
      padding: EdgeInsets.zero,
      maxWidth: 500,
      maxHeight: 600,
      builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<NavBloc>(
                    create: (_) => NavBloc(ref)
                      ..add(const NavEvent.changeNavView(state: NavViewState.searchResults))),
              ],
              child: Nav(
                searchView: true,
                showHistory: showHistory,
              )));
}

class Nav extends StatefulWidget {
  /// if set to `true`, will focus `TextField` immediately when no search results present
  final bool searchView;
  final bool showHistory;

  const Nav({Key key, this.searchView, this.showHistory = false}) : super(key: key);

  @override
  _NavState createState() => _NavState();
}

const maxTabsAvailable = 3;
const minTabsAvailable = 2;

class _NavState extends State<Nav> with TickerProviderStateMixin {
  TabController _tabController;
  TabController _searchResultsTabController;
  TextEditingController _searchController;

  NavBloc navBloc() => context.tbloc<NavBloc>();

  SearchBloc searchBloc() => context.tbloc<SearchBloc>();

  List<int> translations() =>
      PrefsBloc.getString(PrefItemId.translationsFilter).split('|').map(int.parse).toList();

  Function() _searchListener;
  Timer _debounce;

  @override
  void initState() {
    _searchController = TextEditingController(text: '');
    final nav3TapEnabled = PrefsBloc.getBool(PrefItemId.nav3Tap);
    final tabLength = nav3TapEnabled ? maxTabsAvailable : minTabsAvailable;

    _searchResultsTabController =
        TabController(length: 2, initialIndex: widget.showHistory ? 1 : 0, vsync: this)
          ..addListener(() {
            if (_searchResultsTabController.index == 1) {
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
    _searchListener = () {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 250), () {
        if (navBloc().state.search != _searchController.text) {
          // tec.dmPrint('/nTESTING:${_searchController.text}/n');
          navBloc().add(NavEvent.onSearchChange(search: _searchController.text));
        }
      });
    };
    _searchController.addListener(_searchListener);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController
      ..removeListener(_searchListener)
      ..dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _changeTabController() {
    final nav3TapEnabled = PrefsBloc.getBool(PrefItemId.nav3Tap);
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
    _searchResultsTabController.animateTo(0);
  }

  void _selectionMode() {
    final selectionModeOn = !context.tbloc<SearchBloc>().state.selectionMode;
    if (selectionModeOn) {
      TecToast.show(context, 'Entered Selection Mode');
    }
    context.tbloc<SearchBloc>().add(const SearchEvent.selectionModeToggle());
  }

  void _onSelectionCopied() {
    final verses = context.tbloc<SearchBloc>().state.filteredResults.where((s) => s.selected);
    if (verses.isNotEmpty) {
      TecShare.copy(context, verses.map((v) => v.shareText).join('\n\n'));
    }
  }

  void _onSelectionShared() {
    final verses = context.tbloc<SearchBloc>().state.filteredResults.where((s) => s.selected);
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
      barrierColor: barrierColorWithContext(context),
      elevation: 10,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
      context: context,
      builder: (c) => BlocBuilder<PrefsBloc, PrefBlocState>(builder: (context, state) {
            final navGridViewEnabled = PrefsBloc.getBool(PrefItemId.navLayout);
            final nav3TapEnabled = PrefsBloc.getBool(PrefItemId.nav3Tap);
            final navCanonical = PrefsBloc.getBool(PrefItemId.navBookOrder);
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
                      PrefsBloc.toggle(PrefItemId.navBookOrder);
                    },
                  ),
                  ListTile(
                    title: Text(
                        navGridViewEnabled ? 'Show full name for books' : 'Show abbreviated books'),
                    onTap: () {
                      navBloc()
                        ..add(NavEvent.changeTabIndex(index: NavTabs.book.index))
                        ..add(const NavEvent.onSearchChange(search: ''));
                      PrefsBloc.toggle(PrefItemId.navLayout);
                    },
                  ),
                  ListTile(
                    title: Text(
                        nav3TapEnabled ? 'Show book and chapter' : 'Show book, chapter, and verse'),
                    onTap: () {
                      PrefsBloc.toggle(PrefItemId.nav3Tap);
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
          debugPrint('bcv tab');
          return BCVTabView(
            listener: (c, s) => _changeTabController(),
            tabController: _tabController,
            searchController: _searchController,
          );
        case NavViewState.searchSuggestions:
          debugPrint('suggestions view');
          return SearchSuggestionsView(
            searchController: _searchController,
            onSubmit: onSubmit,
          );
        case NavViewState.searchResults:
          debugPrint('results view');
          return SearchAndHistoryView(_searchController, _searchResultsTabController);
      }
      return Container();
    }

    Widget leadingAppBarIcon(BuildContext c, NavViewState s, SearchState ss) {
      if (s == NavViewState.searchResults &&
          ss.selectionMode &&
          _searchResultsTabController.index == 0) {
        return CloseButton(onPressed: _selectionMode);
      } else {
        return const CloseButton();
        // else if (s == NavViewState.bcvTabs) {closeButton}
        // else{
        // return BackButton(onPressed: () {
        // c.tbloc<NavBloc>()
        //   ..add(const NavEvent.changeNavView(state: NavViewState.bcvTabs))
        //   ..add(NavEvent.changeTabIndex(index: NavTabs.book.index))
        //   ..add(const NavEvent.onSearchChange(search: ''));
        // });
      }
    }

    Widget titleAppBar(BuildContext c, NavViewState s, SearchState ss) {
      if (s == NavViewState.searchResults && ss.selectionMode) {
        final length = ss.filteredResults.where((s) => s.selected).length;
        return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$length',
              style: Theme.of(context).appBarTheme.textTheme.bodyText1,
            ));
      } else if (s == NavViewState.searchResults && _searchResultsTabController.index == 1) {
        return const Text('History');
      } else {
        return TextField(
            onEditingComplete: onSubmit,
            // focus text field when no current search results but coming from magnifying glass
            autofocus: widget.searchView && ss.searchResults.isEmpty,
            style: Theme.of(context).appBarTheme.textTheme.bodyText1,
            decoration: InputDecoration(
                border: InputBorder.none,
                // suffixIcon: s == NavViewState.searchSuggestions
                //     ? IconButton(
                //         color: Theme.of(context).appBarTheme.actionsIconTheme.color,
                //         icon: const Icon(Icons.cancel_outlined),
                //         onPressed: () {
                //           _searchController.clear();
                //           navBloc().add(const NavEvent.onSearchChange(search: ''));
                //         })
                //     : Container(width: 1),
                hintText: 'Enter references or keywords',
                hintStyle: Theme.of(context)
                    .appBarTheme
                    .textTheme
                    .bodyText1
                    .copyWith(fontStyle: FontStyle.italic)),
            controller: _searchController);
      }
    }

    List<Widget> appBarActions(BuildContext c, NavState s, SearchState ss) {
      List<Widget> actions;

      if (s.navViewState == NavViewState.bcvTabs) {
        if (s.tabIndex != NavTabs.book.index) {
          actions = [
            TextButton(
                child: Text(
                  'GO',
                  style: TextStyle(color: tabColors[s.tabIndex]),
                ),
                onPressed: () => Navigator.of(context).maybePop(s.ref))
          ];
        } else {
          final hasSearchResults = c.tbloc<SearchBloc>().state.searchResults.isNotEmpty;
          actions = [
            IconButton(
                icon: hasSearchResults
                    ? const IconWithNumberBadge(
                        badgeColor: Colors.orange, icon: Icons.youtube_searched_for)
                    : const Icon(Icons.youtube_searched_for),
                onPressed: () {
                  c
                      .tbloc<NavBloc>()
                      .add(const NavEvent.changeNavView(state: NavViewState.searchResults));
                  // default to show history first
                  _searchResultsTabController.animateTo(1);
                }),
            IconButton(icon: Icon(platformAwareMoreIcon(context)), onPressed: _moreButton)
          ];
        }
      } else if (s.navViewState == NavViewState.searchResults) {
        if (ss.selectionMode) {
          actions = [
            IconButton(icon: const Icon(Icons.copy, size: 20), onPressed: _onSelectionCopied),
            IconButton(
                icon: const Icon(FeatherIcons.share2, size: 20), onPressed: _onSelectionShared)
          ];
        } else if (_searchResultsTabController.index == 0) {
          actions = [
            if (ss.filteredResults.isNotEmpty)
              IconButton(icon: const Icon(Icons.check_circle_outline), onPressed: _selectionMode),
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _filter)
          ];
        }
      } else if (s.navViewState == NavViewState.searchSuggestions) {
        actions = [
          IconButton(
              color: Theme.of(context).appBarTheme.actionsIconTheme.color,
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () {
                _searchController.clear();
                navBloc().add(const NavEvent.onSearchChange(search: ''));
                if (s.tabIndex != NavTabs.book.index) {
                  navBloc().add(NavEvent.changeTabIndex(index: NavTabs.book.index));
                }
              })
        ];
      }

      return actions;
    }

    return BlocConsumer<NavBloc, NavState>(
      listener: (c, s) {
        // tec.dmPrint(
        //     'Change from listener:\nstate search:${s.search}\nsearchController:${_searchController.text}');
        if (s.tabIndex < _tabController.length && s.tabIndex != _tabController.index) {
          _tabController.animateTo(s.tabIndex);
        }
      },
      builder: (c, s) => BlocBuilder<SearchBloc, SearchState>(
        builder: (c, ss) => Scaffold(
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            appBar: AppBar(
              title: titleAppBar(c, s.navViewState, ss),
              titleSpacing: 0,
              leading: leadingAppBarIcon(c, s.navViewState, ss),
              actions: appBarActions(c, s, ss),
            ),
            body: Container(
              color: Theme.of(context).dialogBackgroundColor,
              child: body(s.navViewState),
            )),
      ),
    );
  }
}

import 'dart:async';

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
import '../common/tec_bottom_sheet_safe_area.dart';
import '../library/library.dart';
import 'bcv_tab.dart';
import 'search_results_view.dart';
import 'search_suggestions.dart';

const tabColors = [Colors.red, Colors.blue, Colors.orange, Colors.green];

Future<Reference> navigate(BuildContext context, Reference ref, {int initialIndex = 1}) {
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
            BlocProvider<NavBloc>(
                create: (_) => NavBloc(ref)..add(NavEvent.changeTabIndex(index: initialIndex))),
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
      BlocProvider<NavBloc>(
          create: (_) => NavBloc(ref)..add(NavEvent.changeTabIndex(index: initialIndex))),
    ], child: Nav()),
  ));
}

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

const maxTabsAvailable = 4;
const minTabsAvailable = 3;

class _NavState extends State<Nav> with TickerProviderStateMixin {
  TabController _tabController;
  TextEditingController _searchController;
  Timer _debounce;

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
    _searchController = TextEditingController(text: '')..addListener(_searchControllerListener);
    final nav3TapEnabled = context.bloc<PrefItemsBloc>().itemBool(PrefItemId.nav3Tap);
    final tabLength = nav3TapEnabled ? maxTabsAvailable : minTabsAvailable;
    _tabController =
        TabController(length: tabLength, initialIndex: navBloc().state.tabIndex, vsync: this)
          ..addListener(() {
            if (_tabController.index != navBloc().state.tabIndex) {
              navBloc().add(NavEvent.changeTabIndex(index: _tabController.index));
            }
          });
    // if (widget.searchModeOn) {
    //   navBloc()
    //     ..add(const NavEvent.changeNavView(state: NavViewState.searchResults))
    //     ..add(NavEvent.changeTabIndex(index: SearchAndHistoryTabs.search.index));
    // }
    super.initState();
  }

  @override
  void dispose() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    super.dispose();
  }

  void _searchControllerListener() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (navBloc().state.search != _searchController.text) {
        navBloc().add(NavEvent.onSearchChange(search: _searchController.text));
      }
    });
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
    FocusScope.of(context).unfocus();
    if (s.isNotEmpty) {
      navBloc()
        ..add(NavEvent.onSearchChange(search: s))
        ..add(const NavEvent.onSearchFinished())
        ..add(const NavEvent.loadHistory());
      searchBloc().add(SearchEvent.request(search: s, translations: translations()));
    }
  }

  void _selectionMode() {
    final selectionModeOn = !context.bloc<SearchBloc>().state.selectionMode;
    if (selectionModeOn) {
      TecToast.show(context, 'Entered Selection Mode');
    }
    context.bloc<SearchBloc>().add(const SearchEvent.selectionModeToggle());
  }

  void _onSelectionCopied() {
    final verses = context.bloc<SearchBloc>().state.searchResults.where((s) => s.selected);
    if (verses.isNotEmpty) {
      TecShare.copy(context, verses.map((v) => v.shareText).join('\n\n'));
    }
  }

  void _onSelectionShared() {
    final verses = context.bloc<SearchBloc>().state.searchResults.where((s) => s.selected);
    if (verses.isNotEmpty) {
      TecShare.share(verses.map((v) => v.shareText).join('\n\n'));
    }
  }

  Future<void> _translation() async {
    final volumes = await selectVolumes(context,
        filter: const VolumesFilter(volumeType: VolumeType.bible), selectedVolumes: translations());
    if (volumes != null) {
      final prefItem =
          prefsBloc().infoChangedPrefItem(PrefItemId.translationsFilter, volumes.join('|'));
      prefsBloc().add(PrefItemEvent.update(prefItem: prefItem));
      if (_searchController.text.isNotEmpty) {
        searchBloc()
            .add(SearchEvent.request(search: _searchController.text, translations: volumes));
      }
    }
  }

  void _moreButton() {
    showModalBottomSheet<void>(
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
              final translationsAbbrev = items.boolForPrefItem(PrefItemId.translationsAbbreviated);
              return TecBottomSheetSafeArea(
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
                      title: Text(navGridViewEnabled
                          ? 'Show full name for books'
                          : 'Show abbreviated books'),
                      onTap: () {
                        navBloc()
                          ..add(NavEvent.changeTabIndex(index: NavTabs.book.index))
                          ..add(const NavEvent.onSearchChange(search: ''));
                        prefsBloc().add(PrefItemEvent.update(
                            prefItem: prefsBloc().toggledPrefItem(PrefItemId.navLayout)));
                      },
                    ),
                    ListTile(
                      title: Text(nav3TapEnabled
                          ? 'Show book and chapter'
                          : 'Show book, chapter, and verse'),
                      onTap: () {
                        prefsBloc().add(PrefItemEvent.update(
                            prefItem: prefsBloc().toggledPrefItem(PrefItemId.nav3Tap)));
                      },
                    ),
                    ListTile(
                      title: Text(translationsAbbrev
                          ? 'Show full name for translations'
                          : 'Show abbreviated translations'),
                      onTap: () {
                        navBloc().add(NavEvent.changeTabIndex(index: NavTabs.translation.index));
                        prefsBloc().add(PrefItemEvent.update(
                            prefItem:
                                prefsBloc().toggledPrefItem(PrefItemId.translationsAbbreviated)));
                      },
                    ),
                  ],
                ),
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    Widget body(NavViewState navViewState) {
      switch (navViewState) {
        case NavViewState.bcvTabs:
          return BCVTabView(
            listener: (c, s) => _changeTabController(),
            tabController: _tabController,
          );
        case NavViewState.searchSuggestions:
          return SearchSuggestionsView(
            onSubmit: onSubmit,
          );
        case NavViewState.searchResults:
          return SearchAndHistoryView();
      }
      return Container();
    }

    Widget leadingAppBarIcon(BuildContext c, NavViewState s) {
      if (s == NavViewState.searchResults && c.bloc<SearchBloc>().state.selectionMode) {
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
      if (s == NavViewState.searchResults && c.bloc<SearchBloc>().state.selectionMode) {
        final length = c.bloc<SearchBloc>().state.searchResults.where((s) => s.selected).length;
        return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$length',
              style: Theme.of(context).textTheme.bodyText1,
            ));
      } else {
        return TextField(
            onEditingComplete: onSubmit,
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter references or keywords',
                hintStyle: TextStyle(fontStyle: FontStyle.italic)),
            controller: _searchController);
      }
    }

    List<Widget> appBarActions(BuildContext c, NavState s) {
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
              onPressed: () => c.bloc<NavBloc>()
                ..add(const NavEvent.changeNavView(state: NavViewState.searchResults))
                ..add(NavEvent.changeTabIndex(index: SearchAndHistoryTabs.history.index))
                ..add(const NavEvent.loadHistory()),
            ),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: _moreButton)
          ];
        }
      } else if (s.navViewState == NavViewState.searchResults) {
        if (c.bloc<SearchBloc>().state.selectionMode) {
          return [
            IconButton(icon: const Icon(Icons.content_copy), onPressed: _onSelectionCopied),
            IconButton(icon: const Icon(Icons.share), onPressed: _onSelectionShared)
          ];
        } else {
          return [
            IconButton(icon: const Icon(Icons.check_circle_outline), onPressed: _selectionMode),
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _translation)
          ];
        }
      }
      return [];
    }

    return BlocConsumer<NavBloc, NavState>(
      listener: (c, s) {
        if (s.search != _searchController.text) {
          _searchController
            ..text = s.search
            ..selection = TextSelection.collapsed(offset: s.search.length);
        }
        if (s.tabIndex < _tabController.length && s.tabIndex != _tabController.index) {
          _tabController.animateTo(s.tabIndex);
        }
      },
      listenWhen: (p,c)=> c.tabIndex != p.tabIndex || c.search != p.search,
      builder: (c, s) => TecScaffoldWrapper(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: AppBar().preferredSize,
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (c, ss) => AppBar(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                elevation: 5,
                backgroundColor: Theme.of(context).cardColor,
                title: titleAppBar(c, s.navViewState, ss),
                titleSpacing: 0,
                leading: leadingAppBarIcon(c, s.navViewState),
                actions: appBarActions(c, s),
              ),
            ),
          ),
          body: body(s.navViewState),
        ),
      ),
    );
  }
}

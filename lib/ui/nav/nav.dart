import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/search/nav_bloc.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/pref_item.dart';
import '../common/common.dart';
import '../common/tec_scaffold_wrapper.dart';
import '../library/library.dart';
import 'bcv_tab.dart';
import 'search_results_view.dart';
import 'search_suggestions.dart';

const tabColors = [Colors.blue, Colors.orange, Colors.green];

Future<Reference> navigate(BuildContext context, Reference ref) {
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
            // BlocProvider<PrefItemsBloc>(create: (_) => PrefItemsBloc()),
            BlocProvider<NavBloc>(create: (_) => NavBloc(ref)),
            BlocProvider(create: (_) => SearchBloc()),
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
      // BlocProvider<PrefItemsBloc>(create: (_) => PrefItemsBloc()),
      BlocProvider<NavBloc>(create: (_) => NavBloc(ref)),
      BlocProvider(create: (_) => SearchBloc()),
    ], child: Nav()),
  ));
}

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

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
    final tabLength = nav3TapEnabled ? 3 : 2;
    _tabController = TabController(length: tabLength, vsync: this)
      ..addListener(() {
        if (_tabController.index != navBloc().state.tabIndex) {
          navBloc().add(NavEvent.changeTabIndex(index: _tabController.index));
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    super.dispose();
  }

  void _searchControllerListener() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (navBloc().state.search != _searchController.text) {
        navBloc().add(NavEvent.onSearchChange(search: _searchController.text));
      }
    });
  }

  void _changeTabController() {
    final nav3TapEnabled = context.bloc<PrefItemsBloc>().itemBool(PrefItemId.nav3Tap);
    final tabLength = nav3TapEnabled ? 3 : 2;
    setState(() {
      _tabController = TabController(length: tabLength, vsync: this)
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
      navBloc()..add(NavEvent.onSearchChange(search: s))..add(const NavEvent.onSearchFinished());
      searchBloc().add(SearchEvent.request(search: s, translations: translations()));
    }
  }

  Future<void> _translation() async {
    final volumes = await selectVolumes(context,
        filter: const VolumesFilter(volumeType: VolumeType.bible), selectedVolumes: translations());
    if (volumes != null) {
      final prefItem =
          prefsBloc().infoChangedPrefItem(PrefItemId.translationsFilter, volumes.join('|'));
      prefsBloc().add(PrefItemEvent.update(prefItem: prefItem));
    }
    if (_searchController.text.isNotEmpty) {
      searchBloc().add(SearchEvent.request(search: _searchController.text, translations: volumes));
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
            bloc: prefsBloc(),
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
                        prefsBloc().add(PrefItemEvent.update(
                            prefItem: prefsBloc().toggledPrefItem(PrefItemId.navBookOrder)));
                      },
                    ),
                    ListTile(
                      title: Text(navGridViewEnabled
                          ? 'Show full name for books'
                          : 'Show abbreviated books'),
                      onTap: () {
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
                  ],
                ),
              );
            }));
    navBloc()
      ..add(const NavEvent.changeTabIndex(index: 0))
      ..add(const NavEvent.onSearchChange(search: ''));
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
          return SearchResultsView();
      }
      return Container();
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
      builder: (c, s) => TecScaffoldWrapper(
        child: Scaffold(
          appBar: AppBar(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 5,
            title: TextField(
                onEditingComplete: onSubmit,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter references or keywords',
                    hintStyle: TextStyle(fontStyle: FontStyle.italic)),
                controller: _searchController),
            titleSpacing: 0,
            leading: s.navViewState == NavViewState.bcvTabs
                ? const CloseButton()
                : BackButton(
                    onPressed: () {
                      c.bloc<NavBloc>()
                        ..add(const NavEvent.changeNavView(state: NavViewState.bcvTabs))
                        ..add(const NavEvent.onSearchChange(search: ''));
                    },
                  ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => c.bloc<NavBloc>().add(const NavEvent.loadHistory()),
              ),
              if (s.navViewState == NavViewState.bcvTabs)
                IconButton(icon: const Icon(Icons.more_horiz), onPressed: _moreButton),
              if (s.navViewState == NavViewState.searchResults)
                IconButton(icon: const Icon(Icons.filter_list), onPressed: _translation)
            ],
          ),
          body: body(s.navViewState),
        ),
      ),
    );
  }
}

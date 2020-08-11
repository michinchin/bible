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
            BlocProvider<PrefItemsBloc>(create: (_) => PrefItemsBloc()),
            BlocProvider<NavBloc>(create: (_) => NavBloc(ref))
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
      BlocProvider<PrefItemsBloc>(create: (_) => PrefItemsBloc()),
      BlocProvider<NavBloc>(create: (_) => NavBloc(ref))
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
  List<int> translations() => prefsBloc()
      .state
      .items
      .itemWithId(translationsFilter)
      .info
      .split('|')
      .map(int.parse)
      .toList();

  @override
  void initState() {
    _searchController = TextEditingController(text: '')..addListener(_searchControllerListener);
    final nav2TapEnabled = (prefsBloc().state.items?.valueOfItemWithId(nav2Tap) ?? 0) != 0;
    final tabLength = nav2TapEnabled ? 2 : 3;
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
    final nav2TapEnabled = (prefsBloc().state.items?.valueOfItemWithId(nav2Tap) ?? 0) != 0;
    final tabLength = nav2TapEnabled ? 2 : 3;
    setState(() {
      _tabController = TabController(length: tabLength, vsync: this)
        ..addListener(() {
          if (_tabController.index != navBloc().state.tabIndex) {
            navBloc().add(NavEvent.changeTabIndex(index: _tabController.index));
          }
        });
    });
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    navBloc()
      ..add(NavEvent.onSearchChange(search: _searchController.text))
      ..add(const NavEvent.onSearchFinished());
    // Navigator.of(context).maybePop(navBloc().state.ref);
  }

  Future<void> _translation() async {
    final volumes = await selectVolumes(context, selectedVolumes: translations());
    if (volumes != null) {
      final prefItem = PrefItem.from(
          prefsBloc().state.items.itemWithId(translationsFilter).copyWith(info: volumes.join('|')));
      prefsBloc().add(PrefItemEvent.update(prefItem: prefItem));
    }
  }

  void _moreButton() {
    final prefState = prefsBloc()?.state;
    final items = prefState?.items ?? [];
    final navGridViewEnabled = (items.valueOfItemWithId(navLayout) ?? 0) != 0;
    final nav2TapEnabled = (items.valueOfItemWithId(nav2Tap) ?? 0) != 0;
    showModalBottomSheet<void>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        context: context,
        builder: (c) => SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Text(
                        navGridViewEnabled ? 'Show full name for books' : 'Show abbreviated books'),
                    onTap: () {
                      prefsBloc().add(PrefItemEvent.update(
                          prefItem: PrefItem.from(items
                              .itemWithId(navLayout)
                              .copyWith(verse: navGridViewEnabled ? 0 : 1))));
                      Navigator.of(context).maybePop();
                    },
                  ),
                  ListTile(
                    title: Text(nav2TapEnabled ? 'Show verse tab' : 'Hide verse tab'),
                    onTap: () {
                      prefsBloc().add(PrefItemEvent.update(
                          prefItem: PrefItem.from(
                              items.itemWithId(nav2Tap).copyWith(verse: nav2TapEnabled ? 0 : 1))));
                      Navigator.of(context).maybePop();
                    },
                  ),
                ],
              ),
            ));
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
          return SearchSuggestionsView();
        case NavViewState.searchResults:
          return BlocProvider(
              create: (_) => SearchBloc()
                ..add(SearchEvent.request(
                    search: navBloc().state.search, translations: translations())),
              child: SearchResultsView());
      }
      return Container();
    }

    return BlocConsumer<NavBloc, NavState>(
      listener: (c, s) {
        _searchController
          ..text = s.search
          ..selection = TextSelection.collapsed(offset: _searchController.text.length);
        if (s.tabIndex < _tabController.length && s.tabIndex != _tabController.index) {
          _tabController.animateTo(s.tabIndex);
        }
      },
      builder: (c, s) => Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: TextField(
              onEditingComplete: _onSubmit,
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
    );
  }
}

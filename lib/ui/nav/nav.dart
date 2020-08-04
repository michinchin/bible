import 'dart:collection';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/search/nav_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/pref_item.dart';
import '../common/common.dart';

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

  NavBloc navBloc() => context.bloc<NavBloc>();
  PrefItemsBloc prefsBloc() => context.bloc<PrefItemsBloc>();

  @override
  void initState() {
    _searchController = TextEditingController(text: '');

    _searchController.addListener(() {
      if (navBloc().state.search != _searchController.text) {
        navBloc().add(NavEvent.onSearchChange(search: _searchController.text));
      }
    });
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
    navBloc().add(NavEvent.onSearchChange(search: _searchController.text));
    Navigator.of(context).maybePop(navBloc().state.ref);
  }

  void _moreButton() {
    final prefState = prefsBloc()?.state;
    final items = prefState?.items ?? [];
    final navGridViewEnabled = (items.valueOfItemWithId(navLayout) ?? 0) != 0;
    final nav2TapEnabled = (items.valueOfItemWithId(nav2Tap) ?? 0) != 0;
    showModalBottomSheet<void>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        context: context,
        builder: (c) => ListView(
              shrinkWrap: true,
              children: [
                // const Align(alignment: Alignment.topRight, child: CloseButton()),
                ListTile(
                  // leading: Icon(FeatherIcons.bookOpen),
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
            ));
  }

  @override
  Widget build(BuildContext context) {
    final prefState = prefsBloc()?.state;
    final items = prefState?.items ?? [];
    final navGridViewEnabled = (items.valueOfItemWithId(navLayout) ?? 0) != 0;
    final nav2TapEnabled = (items.valueOfItemWithId(nav2Tap) ?? 0) != 0;

    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: appBarThemeWithContext(context),
        tabBarTheme: tabBarThemeWithContext(context),
      ),
      child: BlocConsumer<NavBloc, NavState>(
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
                  title: TecSearchField(
                      onSubmit: (s) => _onSubmit(),
                      padding: const EdgeInsets.all(0),
                      textEditingController: _searchController),
                  titleSpacing: 0,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () => navBloc().add(const NavEvent.loadHistory()),
                    ),
                    IconButton(icon: const Icon(Icons.more_horiz), onPressed: _moreButton)
                  ],
                ),
                body: s.navViewState == NavViewState.bcvTabs
                    ? BlocListener<PrefItemsBloc, PrefItems>(
                        listener: (c, s) => _changeTabController(),
                        child: SafeArea(
                            child: Column(
                          children: [
                            const SizedBox(height: 5),
                            TabBar(
                              indicatorSize: TabBarIndicatorSize.label,
                              indicator: BubbleTabIndicator(
                                  color: tabColors[navBloc().state.tabIndex].withOpacity(0.5)),
                              controller: _tabController,
                              labelColor: Theme.of(context).textColor.withOpacity(0.7),
                              unselectedLabelColor: Theme.of(context).textColor.withOpacity(0.7),
                              tabs: [
                                const Tab(text: 'BOOK'),
                                const Tab(text: 'CHAPTER'),
                                if (!nav2TapEnabled) const Tab(text: 'VERSE')
                              ],
                            ),
                            Expanded(
                              child: TabBarView(controller: _tabController, children: [
                                _BookView(navGridViewEnabled: navGridViewEnabled),
                                _ChapterView(nav2TapEnabled: nav2TapEnabled),
                                if (!nav2TapEnabled) _VerseView(),
                              ]),
                            ),
                          ],
                        )))
                    : _SearchSuggestionsView(),
              )),
    );
  }
}

class _SearchSuggestionsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final bloc = context.bloc<NavBloc>();
    final bible = VolumesRepository.shared.bibleWithId(51);
    final wordSuggestions = bloc.state.wordSuggestions ?? [];
    final bookSuggestions = bloc.state.bookSuggestions ?? [];
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final word in wordSuggestions)
            ListTile(
              title: Text(word),
            ),
          for (final book in bookSuggestions)
            ListTile(
                leading: const Icon(FeatherIcons.bookOpen),
                title: Text(bible.nameOfBook(book)),
                onTap: () {
                  bloc.add(NavEvent.onSearchChange(search: bible.nameOfBook(book)));
                }),
        ],
      ),
    );
  }
}

class _ChapterView extends StatelessWidget {
  final bool nav2TapEnabled;
  const _ChapterView({this.nav2TapEnabled});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDarkTheme ? Theme.of(context).textColor : Theme.of(context).textColor.withOpacity(0.7);
    final bible = VolumesRepository.shared.bibleWithId(51);
    final isLargeScreen = MediaQuery.of(context).size.width > 500;
    final wideScreen = MediaQuery.of(context).size.width > 400;

    final ref = context.bloc<NavBloc>().state.ref;
    final chapters = bible.chaptersIn(book: ref.book);

    return Column(
      children: [
        // Align(
        //   alignment: Alignment.topRight,
        //   child: Switch.adaptive(value: twoTap, onChanged: (b) {}),
        // ),
        Expanded(
          child: GridView.count(
            crossAxisCount: isLargeScreen || wideScreen ? 6 : 5,
            shrinkWrap: true,
            childAspectRatio: isLargeScreen ? 3 : 2,
            padding: const EdgeInsets.all(15),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              for (var i = 1; i <= chapters; i++) ...[
                FlatButton(
                  padding: const EdgeInsets.all(0),
                  shape: const StadiumBorder(),
                  color: Colors.grey.withOpacity(0.1),
                  textColor: ref.chapter == i ? tabColors[1] : textColor,
                  onPressed: () {
                    if (nav2TapEnabled) {
                      Navigator.of(context).maybePop(ref.copyWith(chapter: i));
                    } else {
                      context
                          .bloc<NavBloc>()
                          .selectChapter(ref.book, bible.nameOfBook(ref.book), i);
                    }
                  },
                  child: Text(i.toString()),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

class _VerseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDarkTheme ? Theme.of(context).textColor : Theme.of(context).textColor.withOpacity(0.7);
    final bible = VolumesRepository.shared.bibleWithId(51);
    final isLargeScreen = MediaQuery.of(context).size.width > 500;
    final wideScreen = MediaQuery.of(context).size.width > 400;

    final ref = context.bloc<NavBloc>().state.ref;
    final book = ref.book;
    final chapter = ref.chapter;
    final verses = bible.versesIn(book: book, chapter: chapter);

    return GridView.count(
      crossAxisCount: isLargeScreen || wideScreen ? 6 : 5,
      shrinkWrap: true,
      childAspectRatio: isLargeScreen ? 3 : 2,
      padding: const EdgeInsets.all(15),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        for (var i = 1; i <= verses; i++) ...[
          FlatButton(
            padding: const EdgeInsets.all(0),
            shape: const StadiumBorder(),
            color: Colors.grey.withOpacity(0.1),
            textColor: ref.verse == i ? tabColors[2] : textColor,
            onPressed: () {
              // TODO(abby): manually assigning end verse...probably shouldn't do this
              final updatedRef = ref.copyWith(verse: i, endVerse: i);
              context.bloc<NavBloc>().add(NavEvent.setRef(ref: updatedRef));
              Navigator.of(context).maybePop(updatedRef);
            },
            child: Text(i.toString()),
          ),
        ]
      ],
    );
  }
}

class _BookView extends StatelessWidget {
  final bool navGridViewEnabled;
  const _BookView({this.navGridViewEnabled});

  @override
  Widget build(BuildContext context) {
    final bible = VolumesRepository.shared.bibleWithId(51);
    // ignore: prefer_collection_literals
    final bookNames = LinkedHashMap<int, String>();
    var book = bible.firstBook;
    while (book != 0) {
      bookNames[book] = bible.shortNameOfBook(book);
      final nextBook = bible.bookAfter(book);
      book = (nextBook == book ? 0 : nextBook);
    }
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDarkTheme ? Theme.of(context).textColor : Theme.of(context).textColor.withOpacity(0.7);

    final ot = bookNames.keys.takeWhile(bible.isOTBook).toList();
    final nt = bookNames.keys.where(bible.isNTBook).toList();
    final ref = context.bloc<NavBloc>().state.ref;
    final smallScreen = MediaQuery.of(context).size.height <= 568;

    Widget gridView(List<int> books) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GridView.extent(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          maxCrossAxisExtent: 50,
          childAspectRatio: smallScreen ? 1.8 : 1.5,
          crossAxisSpacing: smallScreen ? 5 : 10,
          mainAxisSpacing: smallScreen ? 5 : 10,
          children: [
            for (final book in books) ...[
              ButtonTheme(
                minWidth: 50,
                child: FlatButton(
                  padding: const EdgeInsets.all(0),
                  shape: const StadiumBorder(),
                  color: Colors.grey.withOpacity(0.1),
                  textColor: ref.book == book ? tabColors[0] : textColor,
                  onPressed: () => context.bloc<NavBloc>().selectBook(book, bible.nameOfBook(book)),
                  child: Text(
                    bookNames[book],
                  ),
                ),
              ),
            ]
          ],
        ));

    // Widget wrap(List<int> books) => Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 5),
    //     child: Wrap(spacing: 2, children: [
    //       for (final book in books) ...[
    //         ButtonTheme(
    //           minWidth: 50,
    //           child: FlatButton(
    //             padding: const EdgeInsets.all(0),
    //             shape: const StadiumBorder(),
    //             color: Colors.grey.withOpacity(0.1),
    //             textColor: ref.book == book ? tabColors[0] : textColor,
    //             onPressed: () => context.bloc<NavBloc>().selectBook(book, bible.nameOfBook(book)),
    //             child: Text(
    //               bookNames[book],
    //             ),
    //           ),
    //         ),
    //       ]
    //     ]));

    Widget list(List<int> books) => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: books.length,
        separatorBuilder: (c, i) => const Divider(
              height: 1,
            ),
        itemBuilder: (c, i) => ListTile(
              onTap: () => c.bloc<NavBloc>().selectBook(books[i], bible.nameOfBook(books[i])),
              title: Text(
                bible.nameOfBook(books[i]),
                textAlign: TextAlign.left,
                style: TextStyle(color: ref.book == books[i] ? tabColors[0] : textColor),
              ),
            ));

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                'OLD TESTAMENT',
                style: Theme.of(context).textTheme.caption,
              )),
          if (navGridViewEnabled) gridView(ot) else list(ot),
          const Divider(color: Colors.transparent),
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                'NEW TESTAMENT',
                style: Theme.of(context).textTheme.caption,
              )),
          if (navGridViewEnabled) gridView(nt) else list(nt),
          const Divider(color: Colors.transparent),
        ],
      ),
    );
  }
}

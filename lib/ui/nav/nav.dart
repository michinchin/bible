import 'dart:collection';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/search/nav_bloc.dart';
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
          height: 600, width: 500, child: BlocProvider(create: (c) => NavBloc(ref), child: Nav())),
    );
  }

  // TODO(abby): if the tab index is not 0 and the search controller text is empty, then fill the words on entering the text field

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
    builder: (context) => BlocProvider(create: (c) => NavBloc(ref), child: Nav()),
  ));
}

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> with SingleTickerProviderStateMixin {
  TabController _tabController;
  TextEditingController _searchController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController(text: '');
    //ignore: close_sinks
    final bloc = context.bloc<NavBloc>();
    _searchController.addListener(() {
      if (bloc.state.search != _searchController.text) {
        bloc.add(NavEvent.onSearchChange(search: _searchController.text));
      }
    });
    _tabController.addListener(() {
      if (_tabController.index != bloc.state.tabIndex) {
        bloc.add(NavEvent.changeTabIndex(index: _tabController.index));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.bloc<NavBloc>(); //ignore: close_sinks
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: appBarThemeWithContext(context),
        tabBarTheme: tabBarThemeWithContext(context),
      ),
      child: BlocConsumer<NavBloc, NavState>(
          listener: (c, s) {
            _searchController.text = s.search;
            if (s.tabIndex < _tabController.length && s.tabIndex != _tabController.index) {
              _tabController.animateTo(s.tabIndex);
            }
          },
          builder: (c, s) => Scaffold(
                appBar: AppBar(
                  title: TextField(
                      controller: _searchController,
                      onEditingComplete: () {
                        bloc.add(const NavEvent.onSearchFinished());
                        Navigator.of(context).maybePop(bloc.state.ref);
                      },
                      decoration: InputDecoration(
                        suffixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: s.ref.label(),
                      )),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () =>
                          TecToast.show(context, '3tap, 2tap, wheel options coming soon!'),
                    )
                  ],
                ),
                body: s.navViewState == NavViewState.bcvTabs
                    ? SafeArea(
                        child: Column(
                          children: [
                            TabBar(
                              indicatorSize: TabBarIndicatorSize.label,
                              indicator: BubbleTabIndicator(
                                  color: tabColors[context.bloc<NavBloc>().state.tabIndex]
                                      .withOpacity(0.5)),
                              controller: _tabController,
                              labelColor: Theme.of(context).textColor.withOpacity(0.7),
                              unselectedLabelColor: Theme.of(context).textColor.withOpacity(0.7),
                              // labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                              tabs: const [
                                Tab(text: 'BOOK'),
                                Tab(text: 'CHAPTER'),
                                Tab(text: 'VERSE')
                              ],
                            ),
                            Expanded(
                              child: TabBarView(controller: _tabController, children: [
                                _BookView(),
                                _ChapterView(),
                                _VerseView(),
                              ]),
                            ),
                          ],
                        ),
                      )
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
                    // Navigator.of(context).maybePop(ref.copyWith(chapter: i));
                    context.bloc<NavBloc>().selectChapter(ref.book, bible.nameOfBook(ref.book), i);
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
    // final isLargeScreen = MediaQuery.of(context).size.width > 500;
    // final wideScreen = MediaQuery.of(context).size.width > 400;

    // List<Widget> _lineInGridView() {
    //   final divs = <Widget>[];
    //   final count = isLargeScreen ? 9 : 6;
    //   for (var i = 0; i < count; i++) {
    //     divs.add(const VerticalDivider(color: Colors.transparent));
    //   }
    //   return divs;
    // }

    final ot = bookNames.keys.takeWhile(bible.isOTBook);
    final nt = bookNames.keys.where(bible.isNTBook);
    final ref = context.bloc<NavBloc>().state.ref;
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
          Wrap(spacing: 5, runSpacing: 0, children: [
            for (final book in ot) ...[
              ButtonTheme(
                minWidth: 50,
                child: FlatButton(
                  padding: const EdgeInsets.all(0),
                  shape: const StadiumBorder(),
                  color: Colors.grey.withOpacity(0.1),
                  textColor: ref.book == book ? tabColors[0] : textColor,
                  onPressed: () {
                    context.bloc<NavBloc>()
                      ..add(NavEvent.setRef(ref: ref.copyWith(book: book)))
                      ..add(const NavEvent.changeTabIndex(index: 1));
                    // Navigator.of(context).maybePop(BookChapterVerse(book, book == 23 ? 119 : 1, 1));
                  },
                  child: Text(
                    bookNames[book],
                  ),
                ),
              ),
            ]
          ]),
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                'NEW TESTAMENT',
                style: Theme.of(context).textTheme.caption,
              )),
          Wrap(spacing: 5, children: [
            for (final book in nt) ...[
              ButtonTheme(
                minWidth: 50,
                child: FlatButton(
                  padding: const EdgeInsets.all(0),
                  shape: const StadiumBorder(),
                  color: ref.book == book
                      ? tabColors[0].withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  textColor: textColor,
                  onPressed: () {
                    context.bloc<NavBloc>().selectBook(book, bible.nameOfBook(book));
                    // Navigator.of(context).maybePop(BookChapterVerse(book, book == 23 ? 119 : 1, 1));
                  },
                  child: Text(
                    bookNames[book],
                  ),
                ),
              ),
            ]
          ]),
          const Divider(color: Colors.transparent),
        ],
      ),
    );
  }
}

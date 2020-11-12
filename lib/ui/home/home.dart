import 'package:flutter/material.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../menu/main_menu.dart';
import '../menu/notifications_view.dart';
import 'today_screen.dart';

void showHome(BuildContext context) {
  Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => _HomeScreen(),
    ),
  );
}

class _HomeScreen extends StatefulWidget {
  @override
  __HomeScreenState createState() => __HomeScreenState();
}

class __HomeScreenState extends State<_HomeScreen> {
  @override
  Widget build(BuildContext context) {
    const tabs = [
      Tab(text: 'Today'),
      Tab(text: 'Explore'),
      Tab(text: 'Study Bibles'),
      Tab(text: 'Commentaries'),
    ];
    final tabViews = [TodayScreen(), Container(), Container(), Container()];

    return TecScaffoldWrapper(
      child: DefaultTabController(
          length: tabs.length,
          child: Scaffold(
              floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              floatingActionButton: BottomHomeFab(),
              bottomNavigationBar: BottomHomeBar(),
              appBar: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: false,
                title: const Text('Home'),
                bottom: const TabBar(
                  tabs: tabs,
                  isScrollable: true,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.account_circle_outlined),
                    onPressed: () => showMainMenu(context),
                  )
                ],
              ),
              body: TabBarView(children: tabViews))),
    );
  }
}

class BottomHomeBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 4.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => showNotifications(context),
          ),
        ],
      ),
    );
  }
}

class BottomHomeFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(TecIcons.tbOutlineLogo, color: Colors.white),
      backgroundColor: tecartaBlue,
      onPressed: () {
        while (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}

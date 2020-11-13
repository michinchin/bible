import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../../models/home/dotds.dart';
import '../../models/home/votd.dart';
import '../menu/main_menu.dart';
import '../menu/notifications_view.dart';
import 'dotd_screen.dart';
import 'today_screen.dart';
import 'votd_screen.dart';

Future<void> showHome(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Home(),
      ),
    );

Future<void> showVotdFromNotification(BuildContext context, DateTime date) async {
  while (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
  unawaited(showHome(context));
  final votds = await Votd.fetch(AppSettings.shared.env);
  if (tec.dateOnly(date).isAtSameMomentAs(tec.today)) {
    await showVotdScreen(context, votds.forDateTime(date));
  } else {
    unawaited(showAllVotd(context, votds, scrollToDateTime: date));
    unawaited(showVotdScreen(context, votds.forDateTime(date)));
  }
}

Future<void> showDotdFromNotification(BuildContext context, DateTime date) async {
  while (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
  unawaited(showHome(context));
  final dotds = await Dotds.fetch(AppSettings.shared.env);
  if (tec.dateOnly(date).isAtSameMomentAs(tec.today)) {
    await showDotdScreen(context, dotds.devoForDate(date));
  } else {
    unawaited(showAllDotd(context, dotds, scrollToDateTime: date));
    await showDotdScreen(context, dotds.devoForDate(date));
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    // const tabs = [
    //   Tab(text: 'Today'),
    //   Tab(text: 'Explore'),
    //   Tab(text: 'Study Bibles'),
    //   Tab(text: 'Commentaries'),
    // ];
    // final tabViews = [TodayScreen(), Container(), Container(), Container()];

    return TecScaffoldWrapper(
        // child: DefaultTabController(
        // length: tabs.length,
        child: Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: BottomHomeFab(),
      bottomNavigationBar: BottomHomeBar(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: const Text('Home'),
        // bottom: const TabBar(
        //   tabs: tabs,
        //   isScrollable: true,
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => showMainMenu(context),
          )
        ],
      ),
      body:
          // TabBarView(children:

          TodayScreen(),
    ));
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

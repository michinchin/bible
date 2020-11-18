import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/home/dotds.dart';
import '../../models/home/votd.dart';
import '../common/common.dart';
import 'dotd_screen.dart';
import 'saves_screen.dart';
import 'today_screen.dart';
import 'votd_screen.dart';

Future<void> showTodayScreen(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Today(),
      ),
    );

Future<void> showVotdFromNotification(BuildContext context, DateTime date) async {
  while (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
  unawaited(showTodayScreen(context));
  final votds = await Votd.fetch();
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
  unawaited(showTodayScreen(context));
  final dotds = await Dotds.fetch();
  if (tec.dateOnly(date).isAtSameMomentAs(tec.today)) {
    await showDotdScreen(context, dotds.devoForDate(date));
  } else {
    unawaited(showAllDotd(context, dotds, scrollToDateTime: date));
    await showDotdScreen(context, dotds.devoForDate(date));
  }
}

class Today extends StatefulWidget {
  @override
  _TodayState createState() => _TodayState();
}

class _TodayState extends State<Today> {
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
      appBar: MinHeightAppBar(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          centerTitle: false,
          title: const Text('Today'),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () => showSaveScreen(context),
            ),
          ],
          // bottom: const TabBar(
          //   tabs: tabs,
          //   isScrollable: true,
          // ),
        ),
      ),
      body:
          // TabBarView(children:

          TodayScreen(),
    ));
  }
}

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

Future<void> showTodayScreen(BuildContext context) => showScreen<void>(
      context: context,
      builder: (context) => Navigator(
          onGenerateRoute: (settings) =>
              TecPageRoute<dynamic>(settings: settings, builder: (context) => Today())),
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
    await showVotdScreen(context, votds.forDateTime(date));
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
    return TecScaffoldWrapper(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: MinHeightAppBar(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            centerTitle: false,
            title: const Text('Today'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () => showSaveScreen(context),
              ),
            ],
          ),
        ),
        body: TodayScreen(),
      ),
    );
  }
}

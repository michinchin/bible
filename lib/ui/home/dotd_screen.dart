import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../../models/home/devo_resource.dart';
import '../../models/home/dotd.dart';
import 'day_card.dart';
import 'home.dart';

Future<void> showDotdScreen(BuildContext context, DevoRes devo) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => _DotdScreen(devo)));

class _DotdScreen extends StatelessWidget {
  final DevoRes devo;
  const _DotdScreen(this.devo);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        floatingActionButton: BottomHomeFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomHomeBar(),
        body: Column(
          children: [
            TecImage(
              url: devo.imageUrl(AppSettings.shared.env),
              colorBlendMode: BlendMode.softLight,
              color:
                  Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white24,
            ),
            Text(devo.title),
            Text(devo.intro)
          ],
        ));
  }
}

// final res = await Resource.fetch(
//         env: env,
//         volumeId: devo.productId,
//         resourceId: devo.resourceId,
//       );

Future<void> showAllDotd(BuildContext context, Dotd dotd, {DateTime scrollToDateTime}) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => _DotdsScreen(dotd)));

class _DotdsScreen extends StatelessWidget {
  final Dotd dotd;
  const _DotdsScreen(this.dotd);
  @override
  Widget build(BuildContext context) {
    final dotds = <DevoRes>[];
    final days = <DateTime>[];
    for (var day = DateTime(tec.today.year, 1, 1);
        day.isBefore(DateTime(tec.today.year, 12, 31)) ||
            day.isAtSameMomentAs(DateTime(tec.today.year, 12, 31));
        day = day.add(const Duration(days: 1))) {
      days.add(day);
      dotds.add(dotd.devoForDate(day));
    }
    return TecScaffoldWrapper(
        child: Scaffold(
      appBar: AppBar(),
      body: Scrollbar(
        child: ListView.builder(
            itemCount: dotds.length,
            itemBuilder: (c, i) => DayCard(
                date: days[i],
                title: dotds[i].title,
                imageUrl: dotds[i].imageUrl(AppSettings.shared.env),
                onTap: () => showDotdScreen(context, dotds[i]))),
      ),
    ));
  }
}

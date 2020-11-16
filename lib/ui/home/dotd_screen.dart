import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../models/home/dotd.dart';
import '../../models/home/dotds.dart';
import '../../models/home/interstitial.dart';
import '../common/common.dart';
import 'day_card.dart';
import 'home.dart';
import 'votd_screen.dart';

Future<void> showDotdScreen(BuildContext context, Dotd devo) async {
  await Interstitial.init(context, productId: devo.productId, adUnitId: Const.prefNativeAdId);
  await Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => _DotdScreen(devo)));
  await Interstitial.show(context);
}

class _DotdScreen extends StatelessWidget {
  final Dotd devo;
  const _DotdScreen(this.devo);
  // bottomNavigationBar: BottomHomeBar(),
  @override
  Widget build(BuildContext context) {
    return TecImageAppBarScaffold(
        imageUrl: devo.imageUrl(AppSettings.shared.env),
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
        imageAspectRatio: imageAspectRatio,
        //  scrollController: scrollController,
        floatingActionButton: BottomHomeFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        // bottomNavigationBar: BottomHomeBar(),
        childBuilder: (c, i) => FutureBuilder<String>(
            future: devo.html(AppSettings.shared.env),
            builder: (c, snapshot) {
              if (snapshot.hasData) {
                return TecHtml(
                  snapshot.data,
                  baseUrl: '',
                  // baseUrl: devo.volume?.baseUrl,
                  textScaleFactor: textScaleFactorWith(c),
                );
              }
              return const LoadingIndicator();
            }));
  }
}

// final res = await Resource.fetch(
//         env: env,
//         volumeId: devo.productId,
//         resourceId: devo.resourceId,
//       );

Future<void> showAllDotd(BuildContext context, Dotds dotd, {DateTime scrollToDateTime}) =>
    Navigator.of(context).push(MaterialPageRoute(
        builder: (c) => _DotdsScreen(
              dotd,
              scrollToDateTime: scrollToDateTime,
            )));

class _DotdsScreen extends StatelessWidget {
  final Dotds dotd;
  final DateTime scrollToDateTime;
  const _DotdsScreen(this.dotd, {this.scrollToDateTime});
  @override
  Widget build(BuildContext context) {
    final dotds = <Dotd>[];
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
      appBar: AppBar(
        title: const TecText(
          'Devotional Of The Day',
          autoSize: true,
        ),
      ),
      body: Scrollbar(
        child: ScrollablePositionedList.builder(
            initialScrollIndex: scrollToDateTime == null
                ? days.indexOf(tec.today)
                : days.indexOf(tec.dateOnly(scrollToDateTime)),
            itemCount: dotds.length,
            itemBuilder: (c, i) => DayCard(
                date: days[i],
                title: dotds[i].title,
                body: dotds[i].intro,
                imageUrl: dotds[i].imageUrl(AppSettings.shared.env),
                onTap: () => showDotdScreen(context, dotds[i]))),
      ),
    ));
  }
}

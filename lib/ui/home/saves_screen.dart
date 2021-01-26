import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../models/home/dotds.dart';
import '../../models/home/saves.dart';
import '../../models/home/votd.dart';
import '../../models/reference_ext.dart';
import '../common/common.dart';
import 'day_card.dart';
import 'dotd_screen.dart';
import 'votd_screen.dart';

Future<void> showSaveScreen(BuildContext context, {int year}) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
        maintainState: false, builder: (c) => SavesScreen(year: year ?? tec.today.year)));

class SavesScreen extends StatelessWidget {
  final int year;
  const SavesScreen({this.year});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OtdSaves>(
        future: OtdSaves.fetch(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final years = snapshot.data.data.map((s) => s.year).toSet().toList()
              ..sort((a, b) => b.compareTo(a));
            return TabWrapper(
              appBarTitle: const Text('Saves'),
              tabViews: [for (final each in years) _SavedOtds(each, snapshot.data)],
              tabs: [for (final each in years) Tab(text: '$each')],
              emptyList: const Center(
                child: Text('No results'),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(),
              body: const LoadingIndicator(),
            );
          }
          return Scaffold(
            appBar: AppBar(),
            body: const Text('Unable to Load Current Page'),
          );
        });
  }
}

class _SavedOtds extends StatelessWidget {
  final OtdSaves otds;
  final int year;
  const _SavedOtds(this.year, this.otds);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait<dynamic>([Dotds.fetch(year: year), Votd.fetch(year: year)]),
      builder: (c, s) {
        if (s.hasData) {
          final dotds = tec.as<Dotds>(s.data[0]);
          final votds = tec.as<Votd>(s.data[1]);
          final children = (otds?.data ?? []).map<Widget>((s) {
            if (s.year == year) {
              final date = tec.dateOnly(DateTime(s.year, 1, 1).add(Duration(days: s.day)));
              if (s.cardType == votdType) {
                final votd = votds.forDateTime(date);
                return FutureBuilder<tec.ErrorOrValue<String>>(
                  future: votd.getFormattedVerse(currentBibleFromContext(c)),
                  builder: (c, s) => DayCard(
                    imageUrl: votd.imageUrl,
                    title: votd.ref.label(),
                    body: s.hasData ? s.data.value : '',
                    date: date,
                    onTap: () => showVotdScreen(c, votd),
                  ),
                );
              } else {
                final dotd = dotds.devoForDate(date);
                return DayCard(
                  imageUrl: dotd.imageUrl,
                  title: dotd.title,
                  body: dotd.intro,
                  date: date,
                  onTap: () => showDotdScreen(c, dotd),
                );
              }
            }
            return Container();
          }).toList();
          return ListView(
            children: children,
          );
        } else if (!s.hasData && s.connectionState == ConnectionState.done) {
          return Container(
            alignment: Alignment.center,
            child: const Text('No current saves.'),
          );
        }
        return const Center(child: LoadingIndicator());
      },
    );
  }
}

/// if more than one child don't show tabs, otherwise show them
class TabWrapper extends StatelessWidget {
  final Widget appBarTitle;
  final List<Widget> tabViews;
  final List<Tab> tabs;
  final Widget emptyList;
  const TabWrapper({this.tabViews, this.tabs, this.appBarTitle, this.emptyList});
  @override
  Widget build(BuildContext context) {
    return tabViews.length <= 1
        ? Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: MinHeightAppBar(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: appBarTitle,
              ),
            ),
            body: tabViews.isNotEmpty ? tabViews.first : emptyList)
        : DefaultTabController(
            length: tabViews.length,
            child: Scaffold(
                backgroundColor: Theme.of(context).backgroundColor,
                appBar: MinHeightAppBar(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    title: appBarTitle,
                    bottom: TabBar(
                      tabs: tabs,
                    ),
                  ),
                ),
                body: TabBarView(children: tabViews)));
  }
}

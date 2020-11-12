import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/home/votd.dart';
import '../common/common.dart';
import 'day_card.dart';
import 'home.dart';

Future<void> showVotdScreen(BuildContext context, VotdEntry votd) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => _VotdScreen(votd)));

class _VotdScreen extends StatelessWidget {
  final VotdEntry votd;
  const _VotdScreen(this.votd);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: BottomHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomHomeBar(),
      body: FutureBuilder<tec.ErrorOrValue<Map<int, String>>>(
        future: votd.getRes(VolumesRepository.shared.bibleWithId(51)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final res = snapshot.data.value;
            return Column(
              children: [
                TecImage(
                  url: votd.imageUrl,
                  colorBlendMode: BlendMode.softLight,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white24,
                ),
                Text(votd.ref.label()),
                for (final entry in res.entries) Text(entry.value)
              ],
            );
          }
          return const Center(child: LoadingIndicator());
        },
      ),
    );
  }
}

Future<void> showAllVotd(BuildContext context, Votd votd, {DateTime scrollToDateTime}) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => _VotdsScreen(votd)));

class _VotdsScreen extends StatelessWidget {
  final Votd votd;
  const _VotdsScreen(this.votd);

  @override
  Widget build(BuildContext context) {
    final votds = <VotdEntry>[];
    final days = <DateTime>[];
    for (var day = DateTime(tec.today.year, 1, 1);
        day.isBefore(DateTime(tec.today.year, 12, 31)) ||
            day.isAtSameMomentAs(DateTime(tec.today.year, 12, 31));
        day = day.add(const Duration(days: 1))) {
      days.add(day);
      votds.add(votd.forDateTime(day));
    }
    return TecScaffoldWrapper(
        child: Scaffold(
      appBar: AppBar(),
      body: Scrollbar(
        child: ListView.builder(
            itemCount: votds.length,
            itemBuilder: (c, i) => DayCard(
                date: days[i],
                title: votds[i].refs,
                imageUrl: votds[i].imageUrl,
                onTap: () => showVotdScreen(context, votds[i]))),
      ),
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_data/chapter_view_data.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/const.dart';
import '../../models/home/votd.dart';
import '../common/common.dart';
import 'day_card.dart';
import 'home.dart';

Future<void> showVotdScreen(BuildContext context, VotdEntry votd) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => _VotdScreen(votd)));

class _VotdScreen extends StatefulWidget {
  final VotdEntry votd;
  const _VotdScreen(this.votd);

  @override
  __VotdScreenState createState() => __VotdScreenState();
}

class __VotdScreenState extends State<_VotdScreen> {
  int _translation;

  void setTranslation(int id) {
    setState(() {
      _translation = id;
    });
  }

  Bible currentBible() {
    // find bible translation from views
    final view = context
        .watch<ViewManagerBloc>()
        .state
        .views
        .firstWhere((v) => v.type == Const.viewTypeChapter)
        ?.uid;
    Bible bible;
    if (view != null) {
      final viewData = ChapterViewData.fromContext(context, view);
      _translation ??= viewData.volumeId;
      bible = VolumesRepository.shared.bibleWithId(viewData.volumeId);
    } else {
      _translation ??= defaultBibleId;
      bible = VolumesRepository.shared.bibleWithId(_translation);
    }
    return bible;
  }

  @override
  Widget build(BuildContext context) {
    final bible = currentBible();
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: BottomHomeFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomHomeBar(),
      body: FutureBuilder<tec.ErrorOrValue<String>>(
        future: widget.votd.getFormattedVerse(bible),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.error == null) {
            final res = snapshot.data.value;
            final ref = widget.votd.ref.copyWith(volume: bible.id);
            return Column(
              children: [
                TecImage(
                  url: widget.votd.imageUrl,
                  colorBlendMode: BlendMode.softLight,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white24,
                ),
                Text(ref.label()),
                Text(res)
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

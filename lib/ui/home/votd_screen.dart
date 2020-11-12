import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_data/chapter_view_data.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/const.dart';
import '../../models/home/interstitial.dart';
import '../../models/home/votd.dart';
import '../common/common.dart';
import 'day_card.dart';
import 'home.dart';

Future<void> showVotdScreen(BuildContext context, VotdEntry votd) async {
  await Interstitial.init(context, adUnitId: Const.prefNativeAdId);
  await Navigator.of(context, rootNavigator: true)
      .push<void>(MaterialPageRoute(builder: (c) => _VotdScreen(votd)));
  await Interstitial.show(context);
}

class _VotdScreen extends StatefulWidget {
  final VotdEntry votd;
  const _VotdScreen(this.votd);

  @override
  __VotdScreenState createState() => __VotdScreenState();
}

class __VotdScreenState extends State<_VotdScreen> {
  int _translation;

  @override
  void initState() {
    // _translation ??= currentBible(context).id;
    super.initState();
  }

  void setTranslation(int id) {
    setState(() {
      _translation = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bible = currentBible(context);
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
    Navigator.of(context).push(
        MaterialPageRoute(builder: (c) => _VotdsScreen(votd, scrollToDateTime: scrollToDateTime)));

class _VotdsScreen extends StatelessWidget {
  final Votd votd;
  final DateTime scrollToDateTime;
  const _VotdsScreen(this.votd, {this.scrollToDateTime});

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
      appBar: AppBar(
        title: Text('${tec.today.year} Verses Of The Day'),
      ),
      body: Scrollbar(
        child: ScrollablePositionedList.builder(
            initialScrollIndex: scrollToDateTime == null
                ? days.indexOf(tec.today)
                : days.indexOf(tec.dateOnly(scrollToDateTime)),
            itemCount: votds.length,
            itemBuilder: (c, i) => FutureBuilder<tec.ErrorOrValue<String>>(
                future: votds[i].getFormattedVerse(currentBible(context)),
                builder: (context, snapshot) => DayCard(
                    date: days[i],
                    title: votds[i].ref.label(),
                    body: snapshot.data?.value ?? '',
                    imageUrl: votds[i].imageUrl,
                    onTap: () => showVotdScreen(context, votds[i])))),
      ),
    ));
  }
}

Bible currentBible(BuildContext context) {
  // find bible translation from views
  final view = context
      .tbloc<ViewManagerBloc>()
      .state
      .views
      .firstWhere((v) => v.type == Const.viewTypeChapter, orElse: () => null)
      ?.uid;
  Bible bible;
  if (view != null) {
    final viewData = ChapterViewData.fromContext(context, view);
    bible = VolumesRepository.shared.bibleWithId(viewData.volumeId);
  } else {
    bible = VolumesRepository.shared.bibleWithId(defaultBibleId);
  }
  return bible;
}

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/shared_bible_ref_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/chapter_verses.dart';
import '../../models/const.dart';
import '../../models/home/interstitial.dart';
import '../../models/home/saves.dart';
import '../../models/home/votd.dart';
import '../../models/pref_item.dart';
import '../../models/search/tec_share.dart';
import '../common/common.dart';
import '../library/library.dart';
import '../volume/volume_view_data.dart';
import 'day_card.dart';

Future<void> showVotdScreen(BuildContext context, VotdEntry votd) async {
  await Interstitial.init(context, adUnitId: Const.prefNativeAdId);
  await Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => _VotdScreen(votd)));
  await Interstitial.show(context);
}

const imageAspectRatio = 1080.0 / 555.0;

class _VotdScreen extends StatefulWidget {
  final VotdEntry votd;

  const _VotdScreen(this.votd);

  @override
  __VotdScreenState createState() => __VotdScreenState();
}

class __VotdScreenState extends State<_VotdScreen> {
  Bible _bible;

  @override
  void initState() {
    _bible ??= currentBibleFromContext(context);
    super.initState();
  }

  void setBible(Bible bible) {
    setState(() {
      _bible = bible;
    });
  }

  Future<void> onRefTap() async {
    final vol =
        await selectVolumeInLibrary(context, title: 'Select Bible', selectedVolume: _bible.id);
    if (vol != null) {
      setBible(VolumesRepository.shared.volumeWithId(vol).assocBible());
    }
  }

  Future<void> share() async {
    final copyWithLink = context.tbloc<PrefItemsBloc>().itemBool(PrefItemId.includeShareLink);
    if (!copyWithLink) {
      final text = await tecShowProgressDlg<tec.ErrorOrValue<ReferenceAndVerseText>>(
        context: context,
        title: 'Preparing to share...',
        future: _bible.referenceAndVerseTextWith(widget.votd.ref),
      );
      if (text.value.error == null && text.value.value != null) {
        final toShare =
            ChapterVerses.formatForShare([text.value.value.reference], text.value.value.verseText);
        TecShare.share(toShare);
      }
    } else {
      final text = await _bible.referenceAndVerseTextWith(widget.votd.ref);
      if (text.error == null && text.value != null) {
        final toShare = ChapterVerses.formatForShare([text.value.reference], text.value.verseText);
        await TecShare.shareWithLink(toShare, text.value.reference);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TecImageAppBarScaffold(
      imageUrl: widget.votd.imageUrl,
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
      imageAspectRatio: imageAspectRatio,
      //  scrollController: scrollController,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      actions: [
        IconButton(
            icon: const TecIcon(
              Icon(Icons.share),
              color: Colors.white,
              shadowColor: Colors.black,
            ),
            onPressed: share),
        FutureBuilder<OtdSaves>(
          future: OtdSaves.fetch(),
          builder: (c, s) => IconButton(
              icon: TecIcon(
                Icon(s.hasData && s.data.hasItem(votdType, widget.votd.year, widget.votd.ordinalDay)
                    ? Icons.bookmark
                    : Icons.bookmark_border),
                color: Colors.white,
                shadowColor: Colors.black,
              ),
              onPressed: () async {
                await s.data?.saveOtd(
                    cardTypeId: votdType, year: widget.votd.year, day: widget.votd.ordinalDay);
                setState(() {});
              }),
        ),
      ],
      childBuilder: (c, i) => FutureBuilder<tec.ErrorOrValue<String>>(
        future: widget.votd.getFormattedVerse(_bible),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data.error == null) {
            final res = snapshot.data.value;
            final ref = widget.votd.ref.copyWith(volume: _bible.id);
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TecText(
                        res,
                        style: cardSubtitleCompactStyle,
                        textScaleFactor: contentTextScaleFactorWith(context),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 5),
                      FlatButton(
                        padding: EdgeInsets.zero,
                        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          TecText(
                            ref.label(),
                            style: cardTitleCompactStyle,
                            textScaleFactor: contentTextScaleFactorWith(context),
                          ),
                          Icon(Icons.arrow_drop_down, color: Theme.of(context).textColor),
                        ]),
                        onPressed: onRefTap,
                      ),
                    ],
                  ),
                ),
              ),
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

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: MinHeightAppBar(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const TecText(
            'Verse Of The Day',
            autoSize: true,
          ),
        ),
      ),
      body: Scrollbar(
        child: SafeArea(
            bottom: false,
            child: ScrollablePositionedList.builder(
                initialScrollIndex: scrollToDateTime == null
                    ? days.indexOf(tec.today)
                    : days.indexOf(tec.dateOnly(scrollToDateTime)),
                itemCount: votds.length,
                itemBuilder: (c, i) => FutureBuilder<tec.ErrorOrValue<String>>(
                    future: votds[i].getFormattedVerse(currentBibleFromContext(context)),
                    builder: (context, snapshot) => DayCard(
                        date: days[i],
                        title: votds[i].ref.label(),
                        body: snapshot.data?.value ?? '',
                        imageUrl: votds[i].imageUrl,
                        onTap: () => showVotdScreen(context, votds[i]))))),
      ),
    );
  }
}

Bible currentBibleFromContext(BuildContext context) {
  // find bible translation from views
  final bible = VolumesRepository.shared.bibleWithId(((context.viewManager.state.views
              .firstWhere(
                  (v) =>
                      v.type == Const.viewTypeVolume &&
                      isBibleId(VolumeViewData.fromContext(context, v.uid)?.volumeId),
                  orElse: () => null)
              ?.volumeDataWith(context))
          ?.volumeId) ??
      defaultBibleId);
  return bible;
}

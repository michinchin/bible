import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/home/dotds.dart';
import '../../models/home/votd.dart';
import '../common/common.dart';
import 'dotd_screen.dart';
import 'votd_screen.dart';

class TodayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
            padding: const EdgeInsets.only(top: 10),
            child: ListView(children: [
              const _Label('Verse of the Day'),
              const SizedBox(height: 5),
              _VotdCard(),
              const SizedBox(height: 5),
              const _Label('Devotional of the Day'),
              const SizedBox(height: 5),
              _DotdCard(),
            ])));
  }
}

double dayCardHeight(BuildContext c) => 300;

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListLabel(
        '$text: ${tec.shortDate(tec.today)}',
        style: cardSubtitleCompactStyle.copyWith(color: Theme.of(context).textColor),
      ),
    );
  }
}

class _DotdCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Dotds>(
      future: Dotds.fetch(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final dotd = snapshot.data?.devoForDate(DateTime.now());
          return _HomeCard(
            title: dotd.title,
            subtitle: dotd.intro,
            onImageTap: () => showDotdScreen(context, dotd),
            imageUrl: dotd.imageUrl,
            onMoreTap: () => showAllDotd(context, snapshot.data),
          );
        }
        return const Center(child: LoadingIndicator());
      },
    );
  }
}

class _VotdCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Votd>(
      future: Votd.fetch(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final votd = snapshot.data.forDateTime(DateTime.now());
          return FutureBuilder<tec.ErrorOrValue<String>>(
              future: votd.getFormattedVerse(currentBibleFromContext(context)),
              builder: (context, s) {
                if (s.hasData && s.data.error == null) {
                  final subtitle = s.data.value;
                  return _HomeCard(
                    title: votd.ref.label(),
                    subtitle: subtitle,
                    onImageTap: () => showVotdScreen(context, votd),
                    imageUrl: votd.imageUrl,
                    onMoreTap: () => showAllVotd(context, snapshot.data),
                  );
                }
                return const Center(
                  child: LoadingIndicator(),
                );
              });
        }
        return const Center(child: LoadingIndicator());
      },
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onImageTap;
  final String imageUrl;
  final VoidCallback onMoreTap;
  const _HomeCard(
      {@required this.title,
      @required this.subtitle,
      @required this.onImageTap,
      @required this.imageUrl,
      @required this.onMoreTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TecCard(
          padding: 0,
          color: Theme.of(context).cardColor,
          builder: (c) => Column(children: [
            Stack(children: [
              InkWell(
                onTap: onImageTap,
                child: TecImage(
                  color: Colors.black12,
                  colorBlendMode: BlendMode.colorBurn,
                  url: imageUrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TecText(
                        title,
                        style: cardTitleCompactStyle.copyWith(color: Colors.white, fontSize: 40),
                        textScaleFactor: textScaleFactorWith(context),
                        maxLines: 3,
                      ),
                    ),
                    InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onMoreTap,
                        child: const Icon(SFSymbols.ellipsis_circle, color: Colors.white)),
                  ],
                ),
              ),
            ]),
            InkWell(
                onTap: onImageTap,
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TecText(
                      subtitle,
                      style: cardSubtitleCompactStyle.copyWith(color: Theme.of(context).textColor),
                      textScaleFactor: textScaleFactorWith(context),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ))),
          ]),
        ));
  }
}

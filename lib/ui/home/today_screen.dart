import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
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
            height: dayCardHeight(context),
            child: Row(children: [Expanded(child: _VotdCard()), Expanded(child: _DotdCard())])));
  }
}

double dayCardHeight(BuildContext c) => 200;

class _DotdCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Dotds>(
      future: Dotds.fetch(AppSettings.shared.env),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final dotd = snapshot.data?.devoForDate(DateTime.now());
          return _HomeCard(
            title: dotd.title,
            onImageTap: () => showDotdScreen(context, dotd),
            imageUrl: dotd.imageUrl(AppSettings.shared.env),
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
      future: Votd.fetch(AppSettings.shared.env),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final votd = snapshot.data.forDateTime(DateTime.now());
          return _HomeCard(
            title: votd.ref.label(),
            onImageTap: () => showVotdScreen(context, votd),
            imageUrl: votd.imageUrl,
            onMoreTap: () => showAllVotd(context, snapshot.data),
          );
        }
        return const Center(child: LoadingIndicator());
      },
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final VoidCallback onImageTap;
  final String imageUrl;
  final VoidCallback onMoreTap;
  const _HomeCard(
      {@required this.title,
      @required this.onImageTap,
      @required this.imageUrl,
      @required this.onMoreTap});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TecCard(
              elevation: 0,
              padding: 0,
              color: Theme.of(context).cardColor,
              onTap: onImageTap,
              builder: (c) => TecImage(
                height: dayCardHeight(c),
                url: imageUrl,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TecText(
                  title,
                  autoSize: true,
                  style: cardSubtitleCompactStyle.copyWith(color: Theme.of(context).textColor),
                  textScaleFactor: textScaleFactorWith(context),
                  maxLines: 1,
                ),
              ),
              InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onMoreTap,
                  child: Icon(SFSymbols.ellipsis_circle, color: Theme.of(context).textColor)),
            ],
          ),
        ),
      ],
    );
  }
}

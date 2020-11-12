import 'package:flutter/material.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../../models/home/dotd.dart';
import '../../models/home/votd.dart';
import '../common/common.dart';
import 'dotd_screen.dart';
import 'votd_screen.dart';

class TodayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: _VotdCard()), Expanded(child: _DotdCard())])));
  }
}

double dayCardHeight(BuildContext c) => MediaQuery.of(c).size.width / 2 - 20;

class _DotdCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Dotd>(
      future: Dotd.fetch(AppSettings.shared.env),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final dotd = snapshot.data?.devoForDate(DateTime.now());
          return Column(
            children: [
              TecCard(
                onTap: () => showDotdScreen(context, dotd),
                builder: (c) => Stack(alignment: Alignment.center, children: [
                  TecImage(
                    height: dayCardHeight(c),
                    url: dotd?.imageUrl(AppSettings.shared.env),
                    colorBlendMode: BlendMode.softLight,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white24,
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TecText(
                        dotd.title,
                        autoSize: true,
                        // style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () => showAllDotd(context, snapshot.data),
                      ),
                    ),
                  ],
                ),
              )
            ],
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
          return Column(
            children: [
              TecCard(
                onTap: () => showVotdScreen(context, votd),
                builder: (c) => Stack(alignment: Alignment.center, children: [
                  TecImage(
                    height: dayCardHeight(c),
                    url: votd.imageUrl,
                    colorBlendMode: BlendMode.softLight,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white24,
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TecText(
                        votd.ref.label(),
                        autoSize: true,
                        // style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () => showAllVotd(context, snapshot.data),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }
        return const Center(child: LoadingIndicator());
      },
    );
  }
}

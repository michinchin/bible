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
    return Column(children: [
      FutureBuilder<Votd>(
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
                      Text('VOTD: ${votd.ref.label()}'),
                      OutlineButton(
                        child: const Text('More'),
                        onPressed: () => showAllVotd(context, snapshot.data),
                      ),
                    ],
                  ),
                )
              ],
            );
          }
          return const Center(child: LoadingIndicator());
        },
      ),
      FutureBuilder<Dotd>(
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
                      Text('DOTD: ${dotd?.title}'),
                      OutlineButton(
                        child: const Text('More'),
                        onPressed: () => showAllDotd(context, snapshot.data),
                      ),
                    ],
                  ),
                )
              ],
            );
          }
          return const Center(child: LoadingIndicator());
        },
      ),
    ]);
  }
}

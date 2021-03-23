import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../../models/home/dotds.dart';
import '../../models/home/votd.dart';
import '../../models/reference_ext.dart';
import '../common/common.dart';
import 'dotd_screen.dart';
import 'votd_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final portraitMode = MediaQuery.of(context).orientation == Orientation.portrait;
    return SafeArea(
        bottom: false,
        child: ListView(children: [
          Container(
              padding: EdgeInsets.only(top: 10, bottom: portraitMode ? 0 : 10),
              child: isSmallScreen(context) && portraitMode
                  ? SizedBox(
                      height: dayCardHeight * 2 + 50, //padding = 10+40
                      child: Column(
                          // scrollDirection: portraitMode ? Axis.vertical : Axis.horizontal,
                          children: [
                            Expanded(child: _VotdCard()),
                            const SizedBox(height: 10),
                            Expanded(child: _DotdCard()),
                            const SizedBox(height: 40)
                          ]),
                    )
                  : SizedBox(
                      height: dayCardHeight,
                      child: Row(
                        children: [
                          Expanded(child: _VotdCard()),
                          Expanded(child: _DotdCard()),
                        ],
                      ),
                    )),
        ]));
  }
}

double get dayCardHeight => 300;

class _DotdCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Dotds>(
      future: Dotds.fetch(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final dotd = snapshot.data?.devoForDate(DateTime.now());
          return _HomeCard(
            type: 'Devotional of the day',
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
          return FutureBuilder<ErrorOrValue<String>>(
              future: votd.getFormattedVerse(currentBibleFromContext(context)),
              builder: (context, s) {
                if (s.hasData && s.data.error == null) {
                  final subtitle = s.data.value;
                  return _HomeCard(
                    type: 'Verse of the day',
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
  final String type;
  final String title;
  final String subtitle;
  final VoidCallback onImageTap;
  final String imageUrl;
  final VoidCallback onMoreTap;

  const _HomeCard(
      {@required this.type,
      @required this.title,
      @required this.subtitle,
      @required this.onImageTap,
      @required this.imageUrl,
      @required this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: GestureDetector(
          onTap: onImageTap,
          behavior: HitTestBehavior.translucent,
          child: TecCard(
            elevation: 0,
            padding: 0,
            color: Theme.of(context).cardColor,
            builder: (c) => Stack(
              children: [
                Positioned.fill(
                  child: TecImage(
                    color: Colors.black12,
                    colorBlendMode: BlendMode.darken,
                    url: imageUrl,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Expanded(
                                  child: TecText(
                                type.toUpperCase(),
                                style: cardSubtitleCompactStyle.copyWith(
                                  color: const Color(0xDDFFFFFF),
                                  fontWeight: FontWeight.w600,
                                  shadows: <Shadow>[
                                    const Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 2.0,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                // autoSize: true,
                                // textScaleFactor: contentTextScaleFactorWith(c),
                              )),
                              InkWell(
                                  onTap: onMoreTap,
                                  child: const TecIcon(
                                    Icon(SFSymbols.ellipsis_circle),
                                    color: Colors.white,
                                    shadowColor: Colors.black,
                                  )),
                            ]),
                            Expanded(
                              child: TecText(
                                title,
                                style: cardTitleCompactStyle.copyWith(
                                  color: Colors.white,
                                  shadows: <Shadow>[
                                    const Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 2.0,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                                // textScaleFactor: contentTextScaleFactorWith(c),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            color: Colors.white24,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: TecText(
                                subtitle,
                                style: cardSubtitleCompactStyle
                                    .copyWith(color: Colors.white, shadows: <Shadow>[
                                  const Shadow(
                                      offset: Offset(1,1),
                                      blurRadius: 2.0,
                                      color: Colors.black),
                                ]),
                                textScaleFactor: contentTextScaleFactorWith(context),
                                maxLines: 3,
                                // autoSize: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

/// Returns a frosted background for constrained height child
Widget buildBkgFrost(BuildContext context, WidgetBuilder childBuilder,
        {double bottomCornerRadius = 15.0}) =>
    ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(bottomCornerRadius),
          bottomRight: Radius.circular(bottomCornerRadius),
        ),
        child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(15),
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.black.withOpacity(0.2),
              child: childBuilder(context),
            )));

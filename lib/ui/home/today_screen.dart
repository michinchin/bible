import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:tec_util/tec_util.dart' as tec;
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
    final portraitMode = MediaQuery.of(context).orientation == Orientation.portrait ||
        (MediaQuery.of(context).size.height > 500 && MediaQuery.of(context).size.width > 500);
    return SafeArea(
        bottom: false,
        child: Container(
            padding: EdgeInsets.only(top: 10, bottom: portraitMode ? 0 : 10),
            child: ListView(
                // scrollDirection: portraitMode ? Axis.vertical : Axis.horizontal,
                children: [
                  _VotdCard(),
                  const SizedBox(height: 10),
                  _DotdCard(),
                  if (portraitMode)
                    const Divider(color: Colors.transparent, height: 40)
                  else
                    const VerticalDivider(color: Colors.transparent, width: 80)
                ])));
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
          return FutureBuilder<tec.ErrorOrValue<String>>(
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
        child: TecCard(
          elevation: 0,
          padding: 0,
          color: Theme.of(context).cardColor,
          builder: (c) => Stack(
            children: [
              Positioned.fill(
                child: InkWell(
                  onTap: onImageTap,
                  child: TecImage(
                    color: Colors.black12,
                    colorBlendMode: BlendMode.colorBurn,
                    url: imageUrl,
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(
                            child: TecText(
                              type.toUpperCase(),
                              style: cardSubtitleCompactStyle.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              autoSize: true,
                              textScaleFactor: contentTextScaleFactorWith(c),
                            ),
                          ),
                          InkWell(
                              onTap: onMoreTap,
                              child: const Icon(SFSymbols.ellipsis_circle, color: Colors.white)),
                        ]),
                        TecText(
                          title,
                          style: cardTitleCompactStyle.copyWith(
                            color: Colors.white,
                          ),
                          textScaleFactor: contentTextScaleFactorWith(c),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onImageTap,
                      child: buildBkgFrost(
                          context,
                          (context) => Container(
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: TecText(
                                      subtitle,
                                      style: cardSubtitleCompactStyle.copyWith(
                                        color: Colors.white,
                                      ),
                                      textScaleFactor: contentTextScaleFactorWith(context),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    // const VerticalDivider(
                                    //   color: Colors.transparent,
                                    // ),
                                    // InkWell(
                                    //   onTap: onMoreTap,
                                    //   child: Container(
                                    //       padding: const EdgeInsets.symmetric(
                                    //           horizontal: 15, vertical: 5),
                                    //       decoration: const ShapeDecoration(
                                    //         shape: StadiumBorder(),
                                    //         color: Colors.white,
                                    //       ),
                                    //       child: const TecText(
                                    //         'All',
                                    //         style: TextStyle(
                                    //             fontWeight: FontWeight.bold,
                                    //             color: Const.tecartaBlue),
                                    //       )),
                                    // ),
                                  ],
                                ),
                              )),
                    ),
                  )
                ],
              ),
            ],
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
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.black.withOpacity(0.2),
              child: childBuilder(context),
            )));

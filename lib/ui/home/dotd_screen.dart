import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tec_html/tec_html.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/tab_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/home/dotd.dart';
import '../../models/home/dotds.dart';
import '../../models/home/interstitial.dart';
import '../../models/home/saves.dart';
import '../../models/notifications/notifications_model.dart';
import '../../models/search/tec_share.dart';
import '../common/common.dart';
import '../library/library.dart';
import '../library/volume_image.dart';
import 'day_card.dart';
import 'votd_screen.dart';

Future<void> showDotdScreen(BuildContext context, Dotd devo) async {
  // we need to save the tabManager - as rotation with ads messes with context
  // ignore: close_sinks
  final tabManager = context.tabManager..add(TecTabEvent.hideTabBar);

  // ads aren't based on productIds...
  await Interstitial.init(/*devo.productId*/);

  if (isSmallScreen(context)) {
    await Navigator.of(context).push<void>(MaterialPageRoute(builder: (c) => _DotdScreen(devo)));
  } else {
    await showScreen<void>(
        context: context, builder: (c) => _DotdScreen(devo), bottomAttached: true);
  }

  if (!await NotificationsModel.initNotifications(context)) {
    await Interstitial.show(context);
  }

  tabManager.add(TecTabEvent.showTabBar);
}

class _DotdScreen extends StatefulWidget {
  final Dotd devo;

  const _DotdScreen(this.devo);

  @override
  __DotdScreenState createState() => __DotdScreenState();
}

class __DotdScreenState extends State<_DotdScreen> {
  var _showDevoButton = false;
  Future<String> _devoHtmlFuture;

  @override
  void initState() {
    _devoHtmlFuture = widget.devo.html(AppSettings.shared.env);
    super.initState();
  }

  Future<void> share() async {
    TecShare.share(await widget.devo.shareText());
  }

  @override
  Widget build(BuildContext context) {
    const imageWidth = 70.0;
    return TecImageAppBarScaffold(
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
                Icon(s.hasData && s.data.hasItem(dotdType, widget.devo.year, widget.devo.ordinalDay)
                    ? Icons.bookmark
                    : Icons.bookmark_border),
                color: Colors.white,
                shadowColor: Colors.black,
              ),
              onPressed: () async {
                await s.data?.saveOtd(
                    cardTypeId: dotdType, year: widget.devo.year, day: widget.devo.ordinalDay);
                setState(() {});
              }),
        ),
      ],
      imageUrl: widget.devo.imageUrl,
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
      imageAspectRatio: imageAspectRatio,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      childBuilder: (c, i) => FutureBuilder<String>(
          future: _devoHtmlFuture,
          builder: (c, snapshot) {
            if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              return SafeArea(
                top: false,
                child: Column(children: [
                  TecHtml(
                    snapshot.data,
                    isInitialHtmlElementVisible: false,
                    // TODO(ron): this is an if for old devo base url
                    baseUrl: (widget.devo.volume != null)
                        ? VolumesRepository.shared.volumeWithId(widget.devo.productId)?.baseUrl
                        : '$cloudFrontStreamUrl/${widget.devo.productId}/urlbase/',
                    onLoadFinished: (error) => setState(() => _showDevoButton = true),
                    textScaleFactor: contentTextScaleFactorWith(c),
                    selectable: false,
                  ),
                  // volume is null on old devos
                  // TODO(ron): remove if when using refresh...
                  if (_showDevoButton && widget.devo.volume != null)
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () => showDetailViewForVolume(c, widget.devo.volume, 'dotd'),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: TecCard(
                                  cornerRadius: 10,
                                  builder: (c) => VolumeImage(
                                    volume: widget.devo.volume,
                                    width: imageWidth,
                                  ),
                                ),
                              ),
                              const VerticalDivider(color: Colors.transparent),
                              Expanded(
                                child: TecText.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${widget.devo.volume.name}\n',
                                        style: cardTitleCompactStyle,
                                      ),
                                      TextSpan(
                                        text: 'by ${widget.devo.volume.author}',
                                        style: cardSubtitleCompactStyle,
                                      ),
                                      // WidgetSpan(
                                      //     child: RaisedButton(
                                      //   color: Theme.of(context).cardColor,
                                      //   child: const Text('Learn More'),
                                      //   onPressed: () =>
                                      //       showVolumeDetailView(context, widget.devo.volume),
                                      // ))
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )),
                    ),
                  const Divider(height: 50, color: Colors.transparent)
                ]),
              );
            }
            return const LoadingIndicator();
          }),
    );
  }
}

// final res = await Resource.fetch(
//         env: env,
//         volumeId: devo.productId,
//         resourceId: devo.resourceId,
//       );

Future<void> showAllDotd(BuildContext context, Dotds dotd, {DateTime scrollToDateTime}) =>
    Navigator.of(context).push(MaterialPageRoute(
        builder: (c) => _DotdsScreen(
              dotd,
              scrollToDateTime: scrollToDateTime,
            )));

class _DotdsScreen extends StatefulWidget {
  final Dotds dotd;
  final DateTime scrollToDateTime;

  const _DotdsScreen(this.dotd, {this.scrollToDateTime});

  @override
  __DotdsScreenState createState() => __DotdsScreenState();
}

class __DotdsScreenState extends State<_DotdsScreen> {
  final dotds = <Dotd>[];
  final days = <DateTime>[];
  int scrollIndex;

  @override
  void initState() {
    for (var day = DateTime(today.year, 1, 1);
        day.isBefore(DateTime(today.year, 12, 31)) ||
            day.isAtSameMomentAs(DateTime(today.year, 12, 31));
        day = addDaysToDateTime(day, 1)) {
      days.add(day);
      dotds.add(widget.dotd.devoForDate(day));
    }

    scrollIndex = widget.scrollToDateTime == null
        ? days.indexOf(today)
        : days.indexOf(dateOnly(widget.scrollToDateTime));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: MinHeightAppBar(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const TecText(
            'Devotional Of The Day',
            autoSize: true,
          ),
        ),
      ),
      body: TecScrollbar(
        child: SafeArea(
            child: ScrollablePositionedList.builder(
                initialScrollIndex: scrollIndex,
                itemCount: dotds.length,
                itemBuilder: (c, i) => DayCard(
                    date: days[i],
                    title: dotds[i].title,
                    body: dotds[i].intro,
                    imageUrl: dotds[i].imageUrl,
                    onTap: () => showDotdScreen(context, dotds[i])))),
      ),
    );
  }
}

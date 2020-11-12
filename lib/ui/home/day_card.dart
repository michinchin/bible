import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../common/common.dart';

class DayCard extends StatelessWidget {
  final DateTime date;
  final String title;
  final String imageUrl;
  final String body;
  final VoidCallback onTap;
  const DayCard(
      {@required this.date,
      @required this.title,
      @required this.imageUrl,
      @required this.onTap,
      this.body = ''});

  @override
  Widget build(BuildContext context) {
    const height = 100.0;
    final scale = scaleFactorWith(context);
    final textScale = textScaleFactorWith(context);
    final heading = TecText(
      title,
      textScaleFactor: textScale,
      style: cardTitleCompactStyle.copyWith(color: Theme.of(context).textColor),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final intro = Expanded(
        child: TecText(
      body,
      style: cardSubtitleCompactStyle.copyWith(color: Theme.of(context).textColor),
      textScaleFactor: textScale,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ));

    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        margin: const EdgeInsets.all(8),
        // color: Theme.of(context).cardColor,
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Hero(
                  tag: title,
                  child: TecImage(
                    width: height,
                    height: height,
                    fit: BoxFit.cover,
                    url: imageUrl,
                    colorBlendMode: BlendMode.darken,
                    color: Colors.black26,
                  ),
                ),
                Container(
                  height: height,
                  width: height,
                  padding: EdgeInsets.all(10.0 * scale),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Flexible(
                      flex: 1,
                      child: TecText(
                        '${tec.shortNameOfWeekday(date.weekday)},'
                        ' ${tec.shortNameOfMonth(date.month)}',
                        autoSize: true,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: TecText(
                        '${date.day}',
                        autoSize: true,
                        style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.white),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0 * scale),
                    child: heading,
                  ),
                  intro
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

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
    const height = 80.0;
    // final scale = scaleFactorWith(context);
    final heading = TextSpan(
      text: '$title\n',
      style: cardSubtitleCompactStyle.copyWith(fontWeight: FontWeight.bold),
      // maxLines: 1,
      // overflow: TextOverflow.ellipsis,
    );
    final intro = TextSpan(
      text: body,
      style: cardSubtitleCompactStyle,
      // maxLines: 2,
      // overflow: TextOverflow.ellipsis,
    );

    return InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          margin: const EdgeInsets.all(8),
          // color: Theme.of(context).cardColor,
          child: Row(children: [
            DateWithImage(
              date: date,
              imageUrl: imageUrl,
              side: height,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TecText.rich(
                  TextSpan(children: [heading, intro]),
                  overflow: TextOverflow.ellipsis,
                  autoCalcMaxLines: true,
                ),
              ),
            )
          ]),
        ));
  }
}

class DateWithImage extends StatelessWidget {
  final DateTime date;
  final String imageUrl;
  final double side;
  const DateWithImage({this.date, this.imageUrl, this.side});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        children: [
          TecImage(
            width: side,
            height: side,
            fit: BoxFit.cover,
            url: imageUrl,
            colorBlendMode: BlendMode.darken,
            color: Colors.black26,
          ),
          Container(
            height: side,
            width: side,
            padding: const EdgeInsets.all(10.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Flexible(
                flex: 1,
                child: TecText(
                  '${tec.shortNameOfWeekday(date.weekday)},'
                  ' ${tec.shortNameOfMonth(date.month)}',
                  autoSize: true,
                  minFontSize: 8,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                flex: 2,
                child: TecText(
                  '${date.day}',
                  autoSize: true,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headline4.copyWith(color: Colors.white),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

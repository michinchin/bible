import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../common/common.dart';
import 'volume_image.dart';

class VolumeDetail extends StatelessWidget {
  final Volume volume;

  const VolumeDetail({Key key, this.volume}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: appBarThemeWithContext(context)),
      child: Scaffold(
        appBar: MinHeightAppBar(
          appBar: AppBar(
              //title: TecText(volume.name, maxLines: 2, textAlign: TextAlign.center),
              ),
        ),
        body: _VolumeCard(volume: volume),
      ),
    );
  }
}

class _VolumeCard extends StatelessWidget {
  final Volume volume;
  final Widget buttons;
  const _VolumeCard({this.volume, this.buttons});
  @override
  Widget build(BuildContext context) {
    final textScaleFactor = textScaleFactorWith(context);
    final padding = (16.0 * textScaleFactor).roundToDouble();
    //final halfPad = (padding / 2.0).roundToDouble();

    final insets = EdgeInsets.only(right: padding, left: padding);

    final mqd = MediaQuery.of(context);
    final imageHeight = math.min(mqd.size.width - 100.0, 500.0) * 0.6;
    // final imageWidth = imageHeight - insets.left;

    return Padding(
      padding: insets,
      child: Container(
        height: 35 + imageHeight + imageHeight / 2,
        width: MediaQuery.of(context).size.width - insets.left * 2,
        child: Stack(alignment: Alignment.topLeft, children: [
          Container(
            margin: EdgeInsets.only(top: imageHeight / 3),
            height: double.infinity,
            width: double.infinity,
            child: TecCard(
                padding: 0, color: Theme.of(context).cardColor, builder: (c) => Container()),
          ),
          Column(
            children: [
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TecCard(
                        padding: padding,
                        elevation: 4,
                        cornerRadius: 5,
                        builder: (context) => VolumeImage(volume: volume),
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.only(
                          top: imageHeight / 3 + insets.right,
                          right: insets.right,
                          bottom: insets.right),
                      child: _titleEtc(context, volume),
                    ))
                  ],
                ),
              ),
              if (volume.onSale && buttons != null) ...[
                buttons,
                const Divider(
                  color: Colors.transparent,
                )
              ]
            ],
          ),
        ]),
      ),
    );
  }
}

Widget _titleEtc(BuildContext context, Volume volume) {
  final titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).textColor,
  );

  final subtitleStyle = TextStyle(
    fontSize: 14,
    //fontWeight: FontWeight.w600,
    color: Theme.of(context).textColor, // Theme.of(context).textColor.withOpacity(0.8),
  );

  final textScaleFactor = textScaleFactorWith(context);

  return TecText.rich(
    TextSpan(
      children: <TextSpan>[
        TextSpan(style: titleStyle, text: '${volume.name}\n'),
        TextSpan(style: subtitleStyle, text: volume.publisher),
      ],
    ),
    //autoSize: true,
    //minScaleFactor: 0.5,
    //minFontSize: 5,
    //maxScaleFactor: 2,
    //textAlign: TextAlign.left,
    textScaleFactor: textScaleFactor,
  );
}

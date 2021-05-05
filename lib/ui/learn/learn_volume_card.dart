import 'package:flutter/material.dart';

import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../library/volume_image.dart';

class LearnVolumeCard extends StatelessWidget {
  final Volume volume;
  final String studyText;
  final VoidCallback onTap;
  final String heroPrefix;
  final Widget trailing;

  const LearnVolumeCard({
    Key key,
    @required this.volume,
    @required this.studyText,
    this.onTap,
    this.heroPrefix,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = textScaleFactorWith(context);
    final padding = (6.0 * textScaleFactor).roundToDouble();

    final imgWidth = 50.0 * textScaleFactor;
    final imgHeight = 1.47368 * imgWidth;
    final borderRadius = imgWidth / 7.0;

    return Row(
      // mainAxisSize: MainAxisSize.max,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(left: padding * 2, top: padding, bottom: padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Material(
                    elevation: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                      child: VolumeImage(
                        key: key,
                        volume: volume,
                        width: imgWidth,
                        height: imgHeight,
                        fit: BoxFit.cover,
                        heroPrefix: heroPrefix,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      // color: Colors.red,
                      padding: EdgeInsets.only(left: padding * 2, top: 0, right: padding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TecText(
                            studyText,
                            textScaleFactor: textScaleFactor,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).textColor),
                          ),
                          TecText(
                            volume.name,
                            textScaleFactor: textScaleFactor,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).textColor.withOpacity(0.65)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}

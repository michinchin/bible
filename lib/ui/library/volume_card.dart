import 'package:flutter/material.dart';

import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import 'volume_image.dart';

class VolumeCard extends StatelessWidget {
  final Volume volume;
  final VoidCallback onTap;
  final bool heroAnimated;
  final Widget trailing;

  const VolumeCard({
    Key key,
    @required this.volume,
    this.onTap,
    this.heroAnimated = true,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = textScaleFactorWith(context);
    final padding = (6.0 * textScaleFactor).roundToDouble();

    final imgWidth = 60.0 * textScaleFactor;
    final imgHeight = 1.47368 * imgWidth;

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
                      borderRadius: BorderRadius.all(Radius.circular(padding)),
                      child: VolumeImage(
                        key: key,
                        volume: volume,
                        width: imgWidth,
                        height: imgHeight,
                        fit: BoxFit.cover,
                        heroAnimated: heroAnimated,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      // color: Colors.red,
                      padding: EdgeInsets.only(left: padding * 2, top: padding, right: padding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TecText(
                            '${volume.name}',
                            textScaleFactor: textScaleFactor,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          TecText(
                            '\n${volume.publisher}',
                            textScaleFactor: textScaleFactor,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).textColor,
                            ),
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

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

class VolumeImage extends StatelessWidget {
  final Volume volume;
  final double width;
  final double height;
  final BoxFit fit;
  final String heroPrefix;

  const VolumeImage({
    Key key,
    @required this.volume,
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.heroPrefix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final path = '${tec.streamUrl}/covers/${volume.id}.jpg';
    Widget img() => CachedNetworkImage(
          width: width,
          height: height,
          fit: fit,
          imageUrl: path,
          errorWidget: (context, url, dynamic error) => Container(width: width, height: height),
        );

    return tec.isNotNullOrEmpty(heroPrefix)
        ? Hero(tag: heroTagForVolume(volume, heroPrefix), child: img())
        : img();
  }
}

String heroTagForVolume(Volume volume, String prefix) {
  return '$prefix-volume-${volume.id}';
}

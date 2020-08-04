import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:tec_volumes/tec_volumes.dart';

class VolumeImage extends StatelessWidget {
  const VolumeImage({
    Key key,
    @required this.volume,
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.heroAnimated = true,
  }) : super(key: key);

  final Volume volume;
  final double width;
  final double height;
  final BoxFit fit;
  final bool heroAnimated;

  @override
  Widget build(BuildContext context) {
    final path = 'https://cf-stream.tecartabible.com/7/covers/${volume.id}.jpg';

    final heroTag = '${volume.hashCode}-${volume.id}';
    Widget img() => CachedNetworkImage(
          width: width,
          height: height,
          fit: fit,
          imageUrl: path,
          errorWidget: (context, url, dynamic error) => Container(width: width, height: height),
        );

    return !heroAnimated ? img() : Hero(tag: heroTag, child: img());
  }
}

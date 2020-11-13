import 'package:flutter/foundation.dart';
import 'package:tec_env/tec_env.dart';

import 'package:tec_util/tec_util.dart' as tec;

///
/// DevoRes - Devotional from devo of the days
///
@immutable
class Dotd {
  final int productId;
  final int resourceId;
  final String title;
  final String intro;
  final String imageName;
  final String commands;

  const Dotd({
    @required this.title,
    @required this.intro,
    @required this.commands,
    @required this.imageName,
    @required this.productId,
    @required this.resourceId,
  });

  /// Returns a copy of this object with optional tweaks.
  Dotd copyWith({
    String title,
    String intro,
    String imageName,
    String commands,
    int productId,
    int resourceId,
  }) {
    return Dotd(
      title: title ?? this.title,
      intro: intro ?? this.intro,
      commands: commands ?? this.commands,
      imageName: imageName ?? this.imageName,
      productId: productId ?? this.productId,
      resourceId: resourceId ?? this.resourceId,
    );
  }

  /// Returns a new dotd from parsing devo-of-the-day JSON.
  factory Dotd.fromDotdJson(List<dynamic> json) {
    if (json.length >= 5 && json[1] is List<dynamic> && json[1].length == 2) {
      final productId = tec.as<int>(json[1][0]);
      final resourceId = tec.as<int>(json[1][1]);
      final imageName = tec.as<String>(json[2]);
      final commands = tec.as<String>(json[3]);
      final title = tec.as<String>(json[4]);
      final intro = tec.as<String>(json[5]);
      return Dotd(
          title: title,
          intro: intro,
          imageName: imageName,
          commands: commands,
          productId: productId,
          resourceId: resourceId);
    }
    return null;
  }

  /// Returns the hero tag for the image.
  String get heroTagForImage => '$hashCode-$imageName';
  String imageUrl(TecEnv env) => 'https://${env.streamServer}/${env.apiVersion}/votd/$imageName';

  /// Asynchronously returns a new DevoRes from a JSON list.
  factory Dotd.fromJson(List<dynamic> list) {
    final productId = tec.as<int>(list[1][0]);
    final resourceId = tec.as<int>(list[1][1]);
    final imageName = tec.as<String>(list[2]);
    final commands = tec.as<String>(list[3]);
    final title = tec.as<String>(list[4]);
    final intro = tec.as<String>(list[5]);

    if (tec.isNotNullOrZero(productId) &&
        tec.isNotNullOrZero(resourceId) &&
        tec.isNotNullOrEmpty(imageName) &&
        tec.isNotNullOrEmpty(commands) &&
        tec.isNotNullOrEmpty(title) &&
        tec.isNotNullOrEmpty(intro)) {
      return Dotd(
        title: title,
        intro: intro,
        commands: commands,
        productId: productId,
        resourceId: resourceId,
        imageName: imageName,
      );
    }
    return null;
  }
}

import 'package:flutter/foundation.dart';

import 'package:tec_util/tec_util.dart' as tec;

import 'devo.dart';
import 'dotd.dart';

///
/// DevoRes - Devotional from study resource
///
@immutable
class DevoRes extends Devo {
  final int productId;
  final int resourceId;

  const DevoRes({
    @required String title,
    @required String intro,
    @required String imageName,
    @required this.productId,
    @required this.resourceId,
    int completedDbInt,
    int rating,
  }) : super(
          title: title,
          intro: intro,
          imageName: imageName,
          completedDbInt: completedDbInt,
          rating: rating,
        );

  /// Returns a copy of this object with optional tweaks.
  @override
  DevoRes copyWith({
    String title,
    String intro,
    String imageName,
    DateTime completed,
    bool clearCompleted = false,
    int productId,
    int resourceId,
    int rating,
  }) {
    var newCompletedDbInt = (clearCompleted ? null : completedDbInt);
    if (!clearCompleted && completed != null) {
      newCompletedDbInt = Devo.dbIntFromCompleted(completed);
    }
    return DevoRes(
      title: title ?? this.title,
      intro: intro ?? this.intro,
      imageName: imageName ?? this.imageName,
      completedDbInt: newCompletedDbInt,
      productId: productId ?? this.productId,
      resourceId: resourceId ?? this.resourceId,
      rating: rating ?? this.rating,
    );
  }

  /// Returns a new DevoRes from parsing devo-of-the-day JSON.
  factory DevoRes.fromDotdJson(List<dynamic> json) {
    if (json.length >= 5 && json[1] is List<dynamic> && json[1].length == 2) {
      final productId = tec.as<int>(json[1][0]);
      final resourceId = tec.as<int>(json[1][1]);
      final imageName = tec.as<String>(json[2]);
      final title = tec.as<String>(json[4]);
      final intro = tec.as<String>(json[5]);
      return DevoRes(
          title: title,
          intro: intro,
          imageName: imageName,
          productId: productId,
          resourceId: resourceId);
    }
    return null;
  }

  /// Asynchronously returns a new DevoRes from the given info.
  static Future<DevoRes> fetch({
    @required int productId,
    @required int resourceId,
    @required int imageId,
    @required int completedDbInt,
    @required int ratedInt,
    @required Dotd dotd,
  }) async {
    String title;
    String intro;

    // Is it a "devo-of-the-day" devo?
    final devo =
        dotd?.findDevoWith(productId: productId, resourceId: resourceId);
    if (devo is DevoRes) {
      title = devo.title;
      intro = devo.intro;
    }

    return DevoRes(
      title: title,
      intro: intro,
      imageName: '$imageId.jpg',
      productId: productId,
      resourceId: resourceId,
      completedDbInt: completedDbInt,
      rating: ratedInt
    );
  }

  /// Asynchronously returns a new DevoRes from a JSON list.
  static Future<DevoRes> fromJson(List<dynamic> list, Dotd dotd) async {
    final productId = tec.as<int>(list[0]);
    final resourceId = tec.as<int>(list[1]);
    final imageId = tec.as<int>(list[2]);
    final completedDbInt = (list.length <= 3 ? null : tec.as<int>(list[3]));
    final ratedInt = (list.length <= 4 ? null : tec.as<int>(list[4]));
    if (tec.isNotNullOrZero(productId) &&
        tec.isNotNullOrZero(resourceId) &&
        tec.isNotNullOrZero(imageId)) {
      return DevoRes.fetch(
        productId: productId,
        resourceId: resourceId,
        imageId: imageId,
        completedDbInt: completedDbInt,
        ratedInt: ratedInt,
        dotd: dotd,
      );
    }
    return null;
  }

  /// Returns the JSON string representation of this object.
  @override
  String toJsonStr() {
    final imageId = imageIdFromName(imageName);
    if (isCompleted) {
      return '[$productId, $resourceId, $imageId, $completedDbInt${isRated ? ', $rating' : ''}]';
    }
    return '[$productId, $resourceId, $imageId]';
  }
}

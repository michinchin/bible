import 'package:flutter/foundation.dart';

import 'package:tec_env/tec_env.dart';
import 'package:tec_util/tec_util.dart' as tec;

///
/// Devo - Devotional base class
///
@immutable
abstract class Devo {
  final String title;
  final String intro;
  final String imageName;
  final int completedDbInt;

  /// 1 = thumbs up, -1 = thumbs down, 0 = none selected, null = not yet rated
  final int rating;

  const Devo({
    @required this.title,
    @required this.intro,
    @required this.imageName,
    @required this.completedDbInt,
    this.rating,
  });

  DateTime get completed =>
      tec.dateTimeFromDbInt(completedDbInt, ignoreTimeZone: true);

  static int dbIntFromCompleted(DateTime completed) {
    if (completed != null) {
      return tec.dbIntFromDateTime(completed, ignoreTimeZone: true);
    }
    return null; // ignore: avoid_returning_null
  }

  /// Returns a copy of this object with optional tweaks.
  Devo copyWith({
    String title,
    String intro,
    String imageName,
    DateTime completed,
    int rating,
    bool clearCompleted = false,
  });

  // Returns true if the devo is marked completed.
  bool get isCompleted => (completedDbInt != null);

  // Returns true if the devo has been given a rating
  bool get isRated => (rating != null);

  // Returns true if the [other] devo matches this devo, except for the
  // `completed` value.
  bool matches(Object other) =>
      identical(this, other) ||
      (other is Devo &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          intro == other.intro &&
          imageName == other.imageName);

  /// Returns the image URL.
  String imageUrl(TecEnv env) =>
      'https://${env.streamServerAndVersion}/votd/$imageName';

  /// Returns the hero tag for the image.
  String get heroTagForImage => '$hashCode-$imageName';

  /// Asynchronously returns a list of devos from a JSON object.
  // static Future<List<Devo>> devosFromJson(
  //   List<dynamic> json,
  //   Dotd dotd, {
  //   bool downloadMissingDevos = true,
  // }) async {
  //   final devos = <Devo>[];
  //   final toLoadFromDb = <int>[];
  //   for (final devoJson in json) {
  //     if (devoJson is List<dynamic>) {
  //       final list = devoJson;
  //       if (list.length >= 2 && list[0] is String) {
  //         // Handle a reading plan devo...
  //         final devoRP = DevoRP.fromJson(list);
  //         devos.add(devoRP);
  //       } else if (list.length >= 3 && list.length <= 5 && list[0] is int) {
  //         // Handle a study resource devo...
  //         final devoRes = await DevoRes.fromJson(list, dotd);

  //         // If the title is null we need to load it from the database.
  //         if (devoRes.title == null) {
  //           toLoadFromDb.add(DevoApi.devoIdFrom(
  //               productId: devoRes.productId, resourceId: devoRes.resourceId));
  //         }
  //         devos.add(devoRes);
  //       }
  //     }
  //   }

  //   // Do we need to load some from the database?
  //   if (toLoadFromDb.isNotEmpty) {
  //     final dbDevos = await DevoApi.devosWithIds(
  //       toLoadFromDb,
  //       downloadMissingDevos: downloadMissingDevos,
  //     );
  //     for (var i = 0; i < devos.length; i++) {
  //       final devo = devos[i];
  //       if (devo is DevoRes) {
  //         final dbDevo = dbDevos.firstWhere(
  //             (d) => (d is DevoRes &&
  //                 d.productId == devo.productId &&
  //                 d.resourceId == devo.resourceId),
  //             orElse: () => null);
  //         if (dbDevo != null) {
  //           devos[i] = devo.copyWith(title: dbDevo.title, intro: dbDevo.intro);
  //         }
  //       }
  //     }
  //   }

  //   return devos;
  // }

  /// Returns the JSON string representation of this object.
  String toJsonStr();
}

/// Returns the image ID of the given image name.
int imageIdFromName(String imageName) {
  var imageId = 100;
  if (imageName?.endsWith('.jpg') ?? false) {
    final fname = imageName.substring(0, imageName.length - 4);
    if (fname.isNotEmpty) {
      try {
        imageId = int.parse(fname);
      } catch (_) {}
    }
  }
  return imageId;
}

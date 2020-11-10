import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tec_cache/tec_cache.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_util/tec_util.dart' as tec;

import 'devo_resource.dart';

/// Devotional-of-the-day data.
@immutable
class Dotd {
  Dotd({
    @required List<DevoRes> data,
  })  : assert(data != null),
        data = List<DevoRes>.unmodifiable(data);

  ///
  /// Ordered list of devotionals for the whole year.
  ///
  final List<DevoRes> data;

  /// Returns a Dotd object from parsing the given JSON.
  factory Dotd.fromJson(Map<String, dynamic> json) {
    final d = <DevoRes>[];
    final a = tec.as<List<dynamic>>(json['data']);
    for (final b in a) {
      if (b is List<dynamic>) {
        final devo = DevoRes.fromDotdJson(b);
        if (devo != null) {
          d.add(devo);
        }
      }
    }
    return Dotd(data: d);
  }

  /// Fetches the devotional-of-the-day data.
  static Future<Dotd> fetch(TecEnv env) async {
    final year = DateTime.now().year;
    final fileName = 'devo-tyndale-$year.json';
    final hostAndPath = '${env.streamServerAndVersion}/home';
    final json = await TecCache().jsonFromUrl(
        url: 'https://$hostAndPath/$fileName',
        cachedPath: '$hostAndPath/$fileName',
        bundlePath: 'assets/$fileName');
    if (json != null) {
      return Dotd.fromJson(json);
    } else {
      return Dotd(data: const []);
    }
  }

  /// Returns the devotional for the given date.
  DevoRes devoForDate(DateTime date) {
    if (date != null && tec.isNotNullOrEmpty(data)) {
      final i = tec.indexForDay(tec.dayOfTheYear(date), year: date.year, length: data.length);
      return data[i];
    }
    return null;
  }

  /// Returns the index into `data` for the given date.
  int indexForDate(DateTime date) {
    if (date != null) {
      return tec.indexForDay(tec.dayOfTheYear(date), year: date.year, length: data.length);
    }
    return -1;
  }

  /// Returns the devotional with the given product ID and resource ID,
  /// or null if none.
  DevoRes findDevoWith({@required int productId, @required int resourceId}) =>
      // ignore: avoid_bool_literals_in_conditional_expressions
      data?.firstWhere((devo) => (devo.productId == productId && devo.resourceId == resourceId),
          orElse: () => null);
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tec_cache/tec_cache.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_util/tec_util.dart' as tec;

import 'dotd.dart';

/// Devotional-of-the-day data.
@immutable
class Dotds {
  Dotds({
    @required List<Dotd> data,
  })  : assert(data != null),
        data = List<Dotd>.unmodifiable(data);

  ///
  /// Ordered list of devotionals for the whole year.
  ///
  final List<Dotd> data;

  /// Returns a Dotd object from parsing the given JSON.
  factory Dotds.fromJson(Map<String, dynamic> json) {
    final d = <Dotd>[];
    final a = tec.as<List<dynamic>>(json['data']);
    for (final b in a) {
      if (b is List<dynamic>) {
        final devo = Dotd.fromJson(b);
        if (devo != null) {
          d.add(devo);
        }
      }
    }
    return Dotds(data: d);
  }

  /// Fetches the devotional-of-the-day data.
  static Future<Dotds> fetch(TecEnv env) async {
    final year = DateTime.now().year;
    final fileName = 'devo-$year.json';
    final hostAndPath = '${env.streamServerAndVersion}/home';
    final json = await TecCache().jsonFromUrl(
        url: 'https://$hostAndPath/$fileName',
        cachedPath: '$hostAndPath/$fileName',
        bundlePath: 'assets/$fileName');
    if (json != null) {
      return Dotds.fromJson(json);
    } else {
      return Dotds(data: const []);
    }
  }

  /// Returns the devotional for the given date.
  Dotd devoForDate(DateTime date) {
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
  Dotd findDevoWith({@required int productId, @required int resourceId}) =>
      // ignore: avoid_bool_literals_in_conditional_expressions
      data?.firstWhere((devo) => (devo.productId == productId && devo.resourceId == resourceId),
          orElse: () => null);
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart' as tec;

class CompareResult {
  final int id;
  final String a;
  final String text;

  const CompareResult({this.id, this.a, this.text});

  factory CompareResult.fromJson(Map<String, dynamic> json) {
    final id = tec.as<int>(json['id']);
    final abbreviation = tec.as<String>(json['a']);
    final text = tec.as<String>(json['text']);

    return CompareResult(
      id: id,
      a: abbreviation,
      text: text,
    );
  }
}

class CompareResults {
  List<CompareResult> data = [];

  CompareResults({this.data});

  factory CompareResults.fromJson(List<dynamic> json) {
    final d = <CompareResult>[];
    for (final b in json) {
      if (b is Map<String, dynamic>) {
        final res = CompareResult.fromJson(b);
        if (res != null) {
          d.add(res);
        }
      }
    }
    return CompareResults(data: d);
  }

  static Future<CompareResults> fetch(
      {@required int book,
      @required int chapter,
      @required int verse,
      @required String translations}) async {
    final _cachedPath = '${book}_${chapter}_${verse}_$translations';

    final tecCache = TecCache();

    final json = await tecCache.jsonFromFile(cachedPath: _cachedPath);

    if (tec.isNotNullOrEmpty(json)) {
      return CompareResults.fromJson(tec.as<List<dynamic>>(json['list']));
    }

    return tec.apiRequest(
        endpoint: 'allverses',
        parameters: <String, dynamic>{
          'volumes': '$translations',
          'book': book,
          'chapter': chapter,
          'verse': verse,
        },
        completion: (status, json, dynamic error) async {
          if (status == 200) {
            await tecCache.saveJsonToCache(json: json, cacheUrl: _cachedPath);
            return CompareResults.fromJson(tec.as<List<dynamic>>(json['list']));
          } else {
            return CompareResults(data: []);
          }
        });
  }
}

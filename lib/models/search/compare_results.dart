import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tec_util/tec_util.dart';

class CompareResult {
  final int id;
  final String a;
  final String text;

  const CompareResult({this.id, this.a, this.text});

  factory CompareResult.fromJson(Map<String, dynamic> json) {
    final id = as<int>(json['id']);
    final abbreviation = as<String>(json['a']);
    final text = as<String>(json['text']);

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

    // check cloudfront cache
    var json = await httpRequestList(cfCompareCacheUrl(book, chapter, verse, translations));

    // check the server
    if (isNullOrEmpty(json)) {
      json = await httpRequestList('$apiUrl/allverses',
          body: apiBody(<String, dynamic>{
            'volumes': translations,
            'book': book,
            'chapter': chapter,
            'verse': verse,
          }));
    }

    if (isNotNullOrEmpty(json)) {
      return CompareResults.fromJson(json);
    }
    else {
      return CompareResults(data: []);
    }
  }
}

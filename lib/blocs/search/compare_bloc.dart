import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart' as tec;

enum CompareEvent { load }

class CompareBloc extends Bloc<CompareEvent, _CompareResults> {
  final int book;
  final int chapter;
  final int verse;
  CompareBloc({this.book, this.chapter, this.verse});

  @override
  _CompareResults get initialState => _CompareResults(data: []);

  @override
  Stream<_CompareResults> mapEventToState(
    CompareEvent event,
  ) async* {
    if (event == CompareEvent.load) {
      final res = await _CompareResults.fetch(book: book, chapter: chapter, verse: verse);
      yield res;
    }
    yield state;
  }
}

class _CompareResult {
  final int id;
  final String a;
  final String text;

  const _CompareResult({this.id, this.a, this.text});

  factory _CompareResult.fromJson(Map<String, dynamic> json) {
    final id = tec.as<int>(json['id']);
    final abbreviation = tec.as<String>(json['a']);
    final text = tec.as<String>(json['text']);

    return _CompareResult(
      id: id,
      a: abbreviation,
      text: text,
    );
  }
}

class _CompareResults {
  List<_CompareResult> data = [];

  _CompareResults({this.data});

  factory _CompareResults.fromJson(List<dynamic> json) {
    final d = <_CompareResult>[];
    for (final b in json) {
      if (b is Map<String, dynamic>) {
        final res = _CompareResult.fromJson(b);
        if (res != null) {
          d.add(res);
        }
      }
    }
    return _CompareResults(data: d);
  }

  static Future<_CompareResults> fetch({
    int book,
    int chapter,
    int verse,
    // BibleTranslations translations
  }) async {
    // translations.formatIds()
    const niv = 51;
    final _cachedPath = '${book}_${chapter}_${verse}_$niv';

    final tecCache = TecCache();

    final json = await tecCache.jsonFromFile(cachedPath: _cachedPath);

    if (tec.isNotNullOrEmpty(json)) {
      return _CompareResults.fromJson(tec.as<List<dynamic>>(json['list']));
    }

    return tec.apiRequest(
        endpoint: 'allverses',
        parameters: <String, dynamic>{
          'volumes': '$niv',
          'book': book,
          'chapter': chapter,
          'verse': verse,
        },
        completion: (status, json, dynamic error) async {
          if (status == 200) {
            await tecCache.saveJsonToCache(json: json, cacheUrl: _cachedPath);
            return _CompareResults.fromJson(tec.as<List<dynamic>>(json['list']));
          } else {
            return _CompareResults(data: []);
          }
        });
  }
}

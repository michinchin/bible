import 'dart:core';

import 'package:flutter/material.dart';
import 'package:tec_cache/tec_cache.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../labels.dart';
import 'verse.dart';

class SearchResult {
  final String ref;
  final int bookId;
  final int chapterId;
  final int verseId;
  final List<Verse> verses;
  final GlobalKey key;

  SearchResult({
    this.ref,
    this.bookId,
    this.chapterId,
    this.verseId,
    this.verses,
    this.key,
  });

  SearchResult copyWith({
    String ref,
    int bookId,
    int chapterId,
    int verseId,
    List<Verse> verses,
    bool contextExpanded,
    bool compareExpanded,
    bool isExpanded,
    bool isSelected,
    int currentVerseIndex,
    String fullText,
    GlobalKey key,
  }) =>
      SearchResult(
        ref: ref ?? this.ref,
        bookId: bookId ?? this.bookId,
        chapterId: chapterId ?? this.chapterId,
        verseId: verseId ?? this.verseId,
        verses: verses ?? this.verses,
        key: key ?? this.key,
      );

  String get href => '$bookId/$chapterId/$verseId';

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final ref = tec.as<String>(json['reference']);
    final v = <Verse>[];
    final a = tec.as<List<dynamic>>(json['verses']);
    for (final b in a) {
      if (b is Map<String, dynamic>) {
        final verse = Verse.fromJson(b, ref);
        if (verse != null) {
          v.add(verse);
        }
      }
    }
    return SearchResult(
        ref: ref,
        bookId: tec.as<int>(json['bookId']),
        chapterId: tec.as<int>(json['chapterId']),
        verses: v,
        verseId: tec.as<int>(json['verseId']),
        key: GlobalKey());
  }
}

class SearchResults {
  List<SearchResult> data = [];
  SearchResults({this.data});

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    final d = <SearchResult>[];
    final a = tec.as<List<dynamic>>(json['searchResults']);
    for (final b in a) {
      if (b is Map<String, dynamic>) {
        final res = SearchResult.fromJson(b);
        if (res != null) {
          d.add(res);
        }
      }
    }
    return SearchResults(data: d);
  }

  static Future<List<SearchResult>> fetch({String words, String translationIds}) async {
    if ((words?.trim() ?? '').isEmpty) {
      return [];
    }
    var phrase = 0, exact = 0;
    var cacheWords = words;
    String searchWords;

    urlEncodingExceptions.forEach((k, v) => cacheWords = cacheWords.replaceAll(RegExp(k), v));
    tec.removeDiacritics(cacheWords).replaceAll(RegExp('[^ a-zA-Z\'0-9:\-]'), ' ').trim();

    // phrase or exact search ?
    if (cacheWords[0] == '"' || cacheWords[0] == '\'') {
      if (cacheWords.contains(' ')) {
        phrase = 1;
      } else {
        exact = 1;
      }

      // remove trailing quote
      if (cacheWords.endsWith(cacheWords[0])) {
        cacheWords = cacheWords.substring(1, cacheWords.length - 1);
      } else {
        cacheWords = cacheWords.substring(1);
      }

      searchWords = cacheWords = cacheWords.toLowerCase();
    } else {
      final currQuery = cacheWords.toLowerCase();
      final regex = RegExp(r' *[0-9]? *\w+ *[0-9]+');
      final matches = regex.allMatches(currQuery).toList();

      cacheWords = _formatWords(cacheWords);

      searchWords = (matches.isNotEmpty) ? _formatRefs(currQuery) : cacheWords;
    }

    final tecCache = TecCache();
    final cacheParam = _getCacheKey(cacheWords, translationIds, exact, phrase);

    // check cloudfront cache
    var json = await tecCache.jsonFromUrl(
      url: '${tec.cacheUrl}/$cacheParam.gz',
      connectionTimeout: const Duration(seconds: 10),
    );

    // try server
    if (tec.isNullOrEmpty(json)) {
      json = await tec.apiRequest(
          endpoint: 'search',
          parameters: <String, dynamic>{
            'searchWords': searchWords,
            'book': 0,
            'bookset': 0,
            'exact': exact,
            'phrase': phrase,
            'searchVolumes': translationIds,
          },
          completion: (status, json, dynamic error) async {
            if (status == 200) {
              await tecCache.saveJsonToCache(
                  json: json, cacheUrl: '${tec.cacheUrl}/$cacheParam.gz');

              return json;
            } else {
              return null;
            }
          });
    }

    if (tec.isNullOrEmpty(json)) {
      return Future.error('Error getting results from server');
    } else {
      return SearchResults.fromJson(json).data;
    }
  }
}

final urlEncodingExceptions = <String, String>{
  '’': '\'', // UTF-8: E2 80 99
  '‘': '\'', // UTF-8: E2 80 98
  '‚': '',
  ',': '', // get rid of commas
  '‛': '\'',
  '“': '"',
  '”': '"',
  '„': '"', // UTF-8: E2 80 9E
  '‟': '"',
  '′': '"',
  '″': '"',
  '‴': '"',
  '‵': '\'',
  '‶': '"',
  '‷': '"',
  '–': '-', // UTF-8: E2 80 93
  '‐': '-',
  '‒': '-',
  '—': '-', // UTF-8: E2 80 94
  '―': '-', // UTF-8: E2 80 95
  '\\.': '',
};

String _formatWords(String keywords) {
  final modifiedKeywords = keywords.toLowerCase();

  // sort by length descending then alpha ascending...
  final wordList = modifiedKeywords.split(' ')
    ..sort((a, b) {
      if (a.length == b.length) {
        return a.compareTo(b);
      } else {
        return b.length.compareTo(a.length);
      }
    });

  // return the top 5 results
  return wordList.sublist(0, wordList.length <= 5 ? wordList.length : 5).join(' ');
}

String _formatRefs(String query) {
  final regex = RegExp(r' *[0-9]? *\w+');

  final arr = regex.allMatches(query).toList();
  if (arr.isNotEmpty) {
    final shortRef = arr[0].group(0);
    if (Labels.extraBookNames.containsKey(shortRef)) {
      final bookId = Labels.extraBookNames[shortRef];
      // TODO(abby): instead of 51 as default bible, use diff value?
      final fullBookName = VolumesRepository.shared.bibleWithId(51).nameOfBook(bookId);
      final fixedQuery = query.replaceAll(shortRef, fullBookName);

      return fixedQuery;
    }
  }
  return query;
}

String _getCacheKey(String keywords, String translationIds, int exact, int phrase) {
  String modKeywords;
  modKeywords = keywords.toLowerCase();
  urlEncodingExceptions.forEach((k, v) => modKeywords = modKeywords.replaceAll(RegExp(k), v));

  var words = keywords.replaceAll(' ', '_');

  words += '_';
  final encoded = StringBuffer();
  const length = Labels.base64Map.length;
  final volumeIds = translationIds.split('|').toList().map(double.parse).toList()..sort();

  for (var i = 0; i < volumeIds.length; i++) {
    var volumeId = volumeIds[i];
    final digit = volumeId / length;
    encoded.write(Labels.base64Map[digit.toInt()]);
    volumeId -= digit.toInt() * length;
    encoded.write(Labels.base64Map[volumeId.toInt()]);
  }
  return '$words${encoded.toString()}_0_0_${phrase}_$exact';
}

List<TextSpan> searchResTextSpans(
  String verseText,
  String words,
) {
  final verse = tec.removeDiacritics(verseText);

  final content = <TextSpan>[];
  // var modPar = verse;
  var modKeywords = words.trim();
  var phrase = false, exact = false;

  urlEncodingExceptions.forEach((k, v) => modKeywords = modKeywords.replaceAll(RegExp(k), v));

  // phrase or exact search ?
  if (modKeywords[0] == '"' || modKeywords[0] == '\'') {
    if (modKeywords.contains(' ')) {
      phrase = true;
    } else {
      exact = true;
    }

    // remove trailing quote
    if (modKeywords.endsWith(modKeywords[0])) {
      modKeywords = modKeywords.substring(1, modKeywords.length - 1);
    } else {
      modKeywords = modKeywords.substring(1);
    }
  } else {
    modKeywords = modKeywords;
  }

  // l = lowercase
  // List<String> formattedKeywords, lFormattedKeywords;
  List<String> lFormattedKeywords;

  if (exact || phrase) {
    // formattedKeywords = [modKeywords.trim()];
    lFormattedKeywords = [modKeywords.trim().toLowerCase()];
  } else {
//      formattedKeywords = modKeywords.split(' ')
//        ..sort((s, t) => s.length.compareTo(t.length));
    lFormattedKeywords = modKeywords.toLowerCase().split(' ');
  }

  final bold = <int, int>{};
  final lverse = verse.toLowerCase();
  final a = 'a'.codeUnitAt(0);
  final z = 'z'.codeUnitAt(0);
  lFormattedKeywords.removeWhere((s) => s.isEmpty);

  // find matching words (case insensitive search)
  for (final keyword in lFormattedKeywords) {
    var where = -1;

    while ((where = lverse.indexOf(keyword, where + 1)) >= 0) {
      if (where == 0 || (lverse.codeUnitAt(where - 1) < a) || lverse.codeUnitAt(where - 1) > z) {
        final length = keyword.length;

        if (length <= 2 && lverse.length > (where + length)) {
          // match only whole words
          if (lverse.codeUnitAt(where + length) >= a && lverse.codeUnitAt(where + length) <= z) {
            continue;
          }
        }

        bold[where] = length;
      }
    }
  }

  if (bold.isEmpty) {
    // no bold - should never happen
    content.add(TextSpan(text: verse));
  } else {
    final boldKeys = bold.keys.toList()..sort((a, b) => a.compareTo(b));

    var lastEnd = 0;

    for (final where in boldKeys) {
      if (where >= lastEnd) {
        if (where > 0) {
          // add any preceding text not bolded...
          content.add(TextSpan(text: verse.substring(lastEnd, where)));
        }

        // add the bold text...
        content.add(TextSpan(
            text: verse.substring(where, where + bold[where]),
            style: const TextStyle(fontWeight: FontWeight.bold)));

        lastEnd = where + bold[where];
      }
    }

    if (lastEnd < verse.length) {
      content.add(TextSpan(text: verse.substring(lastEnd)));
    }
  }
  return content;
}

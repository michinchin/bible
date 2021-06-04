import 'dart:core';

import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';

import '../const.dart';
import 'verse.dart';

class SearchResult extends Equatable {
  final String ref;
  final int bookId;
  final int chapterId;
  final int verseId;
  final List<Verse> verses;

  const SearchResult({
    @required this.ref,
    @required this.bookId,
    @required this.chapterId,
    @required this.verseId,
    @required this.verses,
  });

  @override
  List<Object> get props => [ref, bookId, chapterId, verseId, verses];

  SearchResult copyWith({
    String ref,
    int bookId,
    int chapterId,
    int verseId,
    List<Verse> verses,
  }) =>
      SearchResult(
        ref: ref ?? this.ref,
        bookId: bookId ?? this.bookId,
        chapterId: chapterId ?? this.chapterId,
        verseId: verseId ?? this.verseId,
        verses: verses ?? this.verses,
      );

  String get href => '$bookId/$chapterId/$verseId';

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final ref = as<String>(json['reference']);
    final v = <Verse>[];
    final a = as<List<dynamic>>(json['verses']);
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
      bookId: as<int>(json['bookId']),
      chapterId: as<int>(json['chapterId']),
      verses: v,
      verseId: as<int>(json['verseId']),
    );
  }
}

class SearchResults {
  List<SearchResult> data = [];

  SearchResults({this.data});

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    final d = <SearchResult>[];
    final a = as<List<dynamic>>(json['searchResults']);
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
    removeDiacritics(cacheWords).replaceAll(RegExp('[^ a-zA-Z\'0-9:-]'), ' ').trim();

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

    // check cloudfront cache
    var json = await httpRequestMap(cfSearchCacheUrl(cacheWords, translationIds, exact, phrase));

    // try server
    if (isNullOrEmpty(json)) {
      json = await httpRequestMap('$apiUrl/search',
          body: apiBody(<String, dynamic>{
            'searchWords': searchWords,
            'book': 0,
            'bookset': 0,
            'exact': exact,
            'phrase': phrase,
            'searchVolumes': translationIds,
          }));
    }

    if (isNullOrEmpty(json)) {
      return Future.error('Error getting results from server');
    } else {
      return SearchResults.fromJson(json).data;
    }
  }
}

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
    if (Const.extraBookNames.containsKey(shortRef)) {
      final bookId = Const.extraBookNames[shortRef];
      final fullBookName =
          VolumesRepository.shared.bibleWithId(Const.defaultBible).nameOfBook(bookId);
      final fixedQuery = query.replaceAll(shortRef, fullBookName);

      return fixedQuery;
    }
  }
  return query;
}

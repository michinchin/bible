import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tec_env/tec_env.dart';
import 'package:tec_util/tec_util.dart' as tec;

@immutable
class Chapter {
  /// Returns a new chapter with default settings.
  const Chapter({
    this.volumeId = 0,
    this.book = 0,
    this.chapter = 0,
    this.html,
    this.verses,
    this.xrefs,
    this.footnotes,
  });

  /// Returns a new chapter that is a copy of this chapter with optional tweaks.
  Chapter copyWith({
    int volumeId,
    int book,
    int chapter,
    String html,
    Map<String, dynamic> verses,
    Map<String, dynamic> xrefs,
    Map<String, dynamic> footnotes,
  }) =>
      Chapter(
        volumeId: volumeId ?? this.volumeId,
        book: book ?? this.book,
        html: html ?? this.html,
        verses: verses ?? this.verses,
        xrefs: xrefs ?? this.xrefs,
        footnotes: footnotes ?? this.footnotes,
      );

  final int volumeId;
  final int book;
  final int chapter;
  final String html;
  final Map<String, dynamic> verses;
  final Map<String, dynamic> xrefs;
  final Map<String, dynamic> footnotes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chapter &&
          runtimeType == other.runtimeType &&
          volumeId == other.volumeId &&
          book == other.book &&
          chapter == other.chapter &&
          html == other.html &&
          verses == other.verses &&
          xrefs == other.xrefs &&
          footnotes == other.footnotes;

  @override
  int get hashCode =>
      volumeId.hashCode ^
      book.hashCode ^
      chapter.hashCode ^
      html.hashCode ^
      verses.hashCode ^
      xrefs.hashCode ^
      footnotes.hashCode;

  /// Returns a new chapter parsed from the given JSON.
  factory Chapter.fromJson(
    Map<String, dynamic> json,
    int volumeId,
    int book,
    int chapter,
  ) {
    if (json != null) {
      return Chapter(
        volumeId: volumeId,
        book: book,
        chapter: chapter,
        html: tec.as<String>(json['chapter']),
        verses: tec.as<Map<String, dynamic>>(json['verses']),
        xrefs: tec.as<Map<String, dynamic>>(json['xrefs']),
        footnotes: tec.as<Map<String, dynamic>>(json['footnotes']),
      );
    }
    return null;
  }

  /// Returns a Future<Chapter> fetched from the Tecarta API.
  static Future<Chapter> fetch({
    @required TecEnv env,
    @required int volumeId,
    @required int book,
    @required int chapter,
  }) async {
    //
    debugPrint('fetching chapter');
    final fileName = '${book}_$chapter.json';
    final hostAndPath = '${env.streamServerAndVersion}/$volumeId/chapters';
    final urlPath = 'https://$hostAndPath/$fileName.gz';

    final json = await tec.sendHttpRequest<Map<String, dynamic>>(
        tec.HttpRequestType.get,
        url: urlPath, completion: (status, json, dynamic error) {
      return Future.value(json);
    });

    // final json = await TecCache().jsonFromUrl(
    //     url: urlPath,
    //     cachedPath: '$hostAndPath/$fileName',
    //     refresh: const Duration(days: 7 * 4)); // Refresh every four weeks.

    if (json != null) {
      return Chapter.fromJson(json, volumeId, book, chapter);
    } else {
      tec.dmPrint('Chapter failed to get json from $urlPath');
      return null;
    }
  }
}

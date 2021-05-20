import 'dart:async';

import 'package:tec_util/tec_util.dart';

class AutoComplete {
  final String word;
  final List<String> possibles;

  AutoComplete({this.word, this.possibles});

  factory AutoComplete.fromJson(Map<String, dynamic> json) {
    final possibles = as<List<dynamic>>(json['possibles'])
        .map((dynamic s) => as<String>(s)) //ignore: unnecessary_lambdas
        .toList();
    return AutoComplete(word: as<String>(json['partial']), possibles: possibles);
  }

  static Future<AutoComplete> fetch({String phrase, String translationIds}) async {
    final cleanPhrase = optimizePhrase(phrase);
    final suggestions = getSuggestions(cleanPhrase);

    if (cleanPhrase.trim().isEmpty) {
      return AutoComplete.fromJson(
          <String, dynamic>{'words': '', 'partial': '', 'possibles': <String>[]});
    }

    // check cloudfront cache
    var json = await httpRequestMap(cfSuggestCacheUrl(cleanPhrase, translationIds));

    // check the server
    if (isNullOrEmpty(json)) {
      json = await httpRequestMap('$apiUrl/suggest',
          body: apiBody(<String, dynamic>{
            'words': suggestions['words'],
            'partialWord': suggestions['partialWord'],
            'searchVolumes': translationIds,
          }));
    }

    if (isNullOrEmpty(json)) {
      return Future.error('Error getting results from server');
    } else {
      return AutoComplete.fromJson(json);
    }
  }
}

String optimizePhrase(String phrase) {
  // normalize phrase
  var cleanPhrase = removeDiacritics(phrase.trimLeft());

  // remove punctuation
  cleanPhrase = cleanPhrase.replaceAll(RegExp('[^ a-zA-Z\'0-9:-]'), ' ');

  // top 5 words...
  final words = cleanPhrase.split(' ');
  cleanPhrase = '';

  var partial = '';
  if (!phrase.endsWith(' ')) {
    partial = ' ${words.last}';
    words.removeLast();
  }

  for (final word in words) {
    if (word.trim().isNotEmpty) {
      cleanPhrase += ' ${word.trim()}';
    }
  }

  // sort by length descending then alpha ascending...
  final wordList = cleanPhrase.trim().split(' ')
    ..sort((a, b) {
      if (a.length == b.length) {
        return a.compareTo(b);
      } else {
        return b.length.compareTo(a.length);
      }
    });

  cleanPhrase = wordList.sublist(0, wordList.length <= 5 ? wordList.length : 5).join(' ');

  // so we get full/partial word correct...
  if (partial.isNotEmpty) {
    cleanPhrase += ' $partial';
  } else {
    cleanPhrase += ' ';
  }

  return cleanPhrase;
}

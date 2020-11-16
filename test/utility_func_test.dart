import 'package:flutter_test/flutter_test.dart';

import 'package:bible/models/misc_utils.dart';
import 'package:bible/models/string_utils.dart';

void main() {
  test('String.countOfWords in bible_chapter_view.dart', () {
    expect(''.countOfWords(), 0);
    expect('dog cat rabbit'.countOfWords(), 3);
    expect('  dog  cat  rabbit  '.countOfWords(), 3);
    expect('  dog  cat  rabbit  '.countOfWords(toIndex: 2), 0);
    expect('  dog  cat  rabbit  '.countOfWords(toIndex: 3), 0);
    expect('  dog  cat  rabbit  '.countOfWords(toIndex: 4), 0);
    expect('  dog  cat  rabbit  '.countOfWords(toIndex: 5), 1);
    expect('  dog  cat  rabbit  '.countOfWords(toIndex: 6), 1);
    expect('  dog  cat  rabbit  '.countOfWords(toIndex: 7), 1);
    expect('  dog  cat  rabbit  '.countOfWords(toIndex: 8), 1);
    expect('  dog  cat  rabbit  '.countOfWords(toIndex: 9), 1);
    expect('  dog  cat  rabbit  '.countOfWords(toIndex: 10), 2);
    expect('  dog  cat  rabbit  '.countOfWords(toIndex: 11), 2);
    expect('  dog  cat  rabbit'.countOfWords(toIndex: 17), 2);
    expect('  dog  cat  rabbit'.countOfWords(toIndex: 18), 3);
    expect('  dog  cat  rabbit'.countOfWords(), 3);
    expect('"dog'.countOfWords(toIndex: 1), 0);
  });

  test('String.indexAtEndOfWord in bible_chapter_view.dart', () {
    expect('dog cat rabbit'.indexAtEndOfWord(0), 0);
    expect('dog cat rabbit'.indexAtEndOfWord(100), 14);
    expect('dog cat rabbit'.indexAtEndOfWord(1), 3);
    expect('dog cat rabbit'.indexAtEndOfWord(2), 7);
    expect('  dog  cat  rabbit  '.indexAtEndOfWord(2), 10);
  });

  test('Iterable<int>.missingValues', () {
    expect(<int>[].missingValues(), <int>[]);
    expect([5].missingValues(), <int>[]);
    expect([5, 6].missingValues(), <int>[]);
    expect([5, 7].missingValues(), [6]);
    expect([5, 10].missingValues(), [6, 7, 8, 9]);
    expect([5, 6, 9, 10].missingValues(), [7, 8]);
    expect([5, 7, 8, 10].missingValues(), [6, 9]);
  });

  test('test rangeOfDelimitedSubstring where includeDelimiters == false', () {
    /*************************/
    _includeDelimiters = false;
    /*************************/

    expect('{{}}'.rangeOfDS(), const Range(2, 2));
    expect('a b c {{ d {{ e }} f {{ g }}'.rangeOfDS(), null);
    expect('a b c {{ d {{ e }} f {{ g }} h }} i j'.rangeOfDS(), const Range(8, 31));
    expect('a b c {{ d {{ e {{ f }} g }} h }} i j'.rangeOfDS(), const Range(8, 31));
    expect('abc <<>> def'.rangeOfDS(delimiters: ['<', '>']), const Range(5, 7));
    expect('abc <<>><> def'.rangeOfDS(start: 6, delimiters: ['<', '>']), const Range(9, 9));
  });

  test('test rangeOfDelimitedSubstring where includeDelimiters == true', () {
    /*************************/
    _includeDelimiters = true;
    /*************************/

    expect('{{}}'.rangeOfDS(), const Range(0, 4));
    expect('a b c {{ d {{ e }} f {{ g }}'.rangeOfDS(), null);
    expect('a b c {{ d {{ e }} f {{ g }} h }} i j'.rangeOfDS(), const Range(6, 33));
    expect('a b c {{ d {{ e {{ f }} g }} h }} i j'.rangeOfDS(), const Range(6, 33));
    expect('abc <<>> def'.rangeOfDS(delimiters: ['<', '>']), const Range(4, 8));
    expect('abc <<>><> def'.rangeOfDS(start: 6, delimiters: ['<', '>']), const Range(8, 10));
  });

  test('test isInDelimitedSubstring', () {
    expect('<>'.isInDelimitedSubstring(0, delimiters: ['<', '>']), false);
    expect('<>'.isInDelimitedSubstring(1, delimiters: ['<', '>']), true);
    expect('<>'.isInDelimitedSubstring(2, delimiters: ['<', '>']), false);
  });
}

const _delimiters = <Pattern>['{{', '}}'];
var _includeDelimiters = false;

extension TestStringExt on String {
  Range rangeOfDS({
    int start = 0,
    bool includeDelimiters,
    List<Pattern> delimiters = _delimiters,
  }) {
    return rangeOfDelimitedSubstring(
      start: start,
      includeDelimiters: includeDelimiters ?? _includeDelimiters,
      delimiters: delimiters,
    );
  }
}

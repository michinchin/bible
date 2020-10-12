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
}

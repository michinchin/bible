import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';
import 'package:tec_util/tec_util.dart';

extension TecExtOnString on String {
  ///
  /// Returns the count of words in the string. If [toIndex] if provided, returns the count of
  /// words up to, but not including, that index.
  ///
  /// Note, if [toIndex] is provided, and [toIndex] is in the middle of a word, that word is
  /// not counted. For example, if the string is 'cat dog', and [toIndex] is 0, 1, or 2, the
  /// function returns 0. If [toIndex] is 3, 4, 5, or 6, the function returns 1. If [toIndex]
  /// is 7 or null, the function returns 2.
  ///
  /// See: http://www.unicode.org/reports/tr29/#Word_Boundaries
  ///
  int countOfWords({int toIndex}) {
    var count = 0;
    var isInWord = false;
    var i = 0;
    final units = codeUnits;
    for (final codeUnit in units) {
      final isNonWordChar = _isNonWordChar(codeUnit);
      if (isInWord) {
        if (isNonWordChar) {
          isInWord = false;
          count++;
        }
      } else if (!isNonWordChar) {
        isInWord = true;
      }
      if (toIndex != null && i >= toIndex) break;
      i++;
    }
    if (isInWord && i >= units.length) count++;
    return count;
  }

  ///
  /// Returns the index where the given word starts (or ends, if [start]
  /// is `false`). Note, the first word is word 1, and so on.
  ///
  int indexAtWord(int word, {bool start = true}) {
    if (word == null || word <= 0) return 0;
    var wordCount = 0;
    var isInWord = false;
    var i = 0;
    final units = codeUnits;
    for (final codeUnit in units) {
      final isNonWordChar = _isNonWordChar(codeUnit);
      if (isInWord) {
        if (isNonWordChar) {
          isInWord = false;
          if (word == wordCount && !start) return i;
        }
      } else if (!isNonWordChar) {
        wordCount++;
        if (word == wordCount && start) return i;
        isInWord = true;
      }
      i++;
    }
    return i;
  }

  ///
  /// Returns the index immediately after the given word. Note, the first
  /// word is word 1, and so on.
  ///
  int indexAtEndOfWord(int word) {
    return indexAtWord(word, start: false);
  }

  ///
  /// Returns the index in the string after the last character of the match,
  /// or -1 if no match was found.
  ///
  /// If [start] is used, it must be non-negative and not greater than
  /// [length].
  ///
  int indexAfter(Pattern pattern, [int start]) {
    var i = -1;
    if (pattern is String) {
      i = indexOf(pattern, start ?? 0);
      if (i >= 0) {
        i += pattern.length;
      }
    } else if (pattern is RegExp) {
      var string = this;
      if (start != null && start != 0) {
        string = string.substring(start);
      }
      final match = pattern.firstMatch(string);
      if (match != null) {
        i = match.end + (start ?? 0);
      }
    }
    return i;
  }

  ///
  /// Returns the range of the first delimited substring, starting at [start],
  /// or null if none is found.
  ///
  Range rangeOfDelimitedSubstring({
    int start = 0,
    bool includeDelimiters = true,
    List<Pattern> delimiters = const ['{{', '}}'],
  }) {
    assert(delimiters != null && delimiters.length >= 2);
    final i = start ?? 0;
    if (i >= 0 && i < length) {
      var startIndex = includeDelimiters ? indexOf(delimiters[0], i) : indexAfter(delimiters[0], i);
      if (startIndex >= 0) {
        final substringStart = startIndex;
        var endIndex = includeDelimiters
            ? indexAfter(delimiters[1], indexAfter(delimiters[0], i))
            : indexOf(delimiters[1], substringStart);
        while (endIndex > 0) {
          startIndex = includeDelimiters
              ? indexOf(delimiters[0], startIndex + 1)
              : indexAfter(delimiters[0], startIndex);
          if (startIndex >= 0 &&
              ((includeDelimiters && startIndex < endIndex) ||
                  (!includeDelimiters && startIndex <= endIndex))) {
            endIndex = includeDelimiters
                ? indexAfter(delimiters[1], endIndex)
                : indexOf(delimiters[1], endIndex + 1);
          } else {
            return Range(substringStart, endIndex);
          }
        }
      }
    }
    return null;
  }

  ///
  /// Returns true iff the given index is in a delimited substring.
  ///
  bool isInDelimitedSubstring(
    int i, {
    List<Pattern> delimiters = const ['{{', '}}'],
  }) {
    if (i < 0 || i > length) {
      assert(false);
    } else {
      var previousRangeEnd = 0;
      Range range;
      while ((range = rangeOfDelimitedSubstring(
            start: previousRangeEnd,
            includeDelimiters: false,
            delimiters: delimiters,
          )) !=
          null) {
        if (i >= range.start && i <= range.end) return true;
        previousRangeEnd = range.end + 1;
      }
    }
    return false;
  }

  ///
  /// Returns a new string with useless HTML spans removed.
  ///
  String despanified() => replaceAllMapped(_despanifyRegEx, (m) => m[1]);

  static final _despanifyRegEx = RegExp(r'<span>([^<]*)</span>');

  ///
  /// Returns a new string with each character converted to its matching Unicode superscript
  /// character, if there is one.
  ///
  /// Note, only ascii numbers ('0' - '9'), lowercase ascii letters (except for 'q'), some
  /// ascii punctuation ('+', '-', '=', '(', ')') and some greek symbols ('𝛼', '𝛽', '𝛾',
  /// '𝛿', '𝜀', '𝜃', '𝜄', '𝜙', '𝜒') have a matching Unicode superscript character.
  ///
  /// If [firstNormalize] is `true` (defaults to false), the string is first "normalized",
  /// that is, all diacritics (accents and cedilla) are removed and the string is converted
  /// to lowercase before it is superscripted.
  ///
  /// If [removeNonsuperscriptableChars] is `false`, the default, characters that do not have
  /// a matching Unicode superscript character are left unchanged, otherwise they are removed.
  ///
  String superscripted({bool firstNormalize = false, bool removeNonsuperscriptableChars = false}) {
    var str = this;

    if (firstNormalize) {
      str = removeDiacritics(str);
      str = str.toLowerCase();
    }

    return String.fromCharCodes(_superscript(
      str.codeUnits,
      removeNonsuperscriptableChars: removeNonsuperscriptableChars,
    ));
  }

  ///
  /// Returns a new string with each Unicode superscript character converted to its matching
  /// regular character (e.g. '²' => '2'). Characters that are not superscripted are left
  /// unchanged.
  ///
  String unsuperscripted() => String.fromCharCodes(_unsuperscript(codeUnits));

  ///
  /// Returns true iff the string starts with a digit.
  ///
  bool get startsWithDigit => isNotEmpty && codeUnits.first.isInRange(0x0030, 0x003A);
}

@immutable
class Range extends Equatable {
  const Range(this.start, this.end);
  final int start;
  final int end;

  @override
  List<Object> get props => [start, end];

  @override
  String toString() => '[$start, $end]';
}

//
// PRIVATE STUFF
//

extension<T> on Set<T> {
  Set<T> subtracting(Iterable<T> items) {
    if (items == null || items.isEmpty) return this;
    return Set.of(this)..removeAll(items);
  }
}

// ignore_for_file: unused_element

bool _isNonWordChar(int codeUnit) => _nonWordChars.contains(codeUnit);
final _nonWordChars =
    _whitespace.union(_asciiPunctuation).subtracting([_sglQuote]).union(_nonWordQuotes);

bool _isApostrophe(int codeUnit) => _apostrophes.contains(codeUnit);
const _apostrophes = <int>{_sglQuote, _sglQtRgt};

const _sglQuote = 0x0027; // ' single quote, apostrophe
const _sglQtLft = 0x2018; // ‘ left single quote
const _sglQtRgt = 0x2019; // ’ right single quote, apostrophe

const _dblQuote = 0x0022; // " double quote
const _dblQtLft = 0x201C; // “ left double quote
const _dblQtRgt = 0x201D; // ” right double quote

const _nonWordQuotes = <int>{_sglQtLft, _dblQuote, _dblQtLft, _dblQtRgt};

// const _allQuotes = <int>{_sglQuote, _sglQtLft, _sglQtRgt, _dblQuote, _dblQtLft, _dblQtRgt};

const _nonBreakingHyphen = 0x2011; // ‑ non-breaking hyphen

const _asciiPunctuation = <int>{
  // From: ASCII Punctuation, 0021-007E: https://www.unicode.org/charts/PDF/U0000.pdf

  0x0021, // ! exclamation mark
  0x0022, // " double quotation mark
  0x0023, // # number sign, pound sign, hash mark, crosshatch, or octothorpe
  0x0024, // $ dollar sign
  0x0025, // % percent sign
  0x0026, // & ampersand
  0x0027, // ' apostrophe or single quote
  0x0028, // ( left parenthesis
  0x0029, // ) right parenthesis
  0x002A, // * asterisk
  0x002B, // + plus sign
  0x002C, // , comma
  0x002D, // - hyphen or minus sign
  0x002E, // . period, full stop, dot, or decimal point
  0x002F, // / slash, solidus, or virgule

  /* Ignore numbers.
  0x0030, // 0
  ...
  0x0039, // 9
  */

  0x003A, // : colon
  0x003B, // ; semicolon
  0x003C, // < less-than sign, left bracket
  0x003D, // = equals sign
  0x003E, // > greater-than sign, right bracket
  0x003F, // ? question mark

  0x0040, // @ at sign, commercial at

  /* Ignore uppercase letters (capital letters).
  0x0041, // A
  ...
  0x005A, // Z
  */

  0x005B, // [ left square bracket
  0x005C, // \ backslash or reverse solidus
  0x005D, // ] right square bracket
  0x005E, // ^ circumflex accent, or up arrowhead
  0x005F, // _ underscore, low line
  0x0060, // ` grave accent

  /* Ignore lowercase letters.
  0x0061, // a
  ...
  0x007A, // z
  */

  0x007B, // { left curly bracket
  0x007C, // | vertical line or bar
  0x007D, // } right curly bracket
  0x007E, // ~ tilde
};

//
// Whitespace related data and functions.
//

bool _isWhitespace(int rune) => _whitespace.contains(rune);

// Copied from tec_util string.dart.
const _whitespace = <int>{
  0x0009, // [␉] horizontal tab
  0x000A, // [␊] line feed
  0x000B, // [␋] vertical tab
  0x000C, // [␌] form feed
  0x000D, // [␍] carriage return

  // Not sure we need to include these chars, so commented out for now.
  // 0x001C, // [␜] file separator
  // 0x001D, // [␝] group separator
  // 0x001E, // [␞] record separator
  // 0x001F, // [␟] unit separator

  0x0020, // [ ] space
  0x0085, // next line
  0x00A0, // [ ] no-break space
  0x1680, // [ ] ogham space mark
  0x2000, // [ ] en quad
  0x2001, // [ ] em quad
  0x2002, // [ ] en space
  0x2003, // [ ] em space
  0x2004, // [ ] three-per-em space
  0x2005, // [ ] four-per-em space
  0x2006, // [ ] six-per-em space
  0x2007, // [ ] figure space
  0x2008, // [ ] punctuation space
  0x2009, // [ ] thin space
  0x200A, // [ ] hair space
  0x202F, // [ ] narrow no-break space
  0x205F, // [ ] medium mathematical space
  0x3000, // [　] ideographic space
};

//
// Superscript related data and functions.
//

Map<int, int> _supCodeUnits;

List<int> _superscript(List<int> codeUnits, {bool removeNonsuperscriptableChars = false}) {
  // Init `_supCodeUnits` from `_sup` if necessary.
  _supCodeUnits ??= {for (final e in _sup.entries) e.key.codeUnitAt(0): e.value.codeUnitAt(0)};

  final result = <int>[];
  for (final original in codeUnits) {
    final sup = _supCodeUnits[original];
    if (sup != null) {
      result.add(sup);
      continue;
    }

    if (!removeNonsuperscriptableChars) {
      result.add(original);
      continue;
    }

    if (_whitespace.contains(original)) {
      result.add(original);
      continue;
    }
  }

  return result;
}

Map<int, int> _unsupCodeUnits;

List<int> _unsuperscript(List<int> codeUnits) {
  // Init `_unsupCodeUnits` from `_sup` if necessary.
  _unsupCodeUnits ??= {for (final e in _sup.entries) e.value.codeUnitAt(0): e.key.codeUnitAt(0)};

  final result = <int>[];
  for (final original in codeUnits) {
    final sup = _unsupCodeUnits[original];
    if (sup != null) {
      result.add(sup);
      continue;
    }

    result.add(original);
  }

  return result;
}

const _sup = <String, String>{
  // numbers, e.g. ¹²⋅³⁴
  '0': '⁰', // '\u2070'
  '1': '¹', // '\u00B9'
  '2': '²', // '\u00B2'
  '3': '³', // '\u00B3'
  '4': '⁴', // '\u2074'
  '5': '⁵', // '\u2075'
  '6': '⁶', // '\u2076'
  '7': '⁷', // '\u2077'
  '8': '⁸', // '\u2078'
  '9': '⁹', // '\u2079'

  // lowercase letters
  'a': 'ᵃ', // '\u1d43'
  'b': 'ᵇ', // '\u1d47'
  'c': 'ᶜ', // '\u1d9c'
  'd': 'ᵈ', // '\u1d48'
  'e': 'ᵉ', // '\u1d49'
  'f': 'ᶠ', // '\u1da0'
  'g': 'ᵍ', // '\u1d4d'
  'h': 'ʰ', // '\u02b0'
  'i': 'ⁱ', // '\u2071'
  'j': 'ʲ', // '\u02b2'
  'k': 'ᵏ', // '\u1d4f'
  'l': 'ˡ', // '\u02e1'
  'm': 'ᵐ', // '\u1d50'
  'n': 'ⁿ', // '\u207f'
  'o': 'ᵒ', // '\u1d52'
  'p': 'ᵖ', // '\u1d56'
  'q': 'ᵠ', // no q, so using 'ᵠ' for now.
  'r': 'ʳ', // '\u02b3'
  's': 'ˢ', // '\u02e2'
  't': 'ᵗ', // '\u1d57'
  'u': 'ᵘ', // '\u1d58'
  'v': 'ᵛ', // '\u1d5b'
  'w': 'ʷ', // '\u02b7'
  'x': 'ˣ', // '\u02e3'
  'y': 'ʸ', // '\u02b8'
  'z': 'ᶻ', // '\u1dbb'

  // lowercase math/greek symbols
  '𝛼': 'ᵅ', // '\u1d45' :alpha
  '𝛽': 'ᵝ', // '\u1d5d' :beta
  '𝛾': 'ᵞ', // '\u1d5e' :gamma
  '𝛿': 'ᵟ', // '\u1d5f' :delta
  '𝜀': 'ᵋ', // '\u1d4b' :epsilon
  '𝜃': 'ᶿ', // '\u1dbf' :theta
  '𝜄': 'ᶥ', // '\u1da5' :iota
  '𝜒': 'ᵡ', // '\u1d61' :chi
  '𝜙': 'ᶲ', // '\u1db2' :phi uppercase phi

  // This is commented out because we're using 'ᵠ' for 'p'.
  // '𝜑': 'ᵠ', // '\u1d60' :psi lowercase phi

  // punctuation
  '+': '⁺', // '\u207A'
  '-': '⁻', // '\u207B'
  '=': '⁼', // '\u207C'
  '(': '⁽', // '\u207D'
  ')': '⁾', // '\u207E'

  // not official
  '.': '⋅', // bullet operator: '∙', dot operator: '⋅', z notation spot '⦁'
};

const _sub = <String, String>{
  '0': '₀',
  '1': '₁',
  '2': '₂',
  '3': '₃',
  '4': '₄',
  '5': '₅',
  '6': '₆',
  '7': '₇',
  '8': '₈',
  '9': '₉',
  '+': '₊',
  '-': '₋',
  '=': '₌',
  '(': '₍',
  ')': '₎',
};

// ignore_for_file: unused_element

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
  /// Returns the index at the end of the given word.
  ///
  int indexAtEndOfWord(int word) {
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
          if (word == wordCount) return i;
        }
      } else if (!isNonWordChar) {
        wordCount++;
        isInWord = true;
      }
      i++;
    }
    return i;
  }
}

extension<T> on Set<T> {
  Set<T> subtracting(Iterable<T> items) {
    if (items == null || items.isEmpty) return this;
    return Set.of(this)..removeAll(items);
  }
}

bool _isNonWordChar(int codeUnit) => _nonWordChars.contains(codeUnit);

final _nonWordChars =
    _whitespace.union(_asciiPunctuation).subtracting([_apostrophe]).union(_nonWordQuotes);

const _apostrophe = _sglQuote;

const _sglQuote = 0x0027; // ' single quote, apostrophe
const _sglQtLft = 0x2018; // ‘ left single quote
const _sglQtRgt = 0x2019; // ’ right single quote, apostrophe

const _dblQuote = 0x0022; // " double quote
const _dblQtLft = 0x201C; // “ left double quote
const _dblQtRgt = 0x201D; // ” right double quote

const _nonWordQuotes = <int>{_sglQtLft, _dblQuote, _dblQtLft, _dblQtRgt};

// const _allQuotes = <int>{_sglQuote, _sglQtLft, _sglQtRgt, _dblQuote, _dblQtLft, _dblQtRgt};

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
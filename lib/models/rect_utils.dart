import 'dart:math' as math;
import 'dart:ui';

///
/// Rect extensions
///
extension TecExtOnRect on Rect {
  ///
  /// If right < left or bottom < top, returns a new normalized rectangle,
  /// otherwise just returns this.
  ///
  Rect normalized() {
    if (right < left) {
      if (bottom < top) {
        return Rect.fromLTRB(right, bottom, left, top);
      }
      return Rect.fromLTRB(right, top, left, bottom);
    } else if (bottom < top) {
      return Rect.fromLTRB(left, bottom, right, top);
    }
    return this;
  }

  /// The vertical center.
  double get vCenter => (top + bottom) / 2.0;

  /// The horizontal center.
  double get hCenter => (left + right) / 2.0;
}

///
/// List<Rect> extensions
///
extension TecExtOnListOfRect on List<Rect> {
  ///
  /// Returns the index of the first rect in the list that contains
  /// the given [point].
  ///
  /// Searches the list from index [start] to the end of the list.
  ///
  /// Returns -1 if not found.
  ///
  int indexContainingPoint(Offset point, [int start]) {
    if (point == null) return -1;
    return indexWhere((rect) => rect.contains(point), start ?? 0);
  }

  ///
  /// Returns true if at least one of the rects in the list contain
  /// the given [point].
  ///
  bool containsPoint(Offset point) => (indexContainingPoint(point) >= 0);

  ///
  /// Returns a new rect which is the bounding box containing all the
  /// rects in the list.
  ///
  Rect merged() => fold<Rect>(
        null,
        (previous, rect) => Rect.fromLTRB(
          math.min(previous?.left ?? rect.left, rect.left),
          math.min(previous?.top ?? rect.top, rect.top),
          math.max(previous?.right ?? rect.right, rect.right),
          math.max(previous?.bottom ?? rect.bottom, rect.bottom),
        ),
      );
}

///
/// Iterable<Rect> extensions
///
extension TecExtOnIterableOfRect on Iterable<Rect> {
  ///
  /// Returns a new rect which is the bounding box containing all the
  /// rects in the list.
  ///
  Rect merged() => fold<Rect>(
        null,
        (previous, rect) => Rect.fromLTRB(
          math.min(previous?.left ?? rect.left, rect.left),
          math.min(previous?.top ?? rect.top, rect.top),
          math.max(previous?.right ?? rect.right, rect.right),
          math.max(previous?.bottom ?? rect.bottom, rect.bottom),
        ),
      );
}

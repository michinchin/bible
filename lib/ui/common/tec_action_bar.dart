import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';

@immutable
class ActionBarItem {
  final String title;
  final Widget icon;
  final VoidCallback onTap;
  final String minTitle;
  final int priority;
  final bool showTrailingSeparator;

  const ActionBarItem({
    this.title,
    this.icon,
    this.onTap,
    String minTitle,
    this.priority = 0,
    this.showTrailingSeparator = true,
  })  : minTitle = minTitle ?? title,
        assert(title != null || icon != null);
}

///
/// ActionBar
///
class ActionBar extends StatelessWidget {
  final int viewUid;
  final List<ActionBarItem> items;
  final double elevation;
  final Duration animationDuration;

  const ActionBar({
    Key key,
    @required @required this.items,
    @required this.viewUid,
    this.elevation,
    this.animationDuration, // = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget actionBar() => Container(
          key: ValueKey(items),
          alignment: Alignment.center,
          // color: Colors.red.withOpacity(0.25),
          child: LayoutBuilder(builder: _layoutBuilder),
        );

    return animationDuration == null
        ? actionBar()
        : AnimatedSwitcher(
            duration: animationDuration,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: actionBar(),
          );
  }

  Widget _layoutBuilder(BuildContext context, BoxConstraints constraints) {
    final theme = Theme.of(context);
    final appBarTheme = AppBarTheme.of(context);
    final textStyle = appBarTheme.textTheme?.headline6 ?? theme.primaryTextTheme.headline6;

    // Cache for calculated item widths, so the calculation only happens once.
    final cache = _Cache<int, double>();

    //final scale = MediaQuery.maybeOf(context)?.textScaleFactor ?? 1.0;
    final scale = MediaQuery.of(context)?.textScaleFactor ?? 1.0;
    final sidePadding = 8.0 * scale;
    var min = false;

    final actualItems = items;
    if (actualItems.idealWidth(cache, textStyle, scale) + (sidePadding * 2.0) >
        constraints.maxWidth) {
      min = true;
      while (actualItems.minWidth(cache, textStyle, scale) + (sidePadding * 2.0) >
              constraints.maxWidth &&
          actualItems.length > 1) {
        final minPriority =
            actualItems.fold<int>(tec.maxSafeInt, (v, item) => math.min(v, item.priority));
        final i = actualItems.indexWhere((item) => item.priority == minPriority);
        assert(i >= 0);
        actualItems.removeAndUpdateCacheForItemAtIndex(i >= 0 ? i : 0, cache);
      }
    }

    var i = 0;

    final child = Material(
        elevation: elevation ?? Theme.of(context).appBarTheme.elevation ?? 4.0,
        borderRadius: const BorderRadius.all(Radius.circular(90)),
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).appBarTheme.color
            : Theme.of(context).backgroundColor,
        child: Container(
          constraints: BoxConstraints.tightFor(height: constraints.maxHeight),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: sidePadding),
              ...actualItems.expand((item) =>
                  item.toWidgets(context, textStyle, scale, i++, actualItems.length, min: min)),
              SizedBox(width: sidePadding),
            ],
          ),
        ));
    return Draggable<int>(
        data: viewUid,
        onDragStarted: () => context.tbloc<SheetManagerBloc>().add(SheetEvent.collapse),
        onDragCompleted: () => context.tbloc<SheetManagerBloc>().add(SheetEvent.main),
        feedback: Opacity(opacity: 0.8, child: child),
        child: child);
  }
}

//
// PRIVATE STUFF
//

const _defaultIconSize = 24.0;

extension on ActionBarItem {
  List<Widget> toWidgets(
    BuildContext context,
    TextStyle textStyle,
    double scale,
    int index,
    int count, {
    @required bool min,
  }) {
    final theme = Theme.of(context);
    final appBarTheme = AppBarTheme.of(context);
    var iconTheme = appBarTheme.iconTheme ?? theme.primaryIconTheme;
    iconTheme = iconTheme.merge(IconThemeData(size: _defaultIconSize * scale));

    Widget separator() => Padding(
          padding: EdgeInsets.symmetric(horizontal: _sepPadding * scale),
          child: Container(
            color: textStyle.color.withOpacity(0.2),
            width: _sepWidth,
            height: 34.0 * scale,
          ),
        );

    return [
      CupertinoButton(
        minSize: 0,
        // color: Colors.red.withOpacity(0.25),
        padding: EdgeInsets.symmetric(vertical: (4.0 * scale).roundToDouble()),
        child: Row(children: [
          if (title != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _textPadding * scale),
              child: Text(min ? minTitle : title, style: textStyle, maxLines: 1),
            ),
          if (icon != null) IconTheme.merge(data: iconTheme, child: icon),
        ]),
        onPressed: onTap,
      ),
      if (showTrailingSeparator && index < count - 1) separator(),
    ];
  }

  static const _textPadding = 4.0;
  static const _sepWidth = 2.25;
  static const _sepPadding = 4.0;

  double width(
    TextStyle textStyle,
    double scale,
    int index,
    int count, {
    @required bool min,
  }) {
    var width = 0.0;

    if (title != null) {
      width += TextSpan(text: min ? minTitle : title, style: textStyle)
              .createTextPainter(textScaleFactor: scale)
              .width +
          (_textPadding * scale * 2);
    }

    if (icon != null) {
      width += _defaultIconSize * scale;
    }

    if (showTrailingSeparator && index < count - 1) {
      width += _sepPadding * scale * 2.0;
    }

    return width;
  }
}

extension on List<ActionBarItem> {
  double idealWidth(_Cache<int, double> cache, TextStyle textStyle, double scale) =>
      _width(cache, textStyle, scale, min: false);

  double minWidth(_Cache<int, double> cache, TextStyle textStyle, double scale) =>
      _width(cache, textStyle, scale, min: true);

  double _width(
    _Cache<int, double> cache,
    TextStyle textStyle,
    double scale, {
    @required bool min,
  }) {
    var i = 0;
    return fold<double>(0.0, (total, item) {
      final result = total +
          cache.widthOfItemAtIndex(i, () => item.width(textStyle, scale, i, length, min: min),
              getMinValue: min && item.title != item.minTitle);
      i++;
      return result;
    });
  }

  void removeAndUpdateCacheForItemAtIndex(int i, _Cache<int, double> cache) {
    removeAt(i);

    // The cache needs to be updated because the indexes (keys) of cached items changed.
    cache.removedIndex(i, length);
  }
}

extension _ActionBarOnCache on _Cache<int, double> {
  ///
  /// Gets/sets the cached width for the item at index [i]. If [getMinValue] is true,
  /// gets/sets the cached minimum width.
  ///
  double widthOfItemAtIndex(int i, double Function() getWidth, {@required bool getMinValue}) {
    // Cache min values with a negative key.
    if (getMinValue) return valueForKey(_minKey(i), (_) => getWidth());
    return valueForKey(i, (_) => getWidth());
  }

  /// The key for min values is (-1 - i).
  static int _minKey(int i) => -1 - i;

  /// Updates the cache based on the removed [index] by shifting cached
  /// values from indices after index down by one.
  void removedIndex(int index, int count) {
    var i = index;
    while (i <= count) {
      _replaceValueAt(i, withValueFrom: i + 1);
      _replaceValueAt(_minKey(i), withValueFrom: _minKey(i + 1));
      i++;
    }
  }

  /// Replaces the value at [i] with the value from [withValueFrom].
  /// If there is no value at [withValueFrom], removes the value at [i].
  void _replaceValueAt(int i, {@required int withValueFrom}) {
    if (containsKey(withValueFrom)) {
      update(i, valueForKey(withValueFrom, (_) => null));
    } else {
      remove(i);
    }
  }
}

class _Cache<K, V> {
  V valueForKey(K key, V Function(K key) getValue) {
    assert(key != null && getValue != null);
    var value = _cache[key];
    if (value == null) {
      value = getValue(key);
      if (value != null) _cache[key] = value;
    }
    return value;
  }

  bool containsKey(K key) => _cache.containsKey(key);

  void update(K key, V value) => _cache[key] = value;

  void remove(K key) => _cache.remove(key);

  final _cache = <K, V>{};
}

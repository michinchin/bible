import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// import 'package:tec_util/tec_util.dart' as tec;

export 'package:flutter/rendering.dart' show ScrollDirection;

class TecScrollListener extends StatefulWidget {
  final void Function(ScrollDirection direction) changedDirection;
  final Widget child;
  final AxisDirection axisDirection;

  const TecScrollListener({
    Key key,
    @required this.changedDirection,
    @required this.child,
    this.axisDirection,
  }) : super(key: key);

  @override
  _TecScrollListenerState createState() => _TecScrollListenerState();
}

class _TecScrollListenerState extends State<TecScrollListener> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (notification) => _scrollHandler(context, notification),
        child: widget.child);
  }

  Object _scrollContext;
  double _lastScrollPos;
  ScrollDirection _previousDirection;

  bool _scrollHandler(BuildContext context, ScrollNotification notification) {
    if (notification is ScrollNotification &&
        (widget.axisDirection == null ||
            widget.axisDirection == notification.metrics.axisDirection)) {
      final pos = notification.metrics.pixels;
      final minPos = (notification.metrics.minScrollExtent ?? 0.0) + 10.0;
      final maxPos = (notification.metrics.maxScrollExtent ?? double.infinity) - 10.0;
      if (maxPos <= minPos) {
        if (_previousDirection != ScrollDirection.reverse) {
          // tec.dmPrint('Sending `reverse`, pos: $pos, minPos: $minPos, maxPos: $maxPos');
          _previousDirection = ScrollDirection.reverse;
          widget.changedDirection(_previousDirection);
        }
      } else if (pos < maxPos) {
        if (_scrollContext != notification.context) {
          _scrollContext = notification.context;
          _lastScrollPos = null;
        }
        _lastScrollPos ??= pos;

        const delta = 10.0;
        if (pos < _lastScrollPos - delta || pos <= minPos) {
          _lastScrollPos = pos;
          if (_previousDirection != ScrollDirection.reverse) {
            // tec.dmPrint('Sending `reverse`, pos: $pos, minPos: $minPos, maxPos: $maxPos');
            _previousDirection = ScrollDirection.reverse;
            widget.changedDirection(_previousDirection);
          }
        } else if (pos > _lastScrollPos + delta) {
          _lastScrollPos = pos;
          if (_previousDirection != ScrollDirection.forward) {
            // tec.dmPrint('Sending `forward`, pos: $pos, minPos: $minPos, maxPos: $maxPos');
            _previousDirection = ScrollDirection.forward;
            widget.changedDirection(_previousDirection);
          }
        }
      } else {
        _scrollContext = null;
        // tec.dmPrint('Ignoring scroll, pos: $pos, minPos: $minPos, maxPos: $maxPos');
      }
    }

    return false;
  }
}

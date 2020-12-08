import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

export 'package:flutter/rendering.dart' show ScrollDirection;

class TecScrollListener extends StatefulWidget {
  final void Function(ScrollDirection direction) changedDirection;
  final Widget child;

  const TecScrollListener({Key key, @required this.changedDirection, @required this.child})
      : super(key: key);

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
    if (notification is ScrollNotification) {
      final scrollPos = notification.metrics.pixels;
      if (_scrollContext != notification.context) {
        _scrollContext = notification.context;
        _lastScrollPos = null;
      }
      _lastScrollPos ??= scrollPos;
      const delta = 10.0;
      if (scrollPos < _lastScrollPos - delta || scrollPos <= 0.0) {
        _lastScrollPos = scrollPos;
        if (_previousDirection != ScrollDirection.reverse) {
          // tec.dmPrint('Calling SheetManagerBloc.add(SheetEvent.restore)');
          _previousDirection = ScrollDirection.reverse;
          widget.changedDirection(_previousDirection);
        }
      } else if (scrollPos > 0.0 && scrollPos > _lastScrollPos + delta) {
        _lastScrollPos = scrollPos;
        if (_previousDirection != ScrollDirection.forward) {
          // tec.dmPrint('Calling SheetManagerBloc.add(SheetEvent.collapse)');
          _previousDirection = ScrollDirection.forward;
          widget.changedDirection(_previousDirection);
        }
      }
    }

    return false;
  }
}

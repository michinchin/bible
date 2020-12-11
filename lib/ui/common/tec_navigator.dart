import 'package:flutter/material.dart';

///
/// A widget that builds a `Navigator` widget with the given [onGenerateRoute] function,
/// and creates a `HeroController` so that hero animations work in the `Navigator`.
///
/// See: https://stackoverflow.com/a/60729122
///
class NavigatorWithHeroController extends StatefulWidget {
  const NavigatorWithHeroController({Key key, this.onGenerateRoute}) : super(key: key);

  /// Called to generate a route for a given [RouteSettings].
  final RouteFactory onGenerateRoute;

  @override
  _NavigatorWithHeroControllerState createState() => _NavigatorWithHeroControllerState();

  bool canPop(Object state) {
    if (state is _NavigatorWithHeroControllerState) {
      return state.navigator.canPop();
    }

    return false;
  }

  void pop(Object state) {
    if (state is _NavigatorWithHeroControllerState) {
      state.navigator.pop();
    }
  }
}

class _NavigatorWithHeroControllerState extends State<NavigatorWithHeroController> {
  HeroController _heroController;
  GlobalKey _navigatorKey;

  NavigatorState get navigator {
    return _navigatorKey.currentState as NavigatorState;
  }

  @override
  void initState() {
    super.initState();
    _heroController = HeroController(
        createRectTween: (begin, end) => MaterialRectArcTween(begin: begin, end: end));
    _navigatorKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: _navigatorKey, observers: [_heroController], onGenerateRoute: widget.onGenerateRoute);
  }
}

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
}

class _NavigatorWithHeroControllerState extends State<NavigatorWithHeroController> {
  HeroController _heroController;

  @override
  void initState() {
    super.initState();
    _heroController = HeroController(
        createRectTween: (begin, end) => MaterialRectArcTween(begin: begin, end: end));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(observers: [_heroController], onGenerateRoute: widget.onGenerateRoute);
  }
}

import 'package:flutter/material.dart';

///
/// A view with its own [Navigator] state and history. Useful in cases where
/// parallel navigation states and history are desired.
///
/// [TecNavView] configures the top-level [Navigator] to search for routes
/// in the following order:
///
///  1. For the `/` route, the [builder] property, if non-null, is used.
///
///  2. Otherwise, the [routes] table is used, if it has an entry for the route,
///     including `/` if [builder] is not specified.
///
///  3. Otherwise, [onGenerateRoute] is called, if provided. It should return a
///     non-null value for any _valid_ route not handled by [builder] and [routes].
///
///  4. Finally if all else fails [onUnknownRoute] is called.
///
/// These navigation properties are not shared with any sibling [TecNavView]
/// nor any ancestor or descendant [Navigator] instances.
///
/// To push a route above this [TecNavView] instead of inside it (such
/// as when showing a dialog on top of all tabs), use
/// `Navigator.of(rootNavigator: true)`.
///
/// See also:
///
///  * [MaterialPageRoute], a typical modal page route pushed onto the
///    [TecNavView]'s [Navigator].
///
class TecNavView extends StatefulWidget {
  ///
  /// Returns a new [TecNavView], a view with its own [Navigator] state and
  /// history.
  ///
  const TecNavView({
    Key key,
    this.builder,
    this.navigatorKey,
    this.routes,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
  })  : assert(navigatorObservers != null),
        super(key: key);

  /// The widget builder for the default route ([Navigator.defaultRouteName],
  /// which is `/`).
  ///
  /// If a [builder] is specified, then [routes] must not include an entry for `/`,
  /// as [builder] takes its place.
  ///
  /// Rebuilding a [TecNavView] with a different [builder] will not clear
  /// its current navigation stack or update its descendant. Instead, trigger a
  /// rebuild from a descendant in its subtree. This can be done via methods such
  /// as:
  ///
  ///  * Calling [State.setState] on a descendant [StatefulWidget]'s [State]
  ///  * Modifying an [InheritedWidget] that a descendant registered itself
  ///    as a dependent to.
  ///
  final WidgetBuilder builder;

  /// A key to use when building this widget's [Navigator].
  ///
  /// If a [navigatorKey] is specified, the [Navigator] can be directly
  /// manipulated without first obtaining it from a [BuildContext] via
  /// [Navigator.of]: from the [navigatorKey], use the [GlobalKey.currentState]
  /// getter.
  ///
  /// If this is changed, a new [Navigator] will be created, losing all the
  /// state in the process; in that case, the [navigatorObservers] must also be
  /// changed, since the previous observers will be attached to the previous
  /// navigator.
  ///
  final GlobalKey<NavigatorState> navigatorKey;

  /// This view's routing table.
  ///
  /// When a named route is pushed with [Navigator.pushNamed] inside this view,
  /// the route name is looked up in this map. If the name is present,
  /// the associated [WidgetBuilder] is used to construct a [MaterialPageRoute]
  /// that performs an appropriate transition to the new route.
  ///
  /// If the view only has one page, then you can specify it using [builder] instead.
  ///
  /// If [builder] is specified, then it implies an entry in this table for the
  /// [Navigator.defaultRouteName] route (`/`), and it is an error to
  /// redundantly provide such a route in the [routes] table.
  ///
  /// If a route is requested that is not specified in this table (or by
  /// [builder]), then the [onGenerateRoute] callback is called to build the page
  /// instead.
  ///
  /// This routing table is not shared with any routing tables of ancestor or
  /// descendant [Navigator]s.
  ///
  final Map<String, WidgetBuilder> routes;

  /// The route generator callback used when the view is navigated to a named route.
  ///
  /// This is used if [routes] does not contain the requested route.
  ///
  final RouteFactory onGenerateRoute;

  /// Called when [onGenerateRoute] also fails to generate a route.
  ///
  /// This callback is typically used for error handling. For example, this
  /// callback might always generate a "not found" page that describes the route
  /// that wasn't found.
  ///
  /// The default implementation pushes a route that displays an ugly error
  /// message.
  ///
  final RouteFactory onUnknownRoute;

  /// The list of observers for the [Navigator] created in this view.
  ///
  /// This list of observers is not shared with ancestor or descendant [Navigator]s.
  ///
  final List<NavigatorObserver> navigatorObservers;

  @override
  _TecNavViewState createState() {
    return _TecNavViewState();
  }
}

class _TecNavViewState extends State<TecNavView> {
  HeroController _heroController;
  List<NavigatorObserver> _navigatorObservers;

  @override
  void initState() {
    super.initState();
    _heroController = HeroController();
    _updateObservers();
  }

  @override
  void didUpdateWidget(TecNavView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigatorKey != oldWidget.navigatorKey ||
        widget.navigatorObservers != oldWidget.navigatorObservers) {
      _updateObservers();
    }
  }

  void _updateObservers() {
    _navigatorObservers = List<NavigatorObserver>.from(widget.navigatorObservers)
      ..add(_heroController);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute: _onUnknownRoute,
      observers: _navigatorObservers,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    WidgetBuilder routeBuilder;
    if (name == Navigator.defaultRouteName && widget.builder != null) {
      routeBuilder = widget.builder;
    } else if (widget.routes != null) {
      routeBuilder = widget.routes[name];
    }
    if (routeBuilder != null) {
      // return PageRouteBuilder<dynamic>(
      //   pageBuilder: (context, _, __) => routeBuilder(context),
      //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //     // final theme = Theme.of(context).pageTransitionsTheme;
      //     // return theme.buildTransitions<dynamic>(
      //     //     this, context, animation, secondaryAnimation, child);
      //     return FadeTransition(
      //       opacity: animation,
      //       child: RotationTransition(
      //         turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
      //         child: child,
      //       ),
      //     );
      //   },
      // );

      return MaterialPageRoute<dynamic>(builder: routeBuilder, settings: settings);
    }
    if (widget.onGenerateRoute != null) return widget.onGenerateRoute(settings);
    return null;
  }

  Route<dynamic> _onUnknownRoute(RouteSettings settings) {
    assert(() {
      if (widget.onUnknownRoute == null) {
        throw FlutterError('Could not find a generator for route $settings in the $runtimeType.\n'
            'Generators for routes are searched for in the following order:\n'
            ' 1. For the "/" route, the "builder" property, if non-null, is used.\n'
            ' 2. Otherwise, the "routes" table is used, if it has an entry for '
            'the route.\n'
            ' 3. Otherwise, onGenerateRoute is called. It should return a '
            'non-null value for any valid route not handled by "builder" and "routes".\n'
            ' 4. Finally if all else fails onUnknownRoute is called.\n'
            'Unfortunately, onUnknownRoute was not set.');
      }
      return true;
    }());
    final result = widget.onUnknownRoute(settings);
    assert(() {
      if (result == null) {
        throw FlutterError('The onUnknownRoute callback returned null.\n'
            'When the $runtimeType requested the route $settings from its '
            'onUnknownRoute callback, the callback returned null. Such callbacks '
            'must never return null.');
      }
      return true;
    }());
    return result;
  }
}

///
/// Builds and shows a view. If [maxWidth] && [maxHeight] are null, or are
/// greater than or equal to the device window size,
///
///   `Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: builder))`
///
/// is called, otherwise [showDialog] is called, constraining the built view
/// as specified.
///
Future<T> showView<T extends Object>({
  BuildContext context,
  bool useRootNavigator = true,
  bool barrierDismissible = true,
  WidgetBuilder builder,
  double maxWidth,
  double maxHeight,
}) {
  if (maxWidth != null || maxHeight != null) {
    assert(debugCheckHasMediaQuery(context));
    final windowSize = MediaQuery.of(context, nullOk: true)?.size ?? Size.zero;
    if ((maxWidth != null && maxWidth < windowSize.width) ||
        (maxHeight != null && maxHeight < windowSize.height)) {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        useRootNavigator: useRootNavigator,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth ?? double.infinity,
                maxHeight: maxHeight ?? double.infinity,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(20),
              child: Builder(builder: builder),
            ),
          );
        },
      );
    }
  }

  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push<T>(MaterialPageRoute<T>(builder: builder));
}

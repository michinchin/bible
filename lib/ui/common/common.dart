import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tec_tab_indicator.dart';

export 'tec_future_builder.dart';
export 'tec_modal_popup.dart';
export 'tec_page_route.dart';
export 'tec_popup_menu.dart';
export 'tec_search_field.dart';
export 'tec_stream_builder.dart';
export 'tec_tab_indicator.dart';

///
/// Loading indicator with consistent look for the app.
///
class LoadingIndicator extends StatelessWidget {
  final double radius;

  const LoadingIndicator({Key key, this.radius = 10}) : super(key: key);

  @override
  Widget build(BuildContext context) => CupertinoTheme(
      data: CupertinoTheme.of(context).copyWith(brightness: Theme.of(context).brightness),
      child: CupertinoActivityIndicator(
        radius: radius,
      ));
}

///
/// Returns an [AppBarTheme] appropriate for the lightness or darkness of the given [context].
///
AppBarTheme appBarThemeWithContext(BuildContext context) {
  final theme = Theme.of(context);
  final barColor = theme.canvasColor;
  // final barColor = theme.appBarTheme.color ?? theme.primaryColor;
  final brightness = ThemeData.estimateBrightnessForColor(barColor);
  final barTextColor = brightness == Brightness.light ? Colors.grey[700] : Colors.white;
  return theme.appBarTheme.copyWith(
    brightness: brightness,
    color: barColor,
    elevation: 0,
    // shadowColor: Colors.transparent,
    iconTheme: IconThemeData(color: barTextColor),
    actionsIconTheme: IconThemeData(color: barTextColor),
    textTheme: theme.copyOfAppBarTextThemeWithColor(barTextColor),
    centerTitle: true,
  );
}

///
/// Returns a [TabBarTheme] appropriate for the lightness or darkness of the given [context].
///
TabBarTheme tabBarThemeWithContext(BuildContext context) {
  final theme = Theme.of(context);
  final barColor = theme.canvasColor;
  final barTextColor = ThemeData.estimateBrightnessForColor(barColor) == Brightness.light
      ? Colors.grey[700]
      : Colors.white;
  return theme.tabBarTheme.copyWith(
    indicator: const TecTabIndicator(
        indicatorHeight: 4, indicatorColor: null, indicatorSize: TecTabIndicatorSize.full),
    indicatorSize: TabBarIndicatorSize.label,
    labelColor: barTextColor,
    // labelStyle: const TextStyle(fontWeight: FontWeight.w700),
    // unselectedLabelColor: Theme.of(context).textColor,
    // unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
  );
}

///
/// ThemeData extensions.
///
extension ExtOnThemeData on ThemeData {
  ///
  /// Returns a copy of this ThemeData with the appBarTheme.textTheme updated the given [color].
  ///
  TextTheme copyOfAppBarTextThemeWithColor(Color color) =>
      appBarTheme.textTheme?.apply(bodyColor: color) ??
      primaryTextTheme?.apply(bodyColor: color) ??
      TextTheme(headline6: TextStyle(color: color));
}

///
/// Removes the eight pixel padding from the top and bottom of the default AppBar.
///
class MinHeightAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;

  const MinHeightAppBar({Key key, this.appBar}) : super(key: key);

  @override
  Widget build(BuildContext context) => appBar ?? AppBar();

  @override
  Size get preferredSize => Size.fromHeight((appBar ?? AppBar()).preferredSize.height - 16.0);
}

class PrefSizeWidgetUnderlined extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget child;
  final double lineHeight;
  final Color color;

  const PrefSizeWidgetUnderlined({
    Key key,
    @required this.child,
    this.color,
    this.lineHeight = 1.5,
  })  : assert(child != null),
        assert(lineHeight != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final line = Container(
      //width: double.infinity,
      height: lineHeight,
      color: color ?? Theme.of(context).primaryColor,
    );

    // return Stack(children: [child, Positioned(left: 0, right: 0, bottom: 0, child: line)]);
    return Column(children: [child, line]);
  }

  @override
  Size get preferredSize => Size.fromHeight(child.preferredSize.height + lineHeight);
}

class IconWithNumberBadge extends StatelessWidget {
  final IconData icon;
  final int value;
  const IconWithNumberBadge({this.icon, this.value});

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Icon(icon),
      if (value != 0)
        Positioned(
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: const BoxConstraints(
              minWidth: 12,
              minHeight: 12,
            ),
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
    ]);
  }
}

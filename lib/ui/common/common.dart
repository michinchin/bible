import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_widgets/tec_widgets.dart';

import 'tec_tab_indicator.dart';

export 'tec_future_builder.dart';
export 'tec_modal_popup.dart';
export 'tec_page_route.dart';
export 'tec_popup_menu.dart';
export 'tec_search_field.dart';
export 'tec_stream_builder.dart';
export 'tec_tab_indicator.dart';

///
/// Shape and border radius to use for bottom sheets.
///
const bottomSheetShape = RoundedRectangleBorder(borderRadius: bottomSheetBorderRadius);
const bottomSheetBorderRadius = BorderRadius.only(topLeft: _sheetRadius, topRight: _sheetRadius);
const _sheetRadius = Radius.circular(15);

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
/// Returns a horizontal more icon for iOS and macOS, a vertical more icon otherwise.
///
IconData platformAwareMoreIcon(BuildContext context) {
  switch (Theme.of(context).platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return Icons.more_horiz;
    default:
      return Icons.more_vert;
  }
}

///
/// List label with padding
///
class ListLabel extends StatelessWidget {
  final String label;
  const ListLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: TecText(
          label,
          autoSize: true,
          style: Theme.of(context).textTheme.caption,
        ));
  }
}

///
/// ThemeData extensions
///
extension AppExtOnThemeData on ThemeData {
  ///
  /// Returns a copy of this theme with app customizations.
  ///
  ThemeData copyWithAppTheme() {
    return copyWith(
      // primaryColor: brightness == Brightness.light ? primaryColor : primaryColor,
      accentColor: brightness == Brightness.light ? accentColor : Colors.blue,
      bottomSheetTheme: bottomSheetTheme.copyWith(elevation: 4, shape: bottomSheetShape),
      appBarTheme: tecAppBarTheme(),
      tabBarTheme: tecTabBarTheme(),
    );
  }

  ///
  /// Returns our special [AppBarTheme].
  ///
  AppBarTheme tecAppBarTheme() {
    final barColor = canvasColor;
    // final barColor = theme.appBarTheme.color ?? theme.primaryColor;
    final brightness = ThemeData.estimateBrightnessForColor(barColor);
    final barTextColor = brightness == Brightness.light ? Colors.grey[700] : Colors.white;
    return appBarTheme.copyWith(
      brightness: brightness,
      color: barColor,
      elevation: 0,
      // shadowColor: Colors.transparent,
      iconTheme: IconThemeData(color: barTextColor),
      actionsIconTheme: IconThemeData(color: barTextColor),
      textTheme: copyOfAppBarTextThemeWithColor(barTextColor),
      centerTitle: true,
    );
  }

  ///
  /// Returns our special [TabBarTheme].
  ///
  TabBarTheme tecTabBarTheme() {
    final barColor = canvasColor;
    final barTextColor = ThemeData.estimateBrightnessForColor(barColor) == Brightness.light
        ? Colors.grey[700]
        : Colors.white;
    return tabBarTheme.copyWith(
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
  /// Returns a copy of this ThemeData with the appBarTheme.textTheme updated the given [color].
  ///
  TextTheme copyOfAppBarTextThemeWithColor(Color color) =>
      appBarTheme.textTheme?.apply(bodyColor: color) ??
      // primaryTextTheme?.apply(bodyColor: color) ??
      TextTheme(headline6: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w500));
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

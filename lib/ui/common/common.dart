import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fixed_width_widget_span/fixed_width_widget_span.dart';
import 'package:tec_widgets/tec_widgets.dart';

import 'tec_tab_indicator.dart';

export 'tec_dialog.dart';
export 'tec_future_builder.dart';
export 'tec_modal_popup.dart';
export 'tec_page_route.dart';
export 'tec_popup_menu_button.dart';
export 'tec_search_field.dart';
export 'tec_stream_builder.dart';
export 'tec_tab_indicator.dart';

const defaultElevation = 3.0;

///
/// Returns a new `EdgeInsets` object based on the given [parentSize] and [childRect].
///
EdgeInsets insetsFromParentSizeAndChildRect(Size parentSize, Rect childRect) => EdgeInsets.fromLTRB(
      childRect.left,
      childRect.top,
      parentSize.width - childRect.right,
      parentSize.height - childRect.bottom,
    );

///
/// Returns the global rect of the widget with the given [globalKey], or null if none.
///
/// Uses [size] if provided, otherwise uses `(renderBox.hasSize ? renderBox.size : Size.zero)`.
///
Rect globalRectOfWidgetWithKey(GlobalKey globalKey, [Size size]) {
  if (globalKey != null) {
    final renderBox = globalKey.currentContext?.findRenderObject();
    if (renderBox is RenderBox) {
      final pt = renderBox.localToGlobal(Offset.zero);
      final rbSize = size ?? (renderBox.hasSize ? renderBox.size : Size.zero);
      return Rect.fromLTWH(pt.dx, pt.dy, rbSize.width, rbSize.height);
    }
  }
  return null;
}

///
/// Returns the size of the widget with the given [globalKey]. Returns null if a
/// widget with the key is not found. If the widget was found, but it has not
/// undergone layout, returns `Size.zero`.
///
Size sizeOfWidgetWithKey(GlobalKey globalKey) {
  if (globalKey != null) {
    final renderBox = globalKey.currentContext?.findRenderObject();
    if (renderBox is RenderBox) {
      if (renderBox.hasSize) return renderBox.size;
      return Size.zero;
    }
  }
  return null;
}

///
/// Returns the global offset of the widget with the given [globalKey], or null
/// if none.
///
/// If [ancestorKey] is non-null, this function converts the given point to the
/// coordinate system of the ancestor (which must be an ancestor of this render
/// object) instead of to the global coordinate system.
///
/// This method is implemented in terms of `getTransformTo`. If the transform
/// matrix puts the given `point` on the line at infinity (for instance, when
/// the transform matrix is the zero matrix), this method returns (NaN, NaN).
///
Offset globalOffsetOfWidgetWithKey(GlobalKey globalKey, {GlobalKey ancestorKey}) {
  if (globalKey != null) {
    final renderBox = globalKey.currentContext?.findRenderObject();
    if (renderBox is RenderBox) {
      if (ancestorKey != null) {
        final ancestor = ancestorKey.currentContext?.findRenderObject();
        if (ancestor is RenderObject) {
          return renderBox.localToGlobal(Offset.zero, ancestor: ancestor);
        }
      } else {
        return renderBox.localToGlobal(Offset.zero);
      }
    }
  }
  return null;
}

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
  final TextStyle style;

  const ListLabel(this.label, {this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: TecText(
          label,
          autoSize: true,
          style: style ?? Theme.of(context).textTheme.caption,
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
    final bodyColor =
        brightness == Brightness.light ? Colors.grey[800] : const Color(0xFFBBBBBB);

    return copyWith(
      accentColor: brightness == Brightness.light ? accentColor : Colors.blue,
      bottomSheetTheme:
          bottomSheetTheme.copyWith(elevation: defaultElevation, shape: bottomSheetShape),
      appBarTheme: tecAppBarTheme(),
      tabBarTheme: tecTabBarTheme(),
      textTheme: textTheme.apply(bodyColor: bodyColor, displayColor: bodyColor),
      iconTheme: iconTheme.copyWith(color: bodyColor),
      dialogBackgroundColor: brightness == Brightness.light ? Colors.grey[100] : Colors.grey[900],
      backgroundColor: brightness == Brightness.light ? Colors.white : Colors.black,
    );
  }

  ///
  /// Returns our special [AppBarTheme].
  ///
  AppBarTheme tecAppBarTheme() {
    final brightness = ThemeData.estimateBrightnessForColor(canvasColor);
    final barColor = brightness == Brightness.light ? Colors.grey[50] : Colors.grey[850];
    final barTextColor = brightness == Brightness.light ? Colors.grey[800] : Colors.grey[300];
    return appBarTheme.copyWith(
      brightness: brightness,
      color: barColor,
      elevation: defaultElevation,
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
  TextTheme copyOfAppBarTextThemeWithColor(Color color) {
    final theme = (appBarTheme.textTheme ?? primaryTextTheme)
        // .copyWith(headline6: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500))
        .apply(bodyColor: color)
        .apply(displayColor: color);

    return theme.copyWith(headline6: theme.headline6.copyWith(fontSize: 20));
  }
}

///
/// Removes the eight pixel padding from the top and bottom of the default AppBar.
///
class MinHeightAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget appBar;

  const MinHeightAppBar({Key key, this.appBar}) : super(key: key);

  @override
  Widget build(BuildContext context) => appBar ?? AppBar();

  @override
  Size get preferredSize => Size.fromHeight((appBar ?? AppBar()).preferredSize.height - 16.0);
}

///
/// Icon that can be embedded inline within text.
///
class IconSpan extends FixedWidthWidgetSpan {
  final double size;
  final Color color;

  IconSpan(IconData icon, this.size, this.color)
      : super(
          alignment: PlaceholderAlignment.middle,
          childWidth: size,
          child: Icon(icon, size: size, color: color),
        );
}

class IconWithNumberBadge extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;

  const IconWithNumberBadge({this.icon, this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Icon(icon),
      Positioned(
        right: 3,
        top: 1,
        child: Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: color ?? Colors.red,
            borderRadius: BorderRadius.circular(6),
          ),
          constraints: const BoxConstraints(
            minWidth: 8,
            minHeight: 8,
          ),
          child: value != null
              ? Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                )
              : null,
        ),
      )
    ]);
  }
}

const TextStyle cardTitleCompactStyle = TecTextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w700, // w700 == Bold
);

const TecTextStyle cardSubtitleCompactStyle = TecTextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w400, // w500 == Normal
);

class TecTextStyle extends TextStyle {
  const TecTextStyle({
    double fontSize = 12.0,
    FontWeight fontWeight,
    Color color = Colors.black,
    double letterSpacing,
    double height,
  }) : super(
          inherit: false,
          color: color,
          //fontFamily: 'Avenir',
          fontSize: fontSize,
          fontWeight: fontWeight,
          textBaseline: TextBaseline.alphabetic,
          letterSpacing: letterSpacing,
          height: height,
        );
}

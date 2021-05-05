import 'package:flutter/material.dart';

///
/// Use this in place of `showModalBottomSheet` for a modal bottom sheet that
/// doesn't take up the full width.
///
/// If the [maxWidth] or [height] values are less than or equal to 1.0, the value is
/// treated as a percentage of the total width or height. So, for example, if you
/// want the max width to be 600.0 points, use 600.0. If you want the max width to be
/// 80% of the total width, use 0.8, and the same goes for the [height] value.
///
Future<T> showModalBottomSheetWithMaxWidth<T>({
  @required double maxWidth,
  double height = 0.9,
  BuildContext context,
  Widget Function(BuildContext) builder,
  Color backgroundColor,
  double elevation,
  ShapeBorder shape,
  Clip clipBehavior,
  Color barrierColor,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  RouteSettings routeSettings,
  AnimationController transitionAnimationController,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0.0,
    barrierColor: barrierColor,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (context) => LayoutBuilder(
      builder: (context, constraints) {
        final actualMaxWidth = maxWidth == null
            ? null
            : maxWidth > 1.0
                ? maxWidth
                : constraints.maxWidth * maxWidth;
        final actualHeight = height == null
            ? null
            : height > 1.0
                ? height
                : constraints.maxHeight * height;
        final sheetTheme = Theme.of(context).bottomSheetTheme;
        return SizedBox(
          height: actualHeight,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.maybePop(context),
            child: Align(
              child: Container(
                constraints:
                    actualMaxWidth == null ? null : BoxConstraints(maxWidth: actualMaxWidth),
                child: GestureDetector(
                  // Eat the tap so the sheet doesn't close when it's tapped on.
                  onTap: () {},
                  child: Material(
                    elevation: elevation ?? sheetTheme.modalElevation ?? sheetTheme.elevation,
                    shape: shape,
                    clipBehavior: clipBehavior ?? Clip.none,
                    color: backgroundColor ??
                        sheetTheme.modalBackgroundColor ??
                        sheetTheme.backgroundColor,
                    child: Builder(builder: builder),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

import 'package:flutter/material.dart';

///
/// Builds and shows a dialog. If [maxWidth] and/or [maxHeight] are are not
/// `null`, the size of the dialog is constrained accordingly. If either
/// [maxWidth] or [maxHeight] is greater than the device window size, instead
/// of showing a dialog, a new route is pushed on the navigator using:
///
///   `Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: builder))`
///
Future<T> showTecDialog<T extends Object>({
  BuildContext context,
  bool useRootNavigator = true,
  bool barrierDismissible = true,
  WidgetBuilder builder,
  double maxWidth,
  double maxHeight,
  double cornerRadius,
  EdgeInsets padding = const EdgeInsets.all(20),
}) {
  var windowSize = Size.zero;
  if (maxWidth != null || maxHeight != null) {
    assert(debugCheckHasMediaQuery(context));
    windowSize = (MediaQuery.of(context, nullOk: true)?.size ?? Size.zero);
  }

  if ((maxWidth == null && maxHeight == null) ||
      (maxWidth != null && maxWidth <= windowSize.width) ||
      (maxHeight != null && maxHeight <= windowSize.height)) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? double.infinity,
              maxHeight: maxHeight ?? double.infinity,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(cornerRadius ?? 8),
            ),
            padding: padding,
            child: Builder(builder: builder),
          ),
        );
      },
    );
  }

  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push<T>(MaterialPageRoute<T>(builder: builder));
}

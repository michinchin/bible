import 'package:flutter/material.dart';

import 'common.dart';

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
  EdgeInsets padding = const EdgeInsets.all(20),
  bool makeScrollable = true,
}) {
  var windowSize = Size.zero;
  if (maxWidth != null || maxHeight != null) {
    assert(debugCheckHasMediaQuery(context));
    windowSize = (MediaQuery.of(context, nullOk: true)?.size ?? Size.zero);
  }

  if ((maxWidth == null || maxWidth + 40.0 <= windowSize.width) &&
      (maxHeight == null || maxHeight + 40.0 <= windowSize.height)) {
    return showTecModalPopup<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      semanticsDismissible: barrierDismissible,
      builder: (context) {
        return TecPopupSheet(
          margin: const EdgeInsets.all(32),
          padding: padding, // EdgeInsets.zero,
          makeScrollable: makeScrollable ?? true,
          child: Material(
            color: Colors.transparent,
            child: Container(
              // color: Colors.red,
              constraints: maxWidth == null && maxHeight == null
                  ? null
                  : BoxConstraints(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                    ),
              child: Builder(builder: builder),
            ),
          ),
        );
      },
    );
  }

  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push<T>(MaterialPageRoute<T>(builder: builder, fullscreenDialog: true));
}

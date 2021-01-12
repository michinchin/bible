import 'dart:ui';

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
  Alignment alignment = Alignment.center,
  bool attachedToEdge = false,
  bool blur = false,
}) {
  var windowSize = Size.zero;
  if (maxWidth != null || maxHeight != null) {
    assert(debugCheckHasMediaQuery(context));
    windowSize = (MediaQuery.of(context)?.size ?? Size.zero);
  }

  if ((maxWidth == null || maxWidth + 40.0 <= windowSize.width) &&
      (maxHeight == null || maxHeight + 40.0 <= windowSize.height)) {
    return showTecModalPopup<T>(
      context: context,
      barrierBlur: blur ? 5.0 : null,
      alignment: alignment,
      useRootNavigator: useRootNavigator,
      semanticsDismissible: barrierDismissible,
      animationType: alignment == Alignment.center
          ? TecPopupAnimationType.fadeScale
          : TecPopupAnimationType.slide,
      builder: (context) {
        return TecPopupSheet(
          margin: _marginWith(align: alignment, attachedToEdge: attachedToEdge),
          padding: padding, // EdgeInsets.zero,
          makeScrollable: makeScrollable ?? true,
          borderRadius: _borderRadiusWith(align: alignment, attachedToEdge: attachedToEdge),
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

BorderRadius _borderRadiusWith({
  @required Alignment align,
  @required bool attachedToEdge,
  Radius radius = const Radius.circular(12),
}) {
  return BorderRadius.only(
    topLeft: attachedToEdge && !(align.isTop || align.isLeft) ? radius : Radius.zero,
    topRight: attachedToEdge && !(align.isTop || align.isRight) ? radius : Radius.zero,
    bottomLeft: attachedToEdge && !(align.isBottom || align.isLeft) ? radius : Radius.zero,
    bottomRight: attachedToEdge && !(align.isBottom || align.isRight) ? radius : Radius.zero,
  );
}

EdgeInsets _marginWith({
  @required Alignment align,
  @required bool attachedToEdge,
  double padding = 32.0,
}) {
  return EdgeInsets.only(
    left: attachedToEdge && align.isLeft ? 0.0 : padding,
    top: attachedToEdge && align.isTop ? 0.0 : padding,
    right: attachedToEdge && align.isRight ? 0.0 : padding,
    bottom: attachedToEdge && align.isBottom ? 0.0 : padding,
  );
}

extension TecDialogExtOnAlignment on Alignment {
  bool get isTop => y == -1;
  bool get isCenterY => y == 0;
  bool get isBottom => y == 1;
  bool get isLeft => x == -1;
  bool get isCenterX => x == 0;
  bool get isRight => x == 1;
}

import 'dart:ui' show ImageFilter;

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum TecPopupAnimationType { fadeScale, slide }

/// Shows a modal popup that, depending on the [alignment] setting, can slide
/// up from the bottom of the screen (the default), slide down from the top of
/// the screen, slide in from either side, or slide in from any corner. :)
///
/// Such a popup is an alternative to a menu or a dialog and prevents the user
/// from interacting with the rest of the app (or current [Navigator] area).
///
/// The `context` argument is used to look up the [Navigator] for the popup.
/// It is only used when the method is called. Its corresponding widget can be
/// safely removed from the tree before the popup is closed.
///
/// The `useRootNavigator` argument is used to determine whether to push the
/// popup to the [Navigator] furthest from or nearest to the given `context`.
/// It is `false` by default.
///
/// The `semanticsDismissible` argument is used to determine whether the
/// semantics of the modal barrier are included in the semantics tree.
///
/// The `builder` argument typically builds a [TecPopupSheet] widget.
/// Content below the widget is dimmed with a [ModalBarrier]. The widget built
/// by the `builder` does not share a context with the location that
/// `showTecModalPopup` is originally called from. Use a
/// [StatefulBuilder] or a custom [StatefulWidget] if the widget needs to
/// update dynamically.
///
/// Returns a `Future` that resolves to the value that was passed to
/// [Navigator.pop] when the popup was closed.
///
/// See also:
///
///  * [TecPopupSheet], which is the widget usually returned by the
///    `builder` argument to [showTecModalPopup].
///
Future<T> showTecModalPopup<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  Color barrierColor,
  ImageFilter filter,
  bool useRootNavigator = true,
  bool semanticsDismissible,
  Alignment alignment = Alignment.bottomCenter,
  EdgeInsetsGeometry edgeInsets = const EdgeInsets.all(0),
  TecPopupAnimationType animationType = TecPopupAnimationType.fadeScale,
}) {
  assert(useRootNavigator != null);
  return Navigator.of(context, rootNavigator: useRootNavigator).push(
    _TecModalPopupRoute<T>(
      barrierColor: barrierColor ?? CupertinoDynamicColor.resolve(_kModalBarrierColor, context),
      barrierLabel: 'Dismiss',
      builder: builder,
      alignment: alignment ?? Alignment.bottomCenter,
      edgeInsets: edgeInsets,
      animationType: animationType ?? TecPopupAnimationType.fadeScale,
      filter: filter,
      semanticsDismissible: semanticsDismissible,
    ),
  );
}

/// A popup sheet.
///
/// A [TecPopupSheet] is typically passed as the child widget to
/// [showTecModalPopup].
///
class TecPopupSheet extends StatelessWidget {
  ///
  /// Creates a [TecPopupSheet].
  ///
  const TecPopupSheet({Key key, @required this.child, this.padding})
      : assert(child != null),
        super(key: key);

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      namesRoute: true,
      scopesRoute: true,
      explicitChildNodes: true,
      label: 'Popup',
      child: CupertinoUserInterfaceLevel(
        data: CupertinoUserInterfaceLevelData.elevated,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: _kEdgeHorizontalPadding,
            vertical: _kEdgeVerticalPadding,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _kBlurAmount, sigmaY: _kBlurAmount),
              child: Container(
                color: CupertinoDynamicColor.resolve(_kBackgroundColor, context),
                child: _PopupSheetContent(child: child, padding: padding),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

//
// PRIVATE DATA, FUNCTIONS, AND CLASSES
//

/// Barrier color for a Cupertino modal barrier.
/// Extracted from https://developer.apple.com/design/resources/.
const Color _kModalBarrierColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x11000000), // Color(0x33000000),
  darkColor: Color(0x7A000000),
);

/// The duration of the transition used when a modal popup is shown.
const Duration _kModalPopupTransitionDuration = Duration(milliseconds: 335);

///
/// Route that, depending on the popupMode setting, can slide up from the
/// bottom of the screen, or slide down from the top of the screen.
///
class _TecModalPopupRoute<T> extends PopupRoute<T> {
  _TecModalPopupRoute({
    this.barrierColor,
    this.barrierLabel,
    this.builder,
    this.alignment,
    this.edgeInsets = const EdgeInsets.all(0),
    this.animationType = TecPopupAnimationType.fadeScale,
    bool semanticsDismissible,
    ImageFilter filter,
    RouteSettings settings,
  }) : super(
          filter: filter,
          settings: settings,
        ) {
    _semanticsDismissible = semanticsDismissible;
  }

  final WidgetBuilder builder;
  bool _semanticsDismissible;

  final Alignment alignment;

  final EdgeInsetsGeometry edgeInsets;

  final TecPopupAnimationType animationType;

  @override
  final String barrierLabel;

  @override
  final Color barrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  bool get semanticsDismissible => _semanticsDismissible ?? false;

  @override
  Duration get transitionDuration => _kModalPopupTransitionDuration;

  Animation<double> _animation;

  Tween<Offset> _offsetTween;

  @override
  Animation<double> createAnimation() {
    assert(_animation == null);
    if (animationType == TecPopupAnimationType.slide) {
      _animation = CurvedAnimation(
          parent: super.createAnimation(),
          curve: Curves.linearToEaseOut,
          reverseCurve: Curves.linearToEaseOut.flipped);
      final beginX = (alignment.x < 0.0
          ? -1.0
          : alignment.x > 0.0
              ? 1.0
              : 0.0);
      final beginY = (alignment.y < 0.0
          ? -1.0
          : alignment.y > 0.0
              ? 1.0
              : 0.0);
      _offsetTween = Tween<Offset>(begin: Offset(beginX, beginY), end: const Offset(0.0, 0.0));
    } else {
      _animation = super.createAnimation();
    }
    return _animation;
  }

  @override
  Widget buildPage(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: Builder(builder: builder),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Container(
      padding: edgeInsets,
      child: ClipRect(
        child: Align(
          alignment: alignment,
          child: animationType == TecPopupAnimationType.slide
              ? FractionalTranslation(translation: _offsetTween.evaluate(_animation), child: child)
              : FadeScaleTransition(animation: _animation, child: child),
        ),
      ),
    );
  }
}

///
/// [TecPopupSheet] content
///
class _PopupSheetContent extends StatelessWidget {
  final Widget child;
  final ScrollController scrollController;
  final EdgeInsets padding;

  const _PopupSheetContent({Key key, @required this.child, this.scrollController, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return SingleChildScrollView(
        controller: scrollController,
        child: const SizedBox(width: 0.0, height: 0.0),
      );
    } else {
      return CupertinoScrollbar(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: _kContentHorizontalPadding,
                  vertical: _kContentVerticalPadding,
                ),
            child: DefaultTextStyle(
              style: _kPopupSheetContentStyle.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              child: child,
            ),
          ),
        ),
      );
    }
  }
}

const TextStyle _kPopupSheetContentStyle = TextStyle(
  fontFamily: '.SF UI Text',
  inherit: false,
  fontSize: 13.0,
  fontWeight: FontWeight.w400,
  color: _kContentTextColor,
  textBaseline: TextBaseline.alphabetic,
);

// Translucent, very light gray that is painted on top of the blurred backdrop
// as the sheet's background color.
const Color _kBackgroundColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFDFDFD), // originally Color(0xC7F9F9F9),
  darkColor: Color(0xFF1E1E1E), // originally Color(0xC7252525)
);

// The gray color used for text that appears in the content area.
const Color _kContentTextColor = Color(0xFF8F8F8F);

const double _kBlurAmount = 20.0;

const double _kEdgeHorizontalPadding = 8.0;
const double _kEdgeVerticalPadding = 8.0; // originally 10.0;

const double _kContentHorizontalPadding = 14.0; // originally 40.0;
const double _kContentVerticalPadding = 14.0;

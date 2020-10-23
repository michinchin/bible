import 'dart:ui' show ImageFilter;

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum TecPopupAnimationType { fadeScale, slide }

/// Shows a modal popup that is positioned based on [alignment] and
/// [edgeInsets], and is animated when opening and closing based on
/// [animationType].
///
/// It is an alternative to a menu or a dialog and prevents the user from
/// interacting with the rest of the app (or current [Navigator] area).
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
  Offset offset,
  EdgeInsetsGeometry edgeInsets = const EdgeInsets.all(0),
  TecPopupAnimationType animationType = TecPopupAnimationType.fadeScale,
}) {
  assert(useRootNavigator != null);
  return Navigator.of(context, rootNavigator: useRootNavigator ?? true).push(
    _TecModalPopupRoute<T>(
      barrierColor: barrierColor ?? CupertinoDynamicColor.resolve(_kModalBarrierColor, context),
      barrierLabel: 'Dismiss',
      builder: builder,
      alignment: alignment ?? Alignment.bottomCenter,
      offset: offset,
      edgeInsets: edgeInsets ?? const EdgeInsets.all(0),
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
  final Widget child;
  final Widget title;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double bgOpacity;
  final double bgBlur;

  ///
  /// Creates a [TecPopupSheet].
  ///
  const TecPopupSheet({
    Key key,
    @required this.child,
    this.title,
    this.margin = const EdgeInsets.all(8),
    this.padding = const EdgeInsets.all(14),
    this.bgOpacity = 0.75,
    this.bgBlur = 20.0,
  })  : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = CupertinoDynamicColor.withBrightness(
      color: const Color(0xFFFFFFFF).withOpacity(bgOpacity), // originally F9F9F9
      darkColor: const Color(0xFF252525).withOpacity(bgOpacity), // originally 252525
    );

    // return Container(width: 10, height: 10, color: Colors.red.withOpacity(0.5));

    return Semantics(
      namesRoute: true,
      scopesRoute: true,
      explicitChildNodes: true,
      label: 'Popup',
      child: CupertinoUserInterfaceLevel(
        data: CupertinoUserInterfaceLevelData.elevated,
        child: Container(
          margin: margin ?? const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: bgBlur, sigmaY: bgBlur),
              // child: Container(width: 300, height: 300, color: Colors.white.withOpacity(0.7)),
              child: Container(
                color: CupertinoDynamicColor.resolve(bgColor, context),
                child: _PopupSheetContent(child: child, title: title, padding: padding),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//
// PRIVATE DATA, FUNCTIONS, AND CLASSES
//

/// Barrier color for a Cupertino modal barrier.
/// Extracted from https://developer.apple.com/design/resources/.
const Color _kModalBarrierColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x22000000), // Color(0x33000000),
  darkColor: Color(0x7A000000),
);

/// The duration of the transition used when a modal popup is shown.
const Duration _kModalPopupTransitionDuration = Duration(milliseconds: 335);

///
/// Route that, depending on the popupMode setting, can slide up from the
/// bottom of the screen, or slide down from the top of the screen.
///
class _TecModalPopupRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  final bool _semanticsDismissible;
  final Alignment alignment;
  final Offset offset;
  final EdgeInsetsGeometry edgeInsets;
  final TecPopupAnimationType animationType;

  _TecModalPopupRoute({
    this.barrierColor,
    this.barrierLabel,
    this.builder,
    this.alignment,
    this.offset,
    this.edgeInsets = const EdgeInsets.all(0),
    this.animationType = TecPopupAnimationType.fadeScale,
    bool semanticsDismissible,
    ImageFilter filter,
    RouteSettings settings,
  })  : _semanticsDismissible = semanticsDismissible,
        super(
          filter: filter,
          settings: settings,
        );

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
    final safeAreaInsets = MediaQuery.of(context).viewPadding;
    // dmPrint('_TecModalPopupRoute buildTransitions safe area $safeAreaInsets');

    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // dmPrint('_TecModalPopupRoute buildTransitions constraints: ${constraints.biggest}');

          var align = alignment;
          if (offset != null) {
            final cx = constraints.maxWidth / 2;
            final cy = constraints.maxHeight / 2;
            final x = ((offset.dx - safeAreaInsets.left) - cx) / cx;
            final y = ((offset.dy - safeAreaInsets.top) - cy) / cy;
            align = Alignment(x, y);
            // dmPrint('_TecModalPopupRoute buildTransitions alignment: $align');
          }

          return Container(
            padding: edgeInsets,
            child: ClipRect(
              child: Align(
                alignment: align,
                child: animationType == TecPopupAnimationType.slide
                    ? FractionalTranslation(
                        translation: _offsetTween.evaluate(_animation), child: child)
                    : FadeScaleTransition(animation: _animation, child: child),
              ),
            ),
          );
        },
      ),
    );
  }
}

///
/// [TecPopupSheet] content
///
class _PopupSheetContent extends StatelessWidget {
  final Widget child;
  final Widget title;
  final ScrollController scrollController;
  final EdgeInsets padding;

  const _PopupSheetContent({
    Key key,
    @required this.child,
    this.title,
    this.scrollController,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return SingleChildScrollView(
        controller: scrollController,
        child: const SizedBox(width: 0.0, height: 0.0),
      );
    } else {
      if (title != null) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            title,
            Flexible(child: scrollableChild()),
          ],
        );
      }
      return scrollableChild();
    }
  }

  Widget scrollableChild() {
    return CupertinoScrollbar(
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(14),
          child: DefaultTextStyle(
            style: _kPopupSheetContentStyle,
            textAlign: TextAlign.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

const TextStyle _kPopupSheetContentStyle = TextStyle(
  // fontFamily: '.SF UI Text',
  inherit: false,
  fontSize: 13.0,
  fontWeight: FontWeight.w600,
  color: Color(0xFF8F8F8F),
  textBaseline: TextBaseline.alphabetic,
);

void dmPrint(Object object) {
  if (kDebugMode) print(object); // ignore: avoid_print
}

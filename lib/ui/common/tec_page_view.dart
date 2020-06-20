import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tec_util/tec_util.dart' as tec;

///
/// Similar to the [PageView] class, except that it supports unbounded
/// page scrolling in both directions, with no need to specify, or even
/// know, the limit of pages in either direction.
///
/// Scrolling is enabled in both directions until the provided [pageBuilder]
/// returns `null` for a given page index, which will disable scrolling to
/// that page index. Page index values just represent the offset from page
/// zero, and can be positive or negative values.
///
/// A [TecPageController] can be used to query and control which page is
/// visible via the `page`, `animateToPage`, `jumpToPage`, `nextPage`, and
/// `previousPage` functions. And the [TecPageController.viewportFraction]
/// property can be used to control the size of each page as a fraction of
/// the viewport size.
///
class TecPageView extends StatefulWidget {
  ///
  /// Creates a [TecPageView] for scrolling a list of widgets page by page.
  ///
  /// The [pageBuilder] parameter must not be null, and will be called only
  /// when necessary to build each page when it is scrolled into view. If
  /// a page cannot be built for the given index (i.e. the page is out of
  /// range for the content), the [pageBuilder] should return null, which
  /// disables scrolling to that page.
  ///
  const TecPageView({
    Key key,
    @required this.pageBuilder,
    this.controller,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.onPageChanged,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
  })  : assert(pageBuilder != null),
        assert(allowImplicitScrolling != null),
        super(key: key);

  /// Function that creates a widget for each page, given the page index.
  final IndexedWidgetBuilder pageBuilder;

  /// Controls whether the widget's pages will respond to
  /// [RenderObject.showOnScreen], which will allow for implicit accessibility
  /// scrolling.
  ///
  /// With this flag set to false, when accessibility focus reaches the end of
  /// the current page and the user attempts to move it to the next element, the
  /// focus will traverse to the next widget outside of the page view.
  ///
  /// With this flag set to true, when accessibility focus reaches the end of
  /// the current page and user attempts to move it to the next element, focus
  /// will traverse to the next page in the page view.
  final bool allowImplicitScrolling;

  /// The axis along which the page view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Whether the page view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the page view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the page view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this page
  /// view is scrolled.
  final TecPageController controller;

  /// Called whenever the page in the center of the viewport changes.
  final ValueChanged<int> onPageChanged;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  @override
  _TecPageViewState createState() => _TecPageViewState();
}

class _TecPageViewState extends State<TecPageView> {
  _TecPageViewScrollPhysics _physics;
  bool _didCreateController = false;
  TecPageController _controller;

  @override
  void initState() {
    super.initState();
    update();
  }

  @override
  void didUpdateWidget(TecPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    update();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  void disposeController() {
    if (_didCreateController) {
      _controller?.dispose();
      _controller = null;
    }
  }

  void update() {
    if (_controller == null || (widget.controller != null && widget.controller != _controller)) {
      // tec.dmPrint('_TecPageViewState updating the page controller...');

      // First, dispose of the old controller (if we created it).
      disposeController();

      // Create the controller if necessary, or save a reference to the provided one.
      _controller = widget.controller ?? TecPageController();
      _didCreateController = (widget.controller == null);

      // Create a new scroll physics object, linked to the current page controller.
      _physics = _TecPageViewScrollPhysics(pageController: _controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: widget.scrollDirection ?? Axis.horizontal,
      reverse: widget.reverse ?? false,
      pageSnapping: false,
      dragStartBehavior: widget.dragStartBehavior ?? DragStartBehavior.start,
      allowImplicitScrolling: widget.allowImplicitScrolling ?? false,
      onPageChanged: widget.onPageChanged == null
          ? null
          : (page) =>
              widget.onPageChanged(_controller._fauxPageFromActualPage(page.toDouble()).round()),
      controller: _controller._pageController,
      physics: _physics,
      itemCount: _controller._maxPossiblePages,
      itemBuilder: (context, index) {
        final fauxIndex = _controller._fauxPageFromActualPage(index.toDouble()).round();
        final page = widget.pageBuilder(context, fauxIndex);
        if (page == null) {
          return Container();
        } else {
          _controller.enablePage(fauxIndex);
          return page;
        }
      },
    );
  }
}

const _defaultMaxPossiblePages = 100000;

///
/// A [TecPageController] provides a way to manipulate which page is visible in
/// a [TecPageView], and provides a way (via the [viewportFraction] parameter)
/// to control the fraction of the viewport that each page occupies.
///
/// See also:
///  * [TecPageView], which is the widget this object controls.
///
class TecPageController implements PageController {
  ///
  /// Creates a [TecPageController].
  ///
  TecPageController({
    int initialPage = 0,
    int minPage,
    int maxPage,
    bool keepPage = true,
    double viewportFraction = 1.0,
    int maxPossiblePages = _defaultMaxPossiblePages,
  })  : assert(initialPage != null),
        assert(initialPage < maxPossiblePages),
        assert(minPage == null || minPage <= initialPage),
        assert(maxPage == null || minPage >= initialPage),
        assert(keepPage != null),
        assert(viewportFraction != null && viewportFraction > 0.0) {
    _fauxInitialPage = initialPage;
    _maxPossiblePages = math.max(
      maxPossiblePages ?? _defaultMaxPossiblePages,
      _defaultMaxPossiblePages,
    );
    _pageController = PageController(
      initialPage: _maxPossiblePages ~/ 2,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
    );
    _minPage = _actualPageFromFauxPage(minPage ?? initialPage);
    _maxPage = _actualPageFromFauxPage(maxPage ?? initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
  }

  // This class's primary purpose is to translate between 'faux' (or external)
  // page indices and actual (or internal) page indices.

  int _fauxInitialPage;
  int _maxPossiblePages;
  int _minPage;
  int _maxPage;
  PageController _pageController;

  int _actualPageFromFauxPage(int fauxPage) => _pageController.initialPage + fauxPage;

  double _fauxPageFromActualPage(double actualPage) =>
      _fauxInitialPage + (actualPage - _pageController.initialPage);

  void enablePage(int page) {
    _enableActualPage(_actualPageFromFauxPage(page));
  }

  void _enableActualPage(int actualPage) {
    if (_minPage > actualPage) {
      _minPage = actualPage;
      tec.dmPrint('TecPageController updated minPage to $page');
    } else if (_maxPage < actualPage) {
      _maxPage = actualPage;
      tec.dmPrint('TecPageController updated maxPage to $page');
    }
  }

  //
  // Inherited from PageController:
  //

  @override
  int get initialPage => _fauxInitialPage;

  @override
  bool get keepPage => _pageController.keepPage;

  @override
  double get viewportFraction => _pageController.viewportFraction;

  @override
  double get page => _fauxPageFromActualPage(_pageController.page);

  @override
  Future<void> animateToPage(int page, {Duration duration, Curve curve}) {
    final actualPage = _actualPageFromFauxPage(page);
    _enableActualPage(actualPage);
    return _pageController.animateToPage(actualPage, duration: duration, curve: curve);
  }

  @override
  void jumpToPage(int page) {
    final actualPage = _actualPageFromFauxPage(page);
    _enableActualPage(actualPage);
    _pageController.jumpToPage(actualPage);
  }

  @override
  Future<void> nextPage({Duration duration, Curve curve}) {
    return _pageController.nextPage(duration: duration, curve: curve);
  }

  @override
  Future<void> previousPage({Duration duration, Curve curve}) {
    return _pageController.previousPage(duration: duration, curve: curve);
  }

  //
  // Inherited from ScrollController:
  //
  // Note, no attempt is made to convert between faux and actual scroll positions.
  //

  @override
  double get initialScrollOffset => _pageController.initialScrollOffset;

  @override
  bool get keepScrollOffset => _pageController.keepScrollOffset;

  @override
  String get debugLabel => _pageController.debugLabel;

  @override
  Iterable<ScrollPosition> get positions => _pageController.positions;

  @override
  bool get hasClients => _pageController.hasClients;

  @override
  ScrollPosition get position => _pageController.position;

  @override
  double get offset => _pageController.offset;

  @override
  Future<void> animateTo(double offset, {Duration duration, Curve curve}) {
    return _pageController.animateTo(offset, duration: duration, curve: curve);
  }

  @override
  void jumpTo(double value) {
    _pageController.jumpTo(value);
  }

  @override
  void attach(ScrollPosition position) {
    return _pageController.attach(position);
  }

  @override
  void detach(ScrollPosition position) {
    _pageController.detach(position);
  }

  @override
  ScrollPosition createScrollPosition(
      ScrollPhysics physics, ScrollContext context, ScrollPosition oldPosition) {
    return _pageController.createScrollPosition(physics, context, oldPosition);
  }

  @override
  void debugFillDescription(List<String> description) {
    _pageController.debugFillDescription(description);
  }

  //
  // Inherited from ChangeNotifier:
  //

  @override
  bool get hasListeners => _pageController.hasListeners;

  @override
  void addListener(VoidCallback listener) {
    _pageController.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _pageController.removeListener(listener);
  }

  @override
  void notifyListeners() {
    _pageController.notifyListeners();
  }
}

///
/// Scroll physics used by a [TecPageView].
///
/// These physics cause the page view to snap to page boundaries and limit
/// scrolling past the min and max pages specified in `pageInfo`.
///
@immutable
class _TecPageViewScrollPhysics extends ScrollPhysics {
  final TecPageController pageController;

  const _TecPageViewScrollPhysics({ScrollPhysics parent, this.pageController})
      : super(parent: parent);

  @override
  _TecPageViewScrollPhysics applyTo(ScrollPhysics ancestor) {
    return _TecPageViewScrollPhysics(parent: buildParent(ancestor), pageController: pageController);
  }

  double _initialPageOffset(double viewportDimension) =>
      math.max(0, viewportDimension * ((pageController?.viewportFraction ?? 1.0) - 1) / 2);

  double _pageFromPixels(double pixels, ScrollMetrics position) {
    final actual = math.max(
            0.0,
            pixels.clamp(position.minScrollExtent, position.maxScrollExtent) -
                _initialPageOffset(position.viewportDimension)) /
        math.max(1.0, position.viewportDimension * (pageController?.viewportFraction ?? 1.0));
    final round = actual.roundToDouble();
    if ((actual - round).abs() < precisionErrorTolerance) {
      return round;
    }
    return actual;
  }

  double _pixelsFromPage(double page, ScrollMetrics position) {
    return page * position.viewportDimension * (pageController?.viewportFraction ?? 1.0) +
        _initialPageOffset(position.viewportDimension);
  }

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    // Get the page from the scroll position.
    var page = _pageFromPixels(position.pixels, position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    page = page.roundToDouble();

    // Make sure the page is in range.
    final minPage = pageController?._minPage?.toDouble();
    final maxPage = pageController?._maxPage?.toDouble();
    if (minPage != null && page < minPage) {
      // tec.dmPrint('_TecPageViewScrollPhysics limiting page to $minPage');
      page = minPage;
    } else if (maxPage != null && page > maxPage) {
      // tec.dmPrint('_TecPageViewScrollPhysics limiting page to $maxPage');
      page = maxPage;
    }

    return _pixelsFromPage(page, position);
  }

  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    final tolerance = this.tolerance;
    final target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }
}

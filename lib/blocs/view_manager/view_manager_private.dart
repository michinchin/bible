part of 'view_manager_bloc.dart';

const _useFloatingTitles = true;

const bool _showViewPadding = true;
const _viewPaddingSize = .5;
const _viewPaddingColorLight = Color(0xffdddddd);
const _viewPaddingColorDark = Color(0xff222222);

const _viewResizeAnimationDuration = Duration(milliseconds: 500);
const _viewResizeAnimationCurve = Curves.easeInCubic;

// Copied from flutter/lib/src/material/app_bar.dart
const double _kMaxTitleTextScaleFactor = 1.34;

///
/// Stack of managed views.
///
class _VMViewStack extends StatefulWidget {
  final BoxConstraints constraints;
  final ViewManagerState vmState;
  final WidgetBuilder mainMenuButtonBuilder;

  const _VMViewStack({Key key, this.constraints, this.vmState, this.mainMenuButtonBuilder})
      : super(key: key);

  @override
  _VMViewStackState createState() => _VMViewStackState();
}

class _VMViewStackState extends State<_VMViewStack> {
  @override
  Widget build(BuildContext context) {
    final constraints = widget.constraints;

    final vmBloc = context.viewManager;
    assert(vmBloc != null);

    final sizeChanged = ((vmBloc?._size ?? Size.zero) != constraints.biggest);
    if (sizeChanged) tec.dmPrint('ViewManager size changed to ${constraints.biggest}');

    vmBloc?._size = constraints.biggest;

    final wasVisibleTextSelected = (vmBloc?.visibleViewsWithSelections?.isNotEmpty ?? false);

    var mqData = MediaQuery.of(context);
    mqData = mqData.copyWith(
        textScaleFactor: math.min(mqData.textScaleFactor, _kMaxTitleTextScaleFactor));
    final floatingTitleHeight = _useFloatingTitles ? mqData.textScaleFactor * 36.0 : 0.0;
    final topOffset =
        floatingTitleHeight == 0.0 ? 0.0 : (floatingTitleHeight / 2.0).roundToDouble();

    final rect =
        Rect.fromLTWH(0, topOffset, constraints.maxWidth, constraints.maxHeight - topOffset);

    {
      final portraitHeight = math.max(rect.width, rect.height);
      final portraitWidth = math.min(constraints.maxWidth, constraints.maxHeight);
      if (portraitHeight < 950.0 && portraitWidth < 500) {
        // This is a phone or small app window, so only allow 2 views.
        _minSize = math.max((portraitHeight / 2.0).floorToDouble(), 244 - topOffset);
        vmBloc?._numViewsLimited = true;
      } else {
        // This is a larger window or tablet.
        _minSize = 300;
        vmBloc?._numViewsLimited = false;
      }
    }

    // Build and update the rows, which updates `vmBloc._rows`, `._overflow`, and `._isFull`.
    final countOfOnScreenViews = vmBloc?._rows?.totalItems ?? 0;
    _buildRows(vmBloc, _SizeOpt.ideal, widget.vmState, rect.width, rect.height)
      ..balance(rect.width);
    final countOfOnScreenViewsChanged = (countOfOnScreenViews != (vmBloc?._rows?.totalItems ?? 0));

    // Is there a maximized view?
    var maximizedView = widget.vmState.views
        .firstWhere((e) => e.uid == widget.vmState.maximizedViewUid, orElse: () => null);

    tec.dmPrint('_VMViewStack build, maximizedView: ${maximizedView?.uid ?? 'none'}');

    // Is there a view with keyboard focus?
    var viewWithKeyboardFocus = widget.vmState.views
        .firstWhere((e) => e.uid == vmBloc?._viewWithKeyboardFocus, orElse: () => null);
    if (viewWithKeyboardFocus != null && maximizedView != null) {
      maximizedView = viewWithKeyboardFocus;
      viewWithKeyboardFocus = null;
    }

    final thisBuildHasMaxedView = (maximizedView != null);
    final lastBuildHadMaxedView = (vmBloc?._prevBuildMaxedViewUid ?? 0) != 0;

    // Build the view widgets.
    final viewRects = <ViewRect>[];
    final children = vmBloc?._rows?.toViewWidgetList(
      context: context,
      constraints: constraints,
      floatingTitleMQData: mqData,
      rect: rect,
      prevBuildMaxedViewUid: vmBloc?._prevBuildMaxedViewUid ?? 0,
      maximizedView: maximizedView,
      viewWithKeyboardFocus: viewWithKeyboardFocus,
      overflowViews: vmBloc?._overflow,
      rects: viewRects,
      animationDuration: sizeChanged ||
              countOfOnScreenViewsChanged ||
              lastBuildHadMaxedView != thisBuildHasMaxedView
          ? _viewResizeAnimationDuration
          : null,
      numViewsLimited: vmBloc?.numViewsLimited ?? true,
      floatingTitleHeight: floatingTitleHeight,
      mainMenuButtonBuilder: widget.mainMenuButtonBuilder,
    );
    vmBloc?._viewRects = viewRects;
    vmBloc?._prevBuildMaxedViewUid = maximizedView?.uid ?? 0;

    // If this build has a maxed view, but the last one didn't, or vice versa, rebuild
    // again after the resize animation finishes. Because, for a nicer and smoother
    // animation, only the view that is maximized or minimized is animated, and after
    // the animation the other views need to be rebuilt so they are sized and layered
    // correctly.
    if (lastBuildHadMaxedView != thisBuildHasMaxedView) {
      Future.delayed(_viewResizeAnimationDuration, () {
        tec.dmPrint('_VMViewStack refreshing after maximize/minimize.');
        setState(() {});
      });
    }

    // If the state of visible selected text changed, call _updateSelectionBloc after the build.
    final isVisibleTextSelected = (vmBloc?.visibleViewsWithSelections?.isNotEmpty ?? false);
    if (wasVisibleTextSelected != isVisibleTextSelected) {
      WidgetsBinding.instance
          .addPostFrameCallback((timeStamp) => vmBloc?._updateSelectionBloc(context));
    }

    return Theme(
      data: Theme.of(context).copyWith(
        // appBarTheme: Theme.of(context).tecAppBarTheme(),
        pageTransitionsTheme: tecPageTransitionsTheme(context),
      ),
      child: Stack(children: children),
    );
  }
}

@freezed
abstract class ManagedViewState with _$ManagedViewState {
  factory ManagedViewState(
    BoxConstraints parentConstraints,
    ViewState viewState,
    Size viewSize,
    int viewIndex,
    int row,
    int col,
    int rowCount,
    int colCount,
    bool isMaximized, // ignore: avoid_positional_boolean_parameters
  ) = _ManagedViewState;
}

class ManagedViewBloc extends Bloc<ManagedViewState, ManagedViewState> {
  ManagedViewBloc(ManagedViewState initialState) : super(initialState);

  @override
  Stream<ManagedViewState> mapEventToState(ManagedViewState event) async* {
    yield ManagedViewState(event.parentConstraints, event.viewState, event.viewSize,
        event.viewIndex, event.row, event.col, event.rowCount, event.colCount, event.isMaximized);
  }
}

///
/// Root navigator for a managed view, so each view has its own navigation
/// state and history.
///
class _ManagedViewNavigator extends StatefulWidget {
  final ManagedViewState managedViewState;

  const _ManagedViewNavigator(this.managedViewState, {Key key}) : super(key: key);

  @override
  _ManagedViewNavigatorState createState() => _ManagedViewNavigatorState();
}

class _ManagedViewNavigatorState extends State<_ManagedViewNavigator> {
  @override
  void didUpdateWidget(_ManagedViewNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final state = widget.managedViewState;
    context.read<ManagedViewBloc>().add(state);
  }

  Widget _routeBuilder(BuildContext context) => BlocBuilder<ManagedViewBloc, ManagedViewState>(
      builder: (context, state) =>
          ViewManager.shared._buildScaffold(context, state.viewState, state.viewSize));

  @override
  Widget build(BuildContext context) {
    final s = widget.managedViewState;

    Widget _navigator() => ClipRect(
          child: Navigator(
            onGenerateRoute: (settings) => TecPageRoute<dynamic>(
              settings: settings,
              builder: _routeBuilder,
            ),
          ),
        );

    return !_showViewPadding
        ? _navigator()
        : Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? _viewPaddingColorDark
                : _viewPaddingColorLight,
            padding: s.isMaximized || (s.rowCount == 1 && s.colCount == 1)
                ? const EdgeInsets.only(top: _viewPaddingSize)
                : EdgeInsets.only(
                    left: s.col == 0 ? 0 : _viewPaddingSize,
                    right: s.col == s.colCount - 1 ? 0 : _viewPaddingSize,
                    top: /* s.row == 0 ? 0 : */ _viewPaddingSize,
                    bottom: s.row == s.rowCount - 1 ? 0 : _viewPaddingSize,
                  ),
            child: _navigator(),
          );
  }
}

///
/// Size options, `minimum` or `ideal`.
///
enum _SizeOpt { min, ideal }

///
/// Builds the rows of views.
///
List<List<ViewState>> _buildRows(
  ViewManagerBloc vmBloc,
  _SizeOpt sizeOpt,
  ViewManagerState state,
  double width,
  double height,
) {
  final rows = <List<ViewState>>[];
  var isFull = false;
  for (final viewState in state.views) {
    // Add another row?
    if (!isFull &&
        (rows.isEmpty ||
            rows.last.width(width, sizeOpt) + viewState.width(width, sizeOpt) > width)) {
      // If another row won't fit, set `isFull` to true.
      if (rows.isNotEmpty &&
          rows.height(height, sizeOpt) + viewState.height(height, sizeOpt) > height) {
        isFull = true;
      }
      rows.add(<ViewState>[]);
    }
    rows.last.add(viewState);
  }

  // If `isFull`, the last row is the row of off screen views (i.e. overflow).
  vmBloc?._overflow = isFull ? rows.removeLast() : [];
  vmBloc?._rows = rows;
  vmBloc?._isFull = isFull ||
      (rows.isNotEmpty &&
          rows.last.width(width, sizeOpt) + _defaultMinWidth(width) > width &&
          rows.height(height, sizeOpt) + _defaultMinHeight(height) > height);

  // tec.dmPrint('ViewManagerBloc.isFull == ${vmBloc?.isFull}');

  return rows;
}

const _iPhoneSEHeight = 568.0;
var _minSize = (_iPhoneSEHeight - 20.0) / 2; // 274

const Size _defaultSize = Size(320, 480);

///
/// Returns the minimum width for a view that is never less than _minSize,
/// otherwise it is the width that will fit at least three columns, or more
/// if each column has a width of at least 400.
///
double _defaultMinWidth(double width) => math.max(
    // Make sure each column's width is not less than _minSize.
    _minSize,
    math.min(
      // Allow more than three columns if each column's width is >= 400.0.
      400.0,
      // The maximum width that will allow three columns.
      ((width ?? _defaultSize.width) / 3.0).floor().toDouble(),
    ));

///
/// Returns the minimum height for a view that is never less than _minSize and
/// never greater than the height that allows for more than three rows.
///
double _defaultMinHeight(double height) => math.max(
      // Make sure each row's height is not less than _minSize.
      _minSize,
      // The maximum height that will allow three rows.
      ((height ?? _defaultSize.height) / 3.0).floor().toDouble(),
    );

///
/// ViewState extensions.
///
extension _ExtOnViewState on ViewState {
  double minWidth(double w) => _defaultMinWidth(w);
  double minHeight(double h) => _defaultMinHeight(h);
  double idealWidth(double w) => math.max(preferredWidth ?? 0, minWidth(w));
  double idealHeight(double h) => math.max(preferredHeight ?? 0, minHeight(h));
  double width(double w, _SizeOpt o) => o == _SizeOpt.min ? minWidth(w) : idealWidth(w);
  double height(double h, _SizeOpt o) => o == _SizeOpt.min ? minHeight(h) : idealHeight(h);
}

///
/// List<ViewState> extensions.
///
extension _ExtOnListOfViewState on List<ViewState> {
  double minWidth(double w) => fold(0.0, (t, vs) => t + vs.minWidth(w));
  double minHeight(double h) => fold(0.0, (t, vs) => math.max(t, vs.minHeight(h)));
  double idealWidth(double w) => fold(0.0, (t, vs) => t + vs.idealWidth(w));
  double idealHeight(double h) => fold(0.0, (t, vs) => math.max(t, vs.idealHeight(h)));
  double width(double w, _SizeOpt o) => o == _SizeOpt.min ? minWidth(w) : idealWidth(w);
  double height(double h, _SizeOpt o) => o == _SizeOpt.min ? minHeight(h) : idealHeight(h);
  String toDebugString() => '[${map<int>((e) => e.uid).join(', ')}]';
}

// ignore_for_file: unused_element

///
/// List<List<ViewState>> extensions
///
extension _ExtOnListOfListOfViewState on List<List<ViewState>> {
  double minHeight(double h) => fold(0.0, (t, vs) => t + vs.minHeight(h));
  double idealHeight(double h) => fold(0.0, (t, vs) => t + vs.idealHeight(h));
  double height(double h, _SizeOpt o) => o == _SizeOpt.min ? minHeight(h) : idealHeight(h);
  int get totalItems => fold(0, (t, vs) => t + vs.length);
  int itemsInRow(int row) => row < 0 || row >= length ? 0 : this[row].length;
  int get rowCount => length;

  ///
  /// Balances rows of items based on the ideal width of each item.
  ///
  void balance(double width) {
    // Balance from the bottom up.
    for (var i = length - 2; i >= 0; i--) {
      while (_balanceRow(i, width)) {
        // Row `i` changed, so we need to rebalance the rows after it.
        // Rebalance from row `i + 1` down, until there a no changes.
        var changed = false;
        for (var j = i + 1; j < length - 1; j++) {
          if (_balanceRow(j, width)) {
            changed = true;
          } else {
            // Stop if there were no changes.
            break; //-------------------------->
          }
        }
        if (!changed) break;
      }
    }
  }

  ///
  /// Balances row `i` with the row after it, based on the ideal width of the
  /// items in the two rows.
  ///
  bool _balanceRow(int i, double width) {
    assert(i != null && i >= 0 && i + 1 < length);
    if (i + 1 >= length) return false;

    final row1 = this[i];
    final row2 = this[i + 1];
    var changed = false;

    // Keep moving the last item in row `i` to the next row until they are in balance.
    while (row1.length > 1) {
      if (row2.idealWidth(width) + row1.last.idealWidth(width) <= row1.idealWidth(width)) {
        row2.insert(0, row1.removeLast());
        changed = true;
      } else {
        break;
      }
    }

    return changed;
  }

  ///
  /// Returns the positioned view widgets.
  ///
  List<Widget> toViewWidgetList({
    @required BuildContext context,
    @required BoxConstraints constraints,
    @required Rect rect,
    @required int prevBuildMaxedViewUid, // 0 if none.
    @required ViewState maximizedView,
    @required ViewState viewWithKeyboardFocus,
    @required List<ViewState> overflowViews,
    @required List<ViewRect> rects,
    @required Duration animationDuration,
    @required bool numViewsLimited,
    @required double floatingTitleHeight,
    @required MediaQueryData floatingTitleMQData,
    @required WidgetBuilder mainMenuButtonBuilder,
  }) {
    // Cannot have both a `maximizedView` and a `viewWithKeyboardFocus`.
    assert(maximizedView == null || viewWithKeyboardFocus == null);

    // The `rects` list must start out empty.
    assert(rects != null && rects.isEmpty);

    // Note, `maxedView` will be set to `viewWithKeyboardFocus` if it needs to be auto-maximized.
    var maxedView = maximizedView;

    final yExtraPerRow = math.max(0.0, (rect.height - idealHeight(rect.height)) / length);
    var yExtra = yExtraPerRow > 0.0 ? 0.0 : rect.height - minHeight(rect.height);

    final viewStates = <ViewState>[];

    // Loop through all the rows, adding a ViewRect to `rects` for each ViewState in the row.
    var y = rect.top, r = 0;
    for (final row in this) {
      var x = 0.0;

      double height;
      if (yExtraPerRow > 0.0) {
        height = row.idealHeight(rect.height) + yExtraPerRow;
      } else {
        final yDelta = math.min(row.idealHeight(rect.height) - row.minHeight(rect.height), yExtra);
        yExtra -= yDelta;
        height = row.minHeight(rect.height) + yDelta;
      }

      final xExtraPerItem = math.max(0.0, (rect.width - row.idealWidth(rect.width)) / row.length);
      var xExtra = xExtraPerItem > 0.0 ? 0.0 : rect.width - row.minWidth(rect.width);

      var c = 0;
      for (final state in row) {
        double width;
        if (xExtraPerItem > 0.0) {
          width = state.idealWidth(rect.width) + xExtraPerItem;
        } else {
          final xDelta =
              math.min(state.idealWidth(rect.width) - state.minWidth(rect.width), xExtra);
          xExtra -= xDelta;
          width = state.minWidth(rect.width) + xDelta;
        }

        // Special case for phone sized screens with 2 views in portrait:
        // Reduce the top view height and increase the bottom view height so
        // with the bottom sheet open they have the same visible height.
        // if (numViewsLimited && length == 2 && row.length == 1 && maxedView == null) {
        //   final heightAdjust = (TecScaffoldWrapper.navigationBarPadding < 15.0) ? 31.0 : 41.0;
        //   height += (r == 0) ? -heightAdjust : heightAdjust;
        // }

        final isMaxed = maxedView?.uid == state.uid;
        final isVisible = isMaxed || maxedView == null;
        final vRect = (isVisible || prevBuildMaxedViewUid == 0) && !isMaxed
            ? Rect.fromLTWH(x, y, width, height)
            : rect;
        rects.add(ViewRect(uid: state.uid, isVisible: isVisible, row: r, column: c, rect: vRect));
        viewStates.add(state);

        c++;
        x += width;
      }

      r++;
      y += height;
    }

    // If there are any `overflowViews`, add a ViewRect to `rects` for each.
    if (overflowViews?.isNotEmpty ?? false) {
      var c = 0;
      for (final state in overflowViews) {
        // If the view with keyboard focus didn't fit on the screen, auto-maximize it.
        if (viewWithKeyboardFocus?.uid == state.uid) {
          assert(maxedView == null);
          maxedView = state;

          // Update all existing rects, now that a view is maximized.
          for (var i = 0; i < rects.length; i++) {
            rects[i] = rects[i].copyWith(isVisible: false, rect: rect);
          }
        }

        final isVisible = maxedView?.uid == state.uid;
        rects.add(ViewRect(uid: state.uid, isVisible: isVisible, row: r, column: c, rect: rect));
        viewStates.add(state);
        c++;
      }
    }

    // Create the list of widgets, one for each ViewRect in `rects`.
    var widgets = <Widget>[];
    final floatingTitles = <Widget>[];

    // The maximized view widget, if there is one, must get added to the `widgets` list last.
    Widget maxedViewWidget;
    Widget maxedFloatingTitleWidget;

    final hasOrHadMaxedView = (maxedView != null || prevBuildMaxedViewUid != 0);

    // ignore: close_sinks
    final vmBloc = context.viewManager;

    for (var i = 0; i < rects.length; i++) {
      final vr = rects[i];
      final state = viewStates[i];

      final isMaxed = maxedView?.uid == vr.uid;
      final colCount = itemsInRow(vr.row);
      final viewSize = Size(
        vr.rect.width - _totalPaddingSize(vr.column, colCount, isMaxed: isMaxed),
        vr.rect.height - _totalPaddingSize(vr.row, rowCount, isMaxed: isMaxed),
      );

      final mvs = ManagedViewState(
          constraints, state, viewSize, i, vr.row, vr.column, rowCount, colCount, isMaxed);

      final isVisible = (vr.isVisible || (vr.row < rowCount && maxedView != null));
      final isOrWasMaxed = (isMaxed || (maxedView == null && prevBuildMaxedViewUid == vr.uid));
      final animate = vr.isVisible && (!hasOrHadMaxedView || isOrWasMaxed);

      vmBloc._blocs[state.uid] ??= ViewManager.shared._createViewDataBloc(context, state);

      final widget = AnimatedPositioned(
        // We need a key so when views are removed or reordered the element tree stays in sync.
        key: ValueKey(vr.uid),
        duration: (animate ? animationDuration : null) ?? Duration.zero,
        curve: _viewResizeAnimationCurve,
        left: vr.rect.left,
        top: vr.rect.top,
        width: vr.rect.width,
        height: vr.rect.height,
        child: Opacity(
          opacity: isVisible ? 1 : 0,
          child: BlocProvider(
            create: (context) => ManagedViewBloc(mvs),
            child: _ManagedViewNavigator(mvs),
          ),
        ),
      );

      Widget floatingTitle;
      if (floatingTitleHeight > 0) {
        final isTopRight = vr.row == 0 && vr.column == itemsInRow(vr.row) - 1;
        final sideInset = floatingTitleHeight * 1.25;
        final size = Size(vr.rect.width - (isTopRight ? sideInset * 2 : 0.0), floatingTitleHeight);
        floatingTitle = AnimatedPositioned(
          key: ValueKey(-vr.uid),
          duration: (animate ? animationDuration : null) ?? Duration.zero,
          curve: _viewResizeAnimationCurve,
          left: vr.rect.left + (isTopRight ? sideInset : 0.0),
          top: vr.rect.top - (floatingTitleHeight / 2.0),
          width: size.width,
          height: size.height,
          child: Opacity(
            opacity: isVisible ? 1 : 0,
            child: MediaQuery(
              data: floatingTitleMQData,
              child: ViewManager.shared._buildFloatingTitle(context, state, size),
            ),
          ),
        );
      }

      if (isOrWasMaxed) {
        // The maximized view widget, if there is one, must get added to the `widgets` list last.
        maxedViewWidget = widget;
        maxedFloatingTitleWidget = floatingTitle;
      } else {
        widgets.add(widget);
        if (floatingTitle != null && vr.isVisible) floatingTitles.add(floatingTitle);
      }
    }

    // Reverse the widget list because Stack children are ordered bottom to top.
    widgets = widgets.reversed.toList()..addAll(floatingTitles.reversed);

    // This adds a translucent barrier over the non-maximized views.
    // widgets.add(
    //   Positioned(
    //     key: const ValueKey('barrier'),
    //     left: rect.left,
    //     top: rect.top,
    //     width: rect.width,
    //     height: rect.height,
    //     child: AnimatedOpacity(
    //       opacity: maxedView == null ? 0 : 0.25,
    //       duration: animationDuration ?? Duration.zero,
    //       curve: _viewResizeAnimationCurve,
    //       child: IgnorePointer(child: Container(color: Colors.black)),
    //     ),
    //   ),
    // );

    // The maximized view widget, if there is one, must get added to the `widgets` list last.
    if (maxedViewWidget != null) widgets.add(maxedViewWidget);
    if (maxedFloatingTitleWidget != null) widgets.add(maxedFloatingTitleWidget);

    if (mainMenuButtonBuilder != null) {
      final fabWidth = floatingTitleHeight;
      const fabPadding = 8.0;
      widgets.add(
        AnimatedPositioned(
          key: const ValueKey('fab'),
          duration: animationDuration ?? Duration.zero,
          curve: _viewResizeAnimationCurve,
          left: rect.width - fabWidth - fabPadding,
          top: 0.0,
          width: fabWidth,
          height: fabWidth,
          child: mainMenuButtonBuilder(context),
        ),
      );
    }

    return widgets;
  }
}

///
/// List extensions.
///
extension _ExtOnList on List {
  bool isValidIndex(num i) => i != null && i >= 0 && i < length;

  void move({@required int from, @required int to}) {
    assert(isValidIndex(from) && isValidIndex(to));
    final dynamic temp = this[from];
    if (from < to) {
      for (var i = from; i < to;) {
        this[i] = this[++i];
      }
      this[to] = temp;
    } else if (from > to) {
      for (var i = from; i > to;) {
        this[i] = this[--i];
      }
      this[to] = temp;
    }
  }
}

/// Given the position of a view in a row or column, and the total number of rows or columns,
/// returns the total padding size.
double _totalPaddingSize(int pos, int count, {@required bool isMaxed}) =>
    !_showViewPadding || isMaxed || count == 1
        ? 0.0
        : pos == 0 || pos == count - 1
            ? _viewPaddingSize
            : _viewPaddingSize + _viewPaddingSize;

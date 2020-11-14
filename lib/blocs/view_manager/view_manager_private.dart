part of 'view_manager_bloc.dart';

const bool _showViewPadding = true;
const _viewPaddingSize = .5;
const _viewPaddingColorLight = Color(0xffdddddd);
const _viewPaddingColorDark = Color(0xff222222);
const _viewResizeAnimationDuration = Duration(milliseconds: 300);

///
/// Stack of managed views.
///
class _VMViewStack extends StatefulWidget {
  final BoxConstraints constraints;
  final ViewManagerState vmState;

  const _VMViewStack({Key key, this.constraints, this.vmState}) : super(key: key);

  @override
  _VMViewStackState createState() => _VMViewStackState();
}

class _VMViewStackState extends State<_VMViewStack> {
  @override
  Widget build(BuildContext context) {
    final portraitHeight = math.max(widget.constraints.maxWidth, widget.constraints.maxHeight);
    final portraitWidth = math.min(widget.constraints.maxWidth, widget.constraints.maxHeight);

    final bloc = context.viewManager;
    assert(bloc != null);

    if (portraitHeight < 950.0 && portraitWidth < 500) {
      // This is a phone or small app window, so only allow 2 views.
      _minSize = math.max(
          ((math.max(widget.constraints.maxWidth, widget.constraints.maxHeight)) / 2.0)
              .floorToDouble(),
          244);
      bloc?._numViewsLimited = true;
    } else {
      // This is a larger window or tablet.
      _minSize = 300;
      bloc?._numViewsLimited = false;
    }

    final sizeChanged = ((bloc?._size ?? Size.zero) != widget.constraints.biggest);
    if (sizeChanged) tec.dmPrint('ViewManager size changed to ${widget.constraints.biggest}');

    bloc?._size = widget.constraints.biggest;

    final wasVisibleTextSelected = (bloc?.visibleViewsWithSelections?.isNotEmpty ?? false);

    // Build and update the rows, which updates `bloc._rows`, `._overflow`, and `._isFull`.
    final countOfOnScreenViews = bloc?._rows?.totalItems ?? 0;
    _buildRows(bloc, _Size.ideal, widget.vmState, widget.constraints)..balance(widget.constraints);
    final countOfOnScreenViewsChanged = (countOfOnScreenViews != (bloc?._rows?.totalItems ?? 0));

    // Is there a maximized view?
    var maximizedView = widget.vmState.views
        .firstWhere((e) => e.uid == widget.vmState.maximizedViewUid, orElse: () => null);

    // tec.dmPrint('_VMViewStack build, maximizedView: ${maximizedView?.uid ?? 'none'}');

    // Is there a view with keyboard focus?
    var viewWithKeyboardFocus = widget.vmState.views
        .firstWhere((e) => e.uid == bloc?._viewWithKeyboardFocus, orElse: () => null);
    if (viewWithKeyboardFocus != null && maximizedView != null) {
      maximizedView = viewWithKeyboardFocus;
      viewWithKeyboardFocus = null;
    }

    final thisBuildHasMaxedView = (maximizedView != null);
    final lastBuildHadMaxedView = bloc?._lastBuildHadMaxedView ?? thisBuildHasMaxedView;

    // Build the view widgets.
    final viewRects = <ViewRect>[];
    final children = bloc?._rows?.toViewWidgetList(
      widget.constraints,
      maximizedView,
      viewWithKeyboardFocus,
      bloc?._overflow,
      viewRects,
      sizeChanged || countOfOnScreenViewsChanged || lastBuildHadMaxedView != thisBuildHasMaxedView
          ? _viewResizeAnimationDuration
          : null,
      numViewsLimited: bloc?.numViewsLimited ?? true,
      lastBuildHadMaxedView: lastBuildHadMaxedView,
    );
    bloc?._viewRects = viewRects;
    bloc?._lastBuildHadMaxedView = thisBuildHasMaxedView;

    // If this build has a maxed view, but the last one didn't, rebuild again after the
    // view resize animation finishes -- because, for a nicer and smoother maximize
    // animation, we only animate the view that is maximized, but after the animation is
    // finished, we still want to update the size of all the other views, so that if they
    // are switched to, they are already full screen.)
    if (thisBuildHasMaxedView && !lastBuildHadMaxedView) {
      Future.delayed(_viewResizeAnimationDuration, () => setState(() {}));
    }

    // If the state of visible selected text changed, call _updateSelectionBloc after the build.
    final isVisibleTextSelected = (bloc?.visibleViewsWithSelections?.isNotEmpty ?? false);
    if (wasVisibleTextSelected != isVisibleTextSelected) {
      WidgetsBinding.instance
          .addPostFrameCallback((timeStamp) => bloc?._updateSelectionBloc(context));
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
                ? EdgeInsets.zero
                : EdgeInsets.only(
                    left: s.col == 0 ? 0 : _viewPaddingSize,
                    right: s.col == s.colCount - 1 ? 0 : _viewPaddingSize,
                    top: s.row == 0 ? 0 : _viewPaddingSize,
                    bottom: s.row == s.rowCount - 1 ? 0 : _viewPaddingSize,
                  ),
            child: _navigator(),
          );
  }
}

///
/// Size options, `minimum` or `ideal`.
///
enum _Size { min, ideal }

///
/// Builds the rows of views.
///
List<List<ViewState>> _buildRows(
  ViewManagerBloc bloc,
  _Size size,
  ViewManagerState state,
  BoxConstraints constraints,
) {
  final rows = <List<ViewState>>[];
  var isFull = false;
  for (final viewState in state.views) {
    // Add another row?
    if (!isFull &&
        (rows.isEmpty ||
            rows.last.width(constraints, size) + viewState.width(constraints, size) >
                constraints.maxWidth)) {
      // If another row won't fit, set `isFull` to true.
      if (rows.isNotEmpty &&
          rows.height(constraints, size) + viewState.height(constraints, size) >
              constraints.maxHeight) {
        isFull = true;
      }
      rows.add(<ViewState>[]);
    }
    rows.last.add(viewState);
  }

  // If `isFull`, the last row is the row of off screen views (i.e. overflow).
  bloc?._overflow = isFull ? rows.removeLast() : [];
  bloc?._rows = rows;
  bloc?._isFull = isFull ||
      (rows.isNotEmpty &&
          rows.last.width(constraints, size) + _defaultMinWidth(constraints) >
              constraints.maxWidth &&
          rows.height(constraints, size) + _defaultMinHeight(constraints) > constraints.maxHeight);

  // tec.dmPrint('ViewManagerBloc.isFull == ${bloc?.isFull}');

  return rows;
}

const _iPhoneSEHeight = 568.0;
var _minSize = (_iPhoneSEHeight - 20.0) / 2; // 274

const BoxConstraints _defaultConstraints = BoxConstraints(maxWidth: 320, maxHeight: 480);

///
/// Returns the minimum width for a view that is never less than _minSize,
/// otherwise it is the width that will fit at least three columns, or more
/// if each column has a width of at least 400.
///
double _defaultMinWidth(BoxConstraints constraints) => math.max(
    // Make sure each column's width is not less than _minSize.
    _minSize,
    math.min(
      // Allow more than three columns if each column's width is >= 400.0.
      400.0,
      // The maximum width that will allow three columns.
      ((constraints ?? _defaultConstraints).maxWidth / 3.0).floor().toDouble(),
    ));

///
/// Returns the minimum height for a view that is never less than _minSize and
/// never greater than the height that allows for more than three rows.
///
double _defaultMinHeight(BoxConstraints constraints) => math.max(
      // Make sure each row's height is not less than _minSize.
      _minSize,
      // The maximum height that will allow three rows.
      ((constraints ?? _defaultConstraints).maxHeight / 3.0).floor().toDouble(),
    );

///
/// ViewState extensions.
///
extension _ExtOnViewState on ViewState {
  double minWidth(BoxConstraints c) => _defaultMinWidth(c);
  double minHeight(BoxConstraints c) => _defaultMinHeight(c);
  double idealWidth(BoxConstraints c) => math.max(preferredWidth ?? 0, minWidth(c));
  double idealHeight(BoxConstraints c) => math.max(preferredHeight ?? 0, minHeight(c));
  double width(BoxConstraints c, _Size s) => s == _Size.min ? minWidth(c) : idealWidth(c);
  double height(BoxConstraints c, _Size s) => s == _Size.min ? minHeight(c) : idealHeight(c);
}

///
/// List<ViewState> extensions.
///
extension _ExtOnListOfViewState on List<ViewState> {
  double minWidth(BoxConstraints c) => fold(0.0, (t, el) => t + el.minWidth(c));
  double minHeight(BoxConstraints c) => fold(0.0, (t, el) => math.max(t, el.minHeight(c)));
  double idealWidth(BoxConstraints c) => fold(0.0, (t, el) => t + el.idealWidth(c));
  double idealHeight(BoxConstraints c) => fold(0.0, (t, el) => math.max(t, el.idealHeight(c)));
  double width(BoxConstraints c, _Size s) => s == _Size.min ? minWidth(c) : idealWidth(c);
  double height(BoxConstraints c, _Size s) => s == _Size.min ? minHeight(c) : idealHeight(c);
  String toDebugString() => '[${map<int>((e) => e.uid).join(', ')}]';
}

// ignore_for_file: unused_element

///
/// List<List<ViewState>> extensions
///
extension _ExtOnListOfListOfViewState on List<List<ViewState>> {
  double minHeight(BoxConstraints c) => fold(0.0, (t, el) => t + el.minHeight(c));
  double idealHeight(BoxConstraints c) => fold(0.0, (t, el) => t + el.idealHeight(c));
  double height(BoxConstraints c, _Size s) => s == _Size.min ? minHeight(c) : idealHeight(c);
  int get totalItems => fold(0, (t, el) => t + el.length);
  int itemsInRow(int row) => row < 0 || row >= length ? 0 : this[row].length;
  int get rowCount => length;

  ///
  /// Balances rows of items based on the ideal width of each item.
  ///
  void balance(BoxConstraints constraints) {
    // Balance from the bottom up.
    for (var i = length - 2; i >= 0; i--) {
      while (_balanceRow(i, constraints)) {
        // Row `i` changed, so we need to rebalance the rows after it.
        // Rebalance from row `i + 1` down, until there a no changes.
        var changed = false;
        for (var j = i + 1; j < length - 1; j++) {
          if (_balanceRow(j, constraints)) {
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
  bool _balanceRow(int i, BoxConstraints constraints) {
    assert(i != null && i >= 0 && i + 1 < length);
    if (i + 1 >= length) return false;

    final row1 = this[i];
    final row2 = this[i + 1];
    var changed = false;

    // Keep moving the last item in row `i` to the next row until they are in balance.
    while (row1.length > 1) {
      if (row2.idealWidth(constraints) + row1.last.idealWidth(constraints) <=
          row1.idealWidth(constraints)) {
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
  List<Widget> toViewWidgetList(
    BoxConstraints constraints,
    ViewState maximizedView,
    ViewState viewWithKeyboardFocus,
    List<ViewState> overflowViews,
    List<ViewRect> rects,
    Duration animationDuration, {
    bool numViewsLimited = false,
    bool lastBuildHadMaxedView = true,
  }) {
    // Cannot have both a `maximizedView` and a `viewWithKeyboardFocus`.
    assert(maximizedView == null || viewWithKeyboardFocus == null);

    // The `rects` list must start out empty.
    assert(rects != null && rects.isEmpty);

    // The Rect for maximized views.
    final maxedRect = Rect.fromLTWH(0, 0, constraints.maxWidth, constraints.maxHeight);

    // Note, `maxedView` will be set to `viewWithKeyboardFocus` if it needs to be auto-maximized.
    var maxedView = maximizedView;

    final yExtraPerRow = math.max(0.0, (constraints.maxHeight - idealHeight(constraints)) / length);
    var yExtra = yExtraPerRow > 0.0 ? 0.0 : constraints.maxHeight - minHeight(constraints);

    final viewStates = <ViewState>[];

    // Loop through all the rows, adding a ViewRect to `rects` for each ViewState in the row.
    var y = 0.0, r = 0;
    for (final row in this) {
      var x = 0.0;

      double height;
      if (yExtraPerRow > 0.0) {
        height = row.idealHeight(constraints) + yExtraPerRow;
      } else {
        final yDelta = math.min(row.idealHeight(constraints) - row.minHeight(constraints), yExtra);
        yExtra -= yDelta;
        height = row.minHeight(constraints) + yDelta;
      }

      final xExtraPerItem =
          math.max(0.0, (constraints.maxWidth - row.idealWidth(constraints)) / row.length);
      var xExtra = xExtraPerItem > 0.0 ? 0.0 : constraints.maxWidth - row.minWidth(constraints);

      var c = 0;
      for (final state in row) {
        double width;
        if (xExtraPerItem > 0.0) {
          width = state.idealWidth(constraints) + xExtraPerItem;
        } else {
          final xDelta =
              math.min(state.idealWidth(constraints) - state.minWidth(constraints), xExtra);
          xExtra -= xDelta;
          width = state.minWidth(constraints) + xDelta;
        }

        // Special case for phone sized screens with 2 views in portrait:
        // Reduce the top view height and increase the bottom view height so
        // with the bottom sheet open they have the same visible height.
        if (numViewsLimited && length == 2 && row.length == 1 && maxedView == null) {
          final heightAdjust = (TecScaffoldWrapper.navigationBarPadding < 15.0) ? 31.0 : 41.0;
          height += (r == 0) ? -heightAdjust : heightAdjust;
        }

        final isMaxed = maxedView?.uid == state.uid;
        final isVisible = isMaxed || maxedView == null;
        final rect = (isVisible || !lastBuildHadMaxedView) && !isMaxed
            ? Rect.fromLTWH(x, y, width, height)
            : maxedRect;
        rects.add(ViewRect(uid: state.uid, isVisible: isVisible, row: r, column: c, rect: rect));
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
            rects[i] = rects[i].copyWith(isVisible: false, rect: maxedRect);
          }
        }

        final isVisible = maxedView?.uid == state.uid;
        rects.add(
            ViewRect(uid: state.uid, isVisible: isVisible, row: r, column: c, rect: maxedRect));
        viewStates.add(state);
        c++;
      }
    }

    // Create the list of widgets, one for each ViewRect in `rects`.
    var widgets = <Widget>[];

    // The maximized view widget, if there is one, must get added to the `widgets` list last.
    Widget maxedViewWidget;

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

      final widget = AnimatedPositioned(
        // We need a key so when views are removed or reordered the element tree stays in sync.
        key: ValueKey(vr.uid),
        duration: (vr.isVisible ? animationDuration : null) ?? Duration.zero,
        left: vr.rect.left,
        top: vr.rect.top,
        width: vr.rect.width,
        height: vr.rect.height,
        // child: AnimatedOpacity(
        //   opacity: vr.isVisible ? 1 : 0,
        //   duration: const Duration(milliseconds: 800),
        //   child: IgnorePointer(
        //     ignoring: !vr.isVisible,
        child: BlocProvider(
          create: (context) => ManagedViewBloc(mvs),
          child: _ManagedViewNavigator(mvs),
        ),
        //   ),
        // ),
      );

      if (isMaxed) {
        // The maximized view widget, if there is one, must get added to the `widgets` list last.
        maxedViewWidget = widget;
      } else {
        widgets.add(widget);
      }
    }

    // Reverse the widget list because Stack children are ordered bottom to top.
    widgets = widgets.reversed.toList();

    // The maximized view widget, if there is one, must get added to the `widgets` list last.
    if (maxedViewWidget != null) widgets.add(maxedViewWidget);

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

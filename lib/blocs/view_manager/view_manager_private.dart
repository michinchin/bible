part of 'view_manager_bloc.dart';

const bool _showViewPadding = true;
const _viewPaddingSize = .5;
const _viewPaddingColorLight = Color(0xffdddddd);
const _viewPaddingColorDark = Color(0xff222222);

///
/// Stack of managed views.
///
class _VMViewStack extends StatelessWidget {
  final BoxConstraints constraints;
  final ViewManagerState vmState;

  const _VMViewStack({Key key, this.constraints, this.vmState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If the maxWidth is less then the bottom sheet maxWidth, subtract the sheet
    // height from maxHeight so views have equal visible area, i.e. so the views
    // don't extend under the bottom sheet.
    const bottomSheetHeight = 0.0; // 56.0; // + (MediaQuery.of(context)?.padding?.bottom ?? 0.0);
    final adjustedConstraints = constraints.maxWidth <= 460.0
        ? constraints.copyWith(maxHeight: constraints.maxHeight - bottomSheetHeight)
        : constraints;

    final portraitHeight = math.max(constraints.maxWidth, constraints.maxHeight);
    final portraitWidth = math.min(constraints.maxWidth, constraints.maxHeight);

    var numViewsLimited = false;

    if (portraitHeight < 950.0 && portraitWidth < 500) {
      // This is a phone or small app window, so only allow 2 views.
      _minSize = math.max(
          ((math.max(adjustedConstraints.maxWidth, adjustedConstraints.maxHeight)) / 2.0)
              .floorToDouble(),
          244);
      numViewsLimited = true;
    } else {
      // This is a larger window or tablet.
      _minSize = 300;
    }

    final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
    assert(bloc != null);

    bloc?._size = Size(adjustedConstraints.maxWidth, adjustedConstraints.maxHeight);

    final wasVisibleTextSelected = (bloc?.visibleViewsWithSelections?.isNotEmpty ?? false);

    // Build and update the rows.
    final rows = _buildRows(bloc, _Size.ideal, vmState, adjustedConstraints)
      ..balance(adjustedConstraints);
    bloc?._rows = rows;

    // Is there a maximized view?
    var maximizedView =
        vmState.views.firstWhere((e) => e.uid == vmState.maximizedViewUid, orElse: () => null);

    // tec.dmPrint('_VMViewStack build, maximizedView: ${maximizedView?.uid ?? 'none'}');

    // Is there a view with keyboard focus?
    var viewWithKeyboardFocus =
        vmState.views.firstWhere((e) => e.uid == bloc?._viewWithKeyboardFocus, orElse: () => null);
    if (viewWithKeyboardFocus != null && maximizedView != null) {
      maximizedView = viewWithKeyboardFocus;
      viewWithKeyboardFocus = null;
    }

    // Build children and save the view rects.
    final viewRects = <ViewRect>[];
    final children = rows.toViewList(
        adjustedConstraints, maximizedView, viewWithKeyboardFocus, viewRects,
        numViewsLimited: numViewsLimited);
    bloc?._viewRects = viewRects;

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
    context.bloc<ManagedViewBloc>().add(state);
  }

  Widget _routeBuilder(BuildContext context) => BlocBuilder<ManagedViewBloc, ManagedViewState>(
      builder: (context, state) => _ManagedViewScaffold(state));

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

    return !_showViewPadding || s.isMaximized || (s.rowCount == 1 && s.colCount == 1)
        ? _navigator()
        : Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? _viewPaddingColorDark
                : _viewPaddingColorLight,
            padding: EdgeInsets.only(
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
/// Scaffold for a managed view.
///
class _ManagedViewScaffold extends StatelessWidget {
  final ManagedViewState state;

  const _ManagedViewScaffold(this.state, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // tec.dmPrint('_ManagedViewScaffold building ${state.viewState.uid} with index ${state.viewIndex}');
    return ViewManager.shared._buildScaffold(context, state.viewState, state.viewSize);
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
    if (rows.isEmpty ||
        rows.last.width(constraints, size) + viewState.width(constraints, size) >
            constraints.maxWidth) {
      // If another row won't fit, break out of the for loop.
      if (rows.isNotEmpty &&
          rows.height(constraints, size) + viewState.height(constraints, size) >
              constraints.maxHeight) {
        isFull = true;
        break; // ---------------------------->
      }
      rows.add(<ViewState>[]);
    }
    rows.last.add(viewState);
  }

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

  Widget toWidget({
    @required BoxConstraints constraints,
    @required Rect rect,
    @required int row,
    @required int col,
    @required int rowCount,
    @required int colCount,
    @required int index,
    @required bool isMaximized,
  }) {
    /// Given the position of a view in a row or column, and the total number of rows or columns,
    /// returns the total padding size.
    double _totalPaddingSize(int pos, int count) => !_showViewPadding || isMaximized || count == 1
        ? 0.0
        : pos == 0 || pos == count - 1
            ? _viewPaddingSize
            : _viewPaddingSize + _viewPaddingSize;

    final viewSize = Size(
      rect.width - _totalPaddingSize(col, colCount),
      rect.height - _totalPaddingSize(row, rowCount),
    );

    final mvs = ManagedViewState(
        constraints, this, viewSize, index, row, col, rowCount, colCount, isMaximized);

    return AnimatedPositionedDirectional(
      // We need a key so when views are removed or reordered the element tree stays in sync.
      key: ValueKey(uid),
      duration: const Duration(milliseconds: 300),
      start: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      // child: _ManagedViewScaffold(mvs),
      child: BlocProvider(
        create: (context) => ManagedViewBloc(mvs),
        child: _ManagedViewNavigator(mvs),
      ),
    );
  }
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
  List<Widget> toViewList(
    BoxConstraints constraints,
    ViewState maximizedView,
    ViewState viewWithKeyboardFocus,
    List<ViewRect> rects,
    { bool numViewsLimited = false }
  ) {
    // Cannot have both a maximizedView and a viewWithKeyboardFocus.
    assert(maximizedView == null || viewWithKeyboardFocus == null);

    var views = <Widget>[];

    var i = 0;
    var y = 0.0;

    final yExtraPerRow = math.max(0.0, (constraints.maxHeight - idealHeight(constraints)) / length);
    var yExtra = yExtraPerRow > 0.0 ? 0.0 : constraints.maxHeight - minHeight(constraints);

    final noViewIsMaximized = (maximizedView == null);
    Widget maximizedViewWidget;

    var viewWithKeyboardFocusIsVisible = false;

    // Local func that adds to [rects] and [views].
    void _addViewWithIndex(
      int index,
      ViewState state,
      int row,
      int col,
      int colCount,
      double x,
      double y,
      double width,
      double height, {
      bool isVisible = true,
      bool isMaximized = false,
    }) {
      final rect = Rect.fromLTWH(isMaximized ? 0.0 : x, isMaximized ? 0.0 : y,
          isMaximized ? constraints.maxWidth : width, isMaximized ? constraints.maxHeight : height);

      rects.add(ViewRect(uid: state.uid, isVisible: isVisible, row: row, column: col, rect: rect));

      final widget = state.toWidget(
        constraints: constraints,
        rect: rect,
        row: row,
        col: col,
        rowCount: length,
        colCount: colCount,
        index: index,
        isMaximized: isMaximized,
      );
      if (isMaximized) {
        maximizedViewWidget = widget;
      } else {
        views.add(widget);
      }
    }

    var r = 0;
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

        if (viewWithKeyboardFocus?.uid == state.uid) {
          viewWithKeyboardFocusIsVisible = true;
        }

        final isMaximized = (maximizedView?.uid == state.uid);

        // special case - phone/small app view with 2 windows in portrait
        // reducing space from the top window so both windows have save visible height
        if (c == 0 &&
            length == 2 &&
            numViewsLimited &&
            noViewIsMaximized &&
            constraints.maxHeight > constraints.maxWidth) {
          final heightAdjust = (TecScaffoldWrapper.navigationBarPadding < 15.0) ? 31.0 : 41.0;
          height += (r == 0) ? -heightAdjust : heightAdjust;
        }

        _addViewWithIndex(i, state, r, c, row.length, x, y, width, height,
            isVisible: noViewIsMaximized || isMaximized, isMaximized: isMaximized);

        i++;
        c++;
        x += width;
      }

      r++;
      y += height;
    }

    // Reverse the view list so first views are on top of the stack.
    views = views.reversed.toList();

    var maxedView = maximizedView;

    // If the view with keyboard focus isn't visible, auto-maximize it!
    if (viewWithKeyboardFocus != null && !viewWithKeyboardFocusIsVisible) {
      assert(maxedView == null);
      maxedView = viewWithKeyboardFocus;
    }

    // It is possible that the maximized view doesn't fit on the screen when not maximized...
    if (maxedView != null && maximizedViewWidget == null) {
      _addViewWithIndex(i, maxedView, 0, 0, 1, 0, 0, 0, 0, isMaximized: true);
    }

    // The maximized view needs to be the last view in the stack so it is always on top.
    if (maxedView != null) views.add(maximizedViewWidget);

    return views;
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

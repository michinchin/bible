part of 'view_manager_bloc.dart';

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
    if (portraitHeight < 950.0 && portraitWidth < 500) {
      // This is a phone or small app window, so only allow 2 views.
      _minSize = math.max(
          ((math.max(adjustedConstraints.maxWidth, adjustedConstraints.maxHeight)) / 2.0)
              .floorToDouble(),
          244);
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
    final children =
        rows.toViewList(adjustedConstraints, maximizedView, viewWithKeyboardFocus, viewRects);
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
  ) = _ManagedViewState;
}

class ManagedViewBloc extends Bloc<ManagedViewState, ManagedViewState> {
  ManagedViewBloc(ManagedViewState initialState) : super(initialState);

  @override
  Stream<ManagedViewState> mapEventToState(ManagedViewState event) async* {
    yield ManagedViewState(
        event.parentConstraints, event.viewState, event.viewSize, event.viewIndex);
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
    return ClipRect(
      child: Navigator(
        onGenerateRoute: (settings) => TecPageRoute<dynamic>(
          settings: settings,
          builder: _routeBuilder,
        ),
      ),
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
    @required double x,
    @required double y,
    @required double width,
    @required double height,
    @required int index,
  }) {
    final mvs = ManagedViewState(constraints, this, Size(width, height), index);
    return AnimatedPositionedDirectional(
      // We need a key so when views are removed or reordered the element tree stays in sync.
      key: ValueKey(uid),
      duration: const Duration(milliseconds: 300),
      start: x,
      top: y,
      width: width,
      height: height,
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
    void addViewWithIndex(
        int index, ViewState state, int r, int c, double x, double y, double width, double height,
        {bool isVisible = true, bool isMaximized = false}) {
      final _x = isMaximized ? 0.0 : x;
      final _y = isMaximized ? 0.0 : y;
      final _width = isMaximized ? constraints.maxWidth : width;
      final _height = isMaximized ? constraints.maxHeight : height;

      rects.add(ViewRect(
          uid: state.uid,
          isVisible: isVisible,
          row: r,
          column: c,
          rect: Rect.fromLTWH(_x, _y, _width, _height)));

      final widget = state.toWidget(
          constraints: constraints, x: _x, y: _y, width: _width, height: _height, index: index);
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

        addViewWithIndex(i, state, r, c, x, y, width, height,
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
      addViewWithIndex(i, maxedView, 0, 0, 0, 0, 0, 0, isMaximized: true);
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

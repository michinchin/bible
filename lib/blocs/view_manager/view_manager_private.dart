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
    double height, checkHeight;

    // at this point orientation variable is correct, however, the size
    // may not have been adjusted yet..
    height = math.max(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      checkHeight = 1024.0;
    }
    else {
      checkHeight = 768.0;
    }

    if (height < checkHeight) {
      // this is a phone...
      _minSize = (height - 44) / 2;
    }
    else {
      // old default...
      _minSize = (_iPhoneSEHeight - 44.0) / 2;
    }


    final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
    assert(bloc != null);

    final wasVisibleTextSelected = (bloc?.visibleViewsWithSelections?.isNotEmpty ?? false);

    // Build and update the rows.
    final rows = _buildRows(bloc, _Size.ideal, vmState, constraints)..balance(constraints);
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
    final children = rows.toViewList(constraints, maximizedView, viewWithKeyboardFocus, viewRects);
    bloc?._viewRects = viewRects;

    // If the state of visible selected text changed, call _updateSelectionBloc after the build.
    final isVisibleTextSelected = (bloc?.visibleViewsWithSelections?.isNotEmpty ?? false);
    if (wasVisibleTextSelected != isVisibleTextSelected) {
      WidgetsBinding.instance
          .addPostFrameCallback((timeStamp) => bloc?._updateSelectionBloc(context));
    }

    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: appBarThemeWithContext(context),
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
  final ManagedViewState _initialState;
  ManagedViewBloc(ManagedViewState initialState) : _initialState = initialState;

  @override
  ManagedViewState get initialState => _initialState;

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
      builder: (_, state) => _ManagedViewScaffold(state));

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
          rows.last.width(constraints, size) + _defaultViewState.width(constraints, size) >
              constraints.maxWidth &&
          rows.height(constraints, size) + _defaultViewState.height(constraints, size) >
              constraints.maxHeight);

  // tec.dmPrint('ViewManagerBloc.isFull == ${bloc?.isFull}');

  return rows;
}

final _defaultViewState = ViewState(uid: 0, type: 'default');

///
/// ViewState extensions.
///
extension _ExtOnViewState on ViewState {
  double minWidth(BoxConstraints c) => ViewManager.shared._minWidthForType(type, c);
  double minHeight(BoxConstraints c) => ViewManager.shared._minHeightForType(type, c);
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
      duration: const Duration(milliseconds: 200),
      start: x,
      top: y,
      width: width,
      height: height,
      // child: _ManagedViewScaffold(mvs),
      child: BlocProvider(
        create: (_) => ManagedViewBloc(mvs),
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

    final views = <Widget>[];

    var i = 0;
    var y = 0.0;

    final yExtraPerRow = math.max(0.0, (constraints.maxHeight - idealHeight(constraints)) / length);
    var yExtra = yExtraPerRow > 0.0 ? 0.0 : constraints.maxHeight - minHeight(constraints);

    final noViewIsMaximized = (maximizedView == null);
    Widget maximizedViewWidget;

    var viewWithKeyboardFocusIsVisible = false;

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

        final thisViewIsMaximized = (maximizedView?.uid == state.uid);

        if (viewWithKeyboardFocus?.uid == state.uid) {
          viewWithKeyboardFocusIsVisible = true;
        }

        // This is always created with the view's no-maximized rect. Should it be?
        rects.add(ViewRect(
            uid: state.uid,
            isVisible: noViewIsMaximized || thisViewIsMaximized,
            row: r,
            column: c,
            rect: Rect.fromLTWH(x, y, width, height)));

        if (thisViewIsMaximized) {
          maximizedViewWidget = state.toWidget(
              constraints: constraints,
              x: 0,
              y: 0,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              index: i);
        } else {
          views.add(state.toWidget(
              constraints: constraints, x: x, y: y, width: width, height: height, index: i));
        }

        i++;
        c++;
        x += width;
      }

      r++;
      y += height;
    }

    var maximizeView = maximizedView;

    // If the view with keyboard focus isn't visible, auto-maximize it!
    if (viewWithKeyboardFocus != null && !viewWithKeyboardFocusIsVisible) {
      assert(maximizeView == null);
      maximizeView = viewWithKeyboardFocus;
    }

    // It is possible that the maximized view doesn't fit on the screen when not maximized...
    if (maximizeView != null && maximizedViewWidget == null) {
      rects.add(ViewRect(
          uid: maximizeView.uid,
          isVisible: true,
          row: 0,
          column: 0,
          rect: Rect.fromLTWH(0, 0, constraints.maxWidth, constraints.maxHeight)));

      maximizedViewWidget = maximizeView.toWidget(
          constraints: constraints,
          x: 0,
          y: 0,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          index: i);
    }

    if (maximizeView != null) views.add(maximizedViewWidget);

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

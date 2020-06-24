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
    final theme = Theme.of(context);
    final barColor = theme.canvasColor;
    // final barColor = theme.appBarTheme.color ?? theme.primaryColor;
    final barTextColor = ThemeData.estimateBrightnessForColor(barColor) == Brightness.light
        ? Colors.grey[700]
        : Colors.white;
    final newAppBarTheme = theme.appBarTheme.copyWith(
      elevation: 0,
      color: barColor,
      actionsIconTheme: IconThemeData(color: barTextColor),
      iconTheme: IconThemeData(color: barTextColor),
      textTheme: theme.copyOfAppBarTextThemeWithColor(barTextColor),
    );

    // tec.dmPrint('_VMViewStackState build()');
    final rows = _buildRows(_Size.ideal, vmState, constraints)..balance(constraints);
    return Theme(
      data: theme.copyWith(
        appBarTheme: newAppBarTheme,
        pageTransitionsTheme: tecPageTransitionsTheme(context),
      ),
      child: Stack(children: rows.toViewList(constraints)),
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
class _ManagedViewScaffold extends StatefulWidget {
  final ManagedViewState state;

  const _ManagedViewScaffold(
    this.state, {
    Key key,
  }) : super(key: key);

  @override
  _ManagedViewScaffoldState createState() => _ManagedViewScaffoldState();
}

class _ManagedViewScaffoldState extends State<_ManagedViewScaffold> {
  Key _bodyKey;

  @override
  void initState() {
    super.initState();
    _bodyKey = ViewManager.shared._makeKey(context, widget.state.viewState);
  }

  @override
  Widget build(BuildContext context) {
    // tec.dmPrint('_ManagedViewScaffold building ${state.viewState.uid} with index ${state.viewIndex}');
    return Scaffold(
      appBar: ManagedViewAppBar(
        appBar: AppBar(
          title: ViewManager.shared
              ._buildViewTitle(context, _bodyKey, widget.state.viewState, widget.state.viewSize),
          leading: widget.state.viewIndex > 0
              ? null
              : IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: 'Main Menu',
                  onPressed: () => showMainMenu(context),
                ),
          actions: ViewManager.shared
              ._buildViewActions(context, _bodyKey, widget.state.viewState, widget.state.viewSize),
        ),
      ),
      body: ViewManager.shared
          ._buildViewBody(context, _bodyKey, widget.state.viewState, widget.state.viewSize),
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
  _Size size,
  ViewManagerState state,
  BoxConstraints constraints,
) {
  final rows = <List<ViewState>>[];
  for (final viewState in state.views) {
    // Add another row?
    if (rows.isEmpty ||
        rows.last.width(constraints, size) + viewState.width(constraints, size) >
            constraints.maxWidth) {
      // If another row won't fit, break out of the for loop.
      if (rows.isNotEmpty &&
          rows.height(constraints, size) + viewState.height(constraints, size) >
              constraints.maxHeight) {
        break; // ---------------------------->
      }
      rows.add(<ViewState>[]);
    }
    rows.last.add(viewState);
  }
  return rows;
}

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
  List<Widget> toViewList(BoxConstraints constraints) {
    final views = <Widget>[];

    var i = 0;
    var y = 0.0;

    final yExtraPerRow = math.max(0.0, (constraints.maxHeight - idealHeight(constraints)) / length);
    var yExtra = yExtraPerRow > 0.0 ? 0.0 : constraints.maxHeight - minHeight(constraints);

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

        final mvs = ManagedViewState(constraints, state, Size(width, height), i);

        views.add(AnimatedPositionedDirectional(
          // We need a key so when views are removed or reordered the element
          // tree stays in sync.
          key: ValueKey(state.uid),
          duration: const Duration(milliseconds: 200),
          start: x,
          top: y,
          width: width,
          height: height,
          child: BlocProvider(
            create: (_) => ManagedViewBloc(mvs),
            child: _ManagedViewNavigator(mvs),
          ),
          // child: _ManagedViewScaffold(mvs),
        ));

        i++;
        x += width;
      }
      y += height;
    }

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
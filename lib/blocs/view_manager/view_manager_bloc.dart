import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../ui/common/common.dart';
import '../../ui/common/tec_page_view.dart';

part 'view_manager_bloc.freezed.dart';
part 'view_manager_bloc.g.dart';

// ignore_for_file: unused_element

const String _key = 'viewManagerState';

///
/// Manages view types.
///
/// Use the [register] function to register a view type. For example:
///
/// ```dart
/// ViewManager.shared.register('MyType', builder: (context, state) => Container());
/// ```
///
class ViewManager {
  static final ViewManager shared = ViewManager();

  final _types = <String, _ViewTypeAPI>{};

  ///
  /// Registers a new view type. For example:
  ///
  /// ```dart
  /// ViewManager.shared.register('MyType', builder: (context, state) => Container());
  /// ```
  ///
  void register(
    String key, {
    @required String title,
    @required BuilderWithViewState builder,
    BuilderWithViewState titleBuilder,
    ActionsBuilderWithViewState actionsBuilder,
    KeyMaker keyMaker,
    ViewSizeFunc minWidth,
    ViewSizeFunc minHeight,
  }) {
    assert(tec.isNotNullOrEmpty(key) && builder != null);
    assert(!_types.containsKey(key));
    _types[key] = _ViewTypeAPI(
      title,
      builder,
      titleBuilder,
      actionsBuilder,
      keyMaker,
      minWidth,
      minHeight,
    );
  }

  List<String> get types => _types.keys.toList();

  String titleForType(String type) => _types[type]?.title;

  Key _makeKey(BuildContext context, ViewState state) =>
      (_types[state.type]?.keyMaker ?? _defaultKeyMaker)(context, state);

  Widget _buildViewBody(BuildContext context, Key bodyKey, ViewState state, Size size) =>
      (_types[state.type]?.builder ?? _defaultBuilder)(context, bodyKey, state, size);

  Widget _buildViewTitle(BuildContext context, Key bodyKey, ViewState state, Size size) =>
      (_types[state.type]?.titleBuilder ?? _defaultTitleBuilder)(context, bodyKey, state, size);

  List<Widget> _buildViewActions(BuildContext context, Key bodyKey, ViewState state, Size size) =>
      (_types[state.type]?.actionsBuilder ?? _defaultActionsBuilder)(context, bodyKey, state, size);

  double _minWidthForType(String type, BoxConstraints constraints) =>
      (_types[type]?.minWidth ?? _defaultMinWidth)(constraints);

  double _minHeightForType(String type, BoxConstraints constraints) =>
      (_types[type]?.minHeight ?? _defaultMinHeight)(constraints);

  Key _defaultKeyMaker(BuildContext context, ViewState state) => null;

  Widget _defaultBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) =>
      Container(key: bodyKey);

  Widget _defaultTitleBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) =>
      Text(state.uid.toString());

  List<Widget> _defaultActionsBuilder(
          BuildContext context, Key bodyKey, ViewState state, Size size) =>
      [
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => context.bloc<ViewManagerBloc>().add(ViewManagerEvent.remove(state.uid)),
        ),
      ];

  // List<Widget> _testActionsForAdjustingSize(
  //     BuildContext context, Key bodyKey, ViewState state, Size size) {
  //   final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
  //   return <Widget>[
  //     IconButton(
  //       icon: const Icon(Icons.border_outer),
  //       onPressed: () {
  //         bloc
  //           ..add(ViewManagerEvent.setWidth(position: widget.state.viewIndex, width: null))
  //           ..add(ViewManagerEvent.setHeight(position: widget.state.viewIndex, height: null));
  //       },
  //     ),
  //     IconButton(
  //       icon: const Icon(Icons.format_textdirection_l_to_r),
  //       onPressed: () {
  //         final idealWidth = widget.state.viewState.idealWidth(widget.state.parentConstraints) ??
  //             ViewManager.shared
  //                 ._minWidthForType(widget.state.viewState.type, widget.state.parentConstraints);
  //         final event =
  //             ViewManagerEvent.setWidth(position: widget.state.viewIndex, width: idealWidth + 20.0);
  //         bloc.add(event);
  //       },
  //     ),
  //     IconButton(
  //       icon: const Icon(Icons.format_line_spacing),
  //       onPressed: () {
  //         final idealHeight = widget.state.viewState.idealHeight(widget.state.parentConstraints) ??
  //             ViewManager.shared
  //                 ._minHeightForType(widget.state.viewState.type, widget.state.parentConstraints);
  //         final event = ViewManagerEvent.setHeight(
  //             position: widget.state.viewIndex, height: idealHeight + 20.0);
  //         bloc.add(event);
  //       },
  //     ),
  //   ];
  // }

  double _defaultMinWidth(BoxConstraints constraints) => math.max(_minSize,
      math.min(_maxMinWidth, ((constraints ?? _defaultConstraints).maxWidth / 3).roundToDouble()));

  double _defaultMinHeight(BoxConstraints constraints) =>
      math.max(_minSize, ((constraints ?? _defaultConstraints).maxHeight / 3).roundToDouble());

  static const BoxConstraints _defaultConstraints = BoxConstraints(maxWidth: 320, maxHeight: 480);
}

const _iPhoneSEHeight = 568.0;
const _minSize = (_iPhoneSEHeight - 20.0) / 2;
const _maxMinWidth = 400.0;

///
/// Signature for a function the creates a key for a given view state.
///
typedef KeyMaker = Key Function(BuildContext context, ViewState state);

///
/// Signature for a function that creates a widget for a given view state.
///
typedef BuilderWithViewState = Widget Function(
    BuildContext context, Key bodyKey, ViewState state, Size size);

///
/// Signature for a function that creates a list of "action" widgets for a given view state.
///
typedef ActionsBuilderWithViewState = List<Widget> Function(
    BuildContext context, Key bodyKey, ViewState state, Size size);

///
/// Signature for a function that creates a widget for a given view state and index.
///
typedef IndexedBuilderWithViewState = Widget Function(
    BuildContext context, ViewState state, Size size, int index);

///
/// Signature for a function that returns a view size value based on constraints.
///
typedef ViewSizeFunc = double Function(BoxConstraints constraints);

///
/// The builder and size functions for a view type.
///
class _ViewTypeAPI {
  final String title;
  final BuilderWithViewState builder;
  final BuilderWithViewState titleBuilder;
  final ActionsBuilderWithViewState actionsBuilder;
  final KeyMaker keyMaker;
  final ViewSizeFunc minWidth;
  final ViewSizeFunc minHeight;

  const _ViewTypeAPI(
    this.title,
    this.builder,
    this.titleBuilder,
    this.actionsBuilder,
    this.keyMaker,
    this.minWidth,
    this.minHeight,
  );
}

///
/// ViewManagerBloc
///
class ViewManagerBloc extends Bloc<ViewManagerEvent, ViewManagerState> {
  final tec.KeyValueStore _kvStore;

  ViewManagerBloc({@required tec.KeyValueStore kvStore})
      : assert(kvStore != null),
        _kvStore = kvStore;

  @override
  ViewManagerState get initialState {
    final jsonStr = _kvStore.getString(_key);
    if (tec.isNotNullOrEmpty(jsonStr)) {
      // tec.dmPrint('loaded ViewManagerState: $jsonStr');
      final json = tec.parseJsonSync(jsonStr);
      if (json != null) return ViewManagerState.fromJson(json);
    }
    return ViewManagerState([], 1);
  }

  @override
  Stream<ViewManagerState> mapEventToState(ViewManagerEvent event) async* {
    final value = event.when(
      add: _add,
      remove: _remove,
      move: _move,
      setWidth: _setWidth,
      setHeight: _setHeight,
      setData: _setData,
    );
    assert(value != null);
    if (value == null) {
      assert(false);
      yield state;
    } else {
      if (value != state) {
        final strValue = tec.toJsonString(value);
        // tec.dmPrint('VM mapEventToState saving state: $strValue');
        await _kvStore.setString(_key, strValue);
      }
      yield value;
    }
  }

  ViewManagerState _add(String type, int position, String data) {
    final nextUid = (state.nextUid ?? 1);
    final viewState = ViewState(uid: nextUid, type: type, data: data);
    final newViews = List.of(state.views); // shallow copy
    // tec.dmPrint('VM add type: $type, uid: $nextUid, position: $position, data: \'$data\'');
    newViews.insert(position ?? newViews.length, viewState);
    return ViewManagerState(newViews, tec.nextIntWithJsSafeWraparound(nextUid, wrapTo: 1));
  }

  ViewManagerState _remove(int uid) {
    final position = state.views.indexWhere((e) => e.uid == uid);
    if (position < 0) return state;
    final newViews = List.of(state.views) // shallow copy
      ..removeAt(position);
    return ViewManagerState(newViews, state.nextUid);
  }

  ViewManagerState _move(int from, int to) {
    if (from == to) return state;
    final newViews = List.of(state.views) // shallow copy
      ..move(from: from, to: to);
    return ViewManagerState(newViews, state.nextUid);
  }

  ViewManagerState _setWidth(int position, double width) {
    assert(state.views.isValidIndex(position));
    final newViews = List.of(state.views); // shallow copy
    newViews[position] = newViews[position].copyWith(preferredWidth: width);
    return ViewManagerState(newViews, state.nextUid);
  }

  ViewManagerState _setHeight(int position, double height) {
    assert(state.views.isValidIndex(position));
    final newViews = List.of(state.views); // shallow copy
    newViews[position] = newViews[position].copyWith(preferredHeight: height);
    return ViewManagerState(newViews, state.nextUid);
  }

  ViewManagerState _setData(int uid, String data) {
    final position = state.views.indexWhere((e) => e.uid == uid);
    if (position < 0) return state;
    final newViews = List.of(state.views); // shallow copy
    newViews[position] = newViews[position].copyWith(data: data);
    return ViewManagerState(newViews, state.nextUid);
  }
}

///
/// ViewManagerEvent
///
@freezed
abstract class ViewManagerEvent with _$ViewManagerEvent {
  const factory ViewManagerEvent.add({@required String type, int position, String data}) = _Add;
  const factory ViewManagerEvent.remove(int uid) = _Remove;
  const factory ViewManagerEvent.move({int fromPosition, int toPosition}) = _Move;
  const factory ViewManagerEvent.setWidth({int position, double width}) = _SetWidth;
  const factory ViewManagerEvent.setHeight({int position, double height}) = _SetHeight;
  const factory ViewManagerEvent.setData({int uid, String data}) = _SetData;
}

///
/// ViewState
///
@freezed
abstract class ViewState with _$ViewState {
  factory ViewState({
    int uid,
    String type,
    double preferredWidth,
    double preferredHeight,
    String data,
  }) = _ViewState;

  /// fromJson
  factory ViewState.fromJson(Map<String, dynamic> json) => _$ViewStateFromJson(json);
}

///
/// ViewManagerState
///
@freezed
abstract class ViewManagerState with _$ViewManagerState {
  factory ViewManagerState(List<ViewState> views, int nextUid) = _Views;

  /// fromJson
  factory ViewManagerState.fromJson(Map<String, dynamic> json) => _$ViewManagerStateFromJson(json);
}

///
/// ViewManagerWidget
///
class ViewManagerWidget extends StatelessWidget {
  final ViewManagerState state;

  const ViewManagerWidget({Key key, this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // tec.dmPrint('ViewManagerWidget build()');
    return LayoutBuilder(
      builder: (context, constraints) => _VMViewStack(
        vmState: state,
        constraints: constraints,
      ),
    );
  }
}

///
/// Reduced height AppBar, so managed views have more space for content.
///
class ManagedViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget appBar;

  const ManagedViewAppBar({Key key, this.appBar}) : super(key: key);

  @override
  Widget build(BuildContext context) => appBar ?? AppBar();

  @override
  Size get preferredSize => _managedViewAppBarPreferredSize;
}

final _managedViewAppBarPreferredSize =
    Size.fromHeight((AppBar().preferredSize.height * 0.75).roundToDouble());

///
/// Signature of the function that is called when the current page is changed.
///
typedef PageableViewOnPageChanged = void Function(BuildContext context, ViewState state, int page);

///
/// View that uses a [TecPageView] for paging.
///
class PageableView extends StatefulWidget {
  final ViewState state;
  final Size size;
  final IndexedBuilderWithViewState pageBuilder;
  final PageableViewOnPageChanged onPageChanged;
  final TecPageController Function() controllerBuilder;

  const PageableView({
    Key key,
    @required this.state,
    @required this.size,
    @required this.pageBuilder,
    this.onPageChanged,
    this.controllerBuilder,
  })  : assert(state != null),
        assert(size != null),
        assert(pageBuilder != null),
        super(key: key);

  @override
  PageableViewState createState() => PageableViewState();
}

class PageableViewState extends State<PageableView> {
  TecPageController _pageController;

  TecPageController get pageController => _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = (widget.controllerBuilder == null ? null : widget.controllerBuilder());
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _pageController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TecPageView(
      pageBuilder: (context, index) =>
          widget.pageBuilder(context, widget.state, widget.size, index),
      controller: _pageController,
      onPageChanged: widget.onPageChanged == null
          ? null
          : (page) => widget.onPageChanged(context, widget.state, page),
    );
  }
}

//
// PRIVATE CLASSES, DATA, AND FUNCTIONS
//

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

    // if (context.bloc<ManagedViewBloc>().state != widget.managedViewState) {
    final state = widget.managedViewState;
    // tec.dmPrint('ManagedViewNavigatorState calling ManagedViewBloc.add for ${state.viewState.uid}');
    context.bloc<ManagedViewBloc>().add(state);
    // }
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
                  onPressed: () {},
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

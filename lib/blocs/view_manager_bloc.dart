import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../ui/common/tec_page_view.dart';

part 'view_manager_bloc.freezed.dart';
part 'view_manager_bloc.g.dart';

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
    ViewSizeFunc minWidth,
    ViewSizeFunc minHeight,
  }) {
    assert(tec.isNotNullOrEmpty(key) && builder != null);
    assert(!_types.containsKey(key));
    _types[key] = _ViewTypeAPI(title, builder, titleBuilder, minWidth, minHeight);
  }

  List<String> get types => _types.keys.toList();

  String titleForType(String type) => _types[type]?.title;

  Widget _buildViewBody(BuildContext context, ViewState state, Size size) =>
      (_types[state.type]?.builder ?? _defaultBuilder)(context, state, size);

  Widget _buildViewTitle(BuildContext context, ViewState state, Size size) =>
      (_types[state.type]?.titleBuilder ?? _defaultTitleBuilder)(context, state, size);

  double _minWidthForType(String type, BoxConstraints constraints) =>
      (_types[type]?.minWidth ?? _defaultMinWidth)(constraints);

  double _minHeightForType(String type, BoxConstraints constraints) =>
      (_types[type]?.minHeight ?? _defaultMinHeight)(constraints);

  Widget _defaultBuilder(BuildContext context, ViewState state, Size size) => Container();

  Widget _defaultTitleBuilder(BuildContext context, ViewState state, Size size) =>
      Text(state.uid.toString());

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
/// Signature for a function that creates a widget for a given view state.
///
typedef BuilderWithViewState = Widget Function(BuildContext context, ViewState state, Size size);

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
  final ViewSizeFunc minWidth;
  final ViewSizeFunc minHeight;

  const _ViewTypeAPI(
    this.title,
    this.builder,
    this.titleBuilder,
    this.minWidth,
    this.minHeight,
  );
}

///
/// Min width for a view, based on type.
///
double _minWidthForType(String type, BoxConstraints constraints) =>
    ViewManager.shared._minWidthForType(type, constraints);

double _minHeightForType(String type, BoxConstraints constraints) =>
    ViewManager.shared._minHeightForType(type, constraints);

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

  ViewManagerState _remove(int position) {
    assert(position != null);
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
  const factory ViewManagerEvent.remove(int position) = _Remove;
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

typedef PageableViewOnPageChanged = void Function(BuildContext context, ViewState state, int page);

///
/// View that uses TecPageView for paging.
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
  _PageableViewState createState() => _PageableViewState();
}

class _PageableViewState extends State<PageableView> {
  TecPageController _pageController;

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
    // tec.dmPrint('_VMViewStackState build()');
    final rows = _buildRows(_Size.ideal, vmState, constraints)..balance(constraints);
    return Stack(children: rows.toViewList(constraints));
  }
}

///
/// Scaffold for a managed view.
///
class _ManagedViewScaffold extends StatelessWidget {
  final BoxConstraints parentConstraints;
  final ViewState viewState;
  final Size viewSize;
  final int viewIndex;

  const _ManagedViewScaffold({
    Key key,
    @required this.parentConstraints,
    @required this.viewState,
    @required this.viewSize,
    @required this.viewIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final bloc = context.bloc<ViewManagerBloc>();

    final theme = Theme.of(context);
    //final barColor = theme.canvasColor;
    final barColor = theme.appBarTheme.color ?? theme.primaryColor;
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

    //final side = BorderSide(width: 1, color: Theme.of(context).primaryColor);

    return Theme(
      data: theme.copyWith(appBarTheme: newAppBarTheme),
      child: // Container(
          // decoration: BoxDecoration(
          //   border: Border(right: side, bottom: side),
          // ),
          // child:
          Scaffold(
        appBar: AppBar(
          title: _ManagedViewTitle(state: viewState, viewSize: viewSize),
          leading: bloc.state.views.length <= 1
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () {
                    final event = ViewManagerEvent.remove(viewIndex);
                    bloc.add(event);
                  },
                ),
          // actions: <Widget>[
          //   IconButton(
          //     icon: const Icon(Icons.border_outer),
          //     onPressed: () {
          //       bloc.add(ViewManagerEvent.setWidth(position: viewIndex, width: null));
          //       bloc.add(ViewManagerEvent.setHeight(position: viewIndex, height: null));
          //     },
          //   ),
          //   IconButton(
          //     icon: const Icon(Icons.format_textdirection_l_to_r),
          //     onPressed: () {
          //       final viewState = bloc.state.views[viewIndex];
          //       final idealWidth = viewState.idealWidth(parentConstraints) ??
          //           _minWidthForType(viewState.type, parentConstraints);
          //       final event =
          //           ViewManagerEvent.setWidth(position: viewIndex, width: idealWidth + 20.0);
          //       bloc.add(event);
          //     },
          //   ),
          //   IconButton(
          //     icon: const Icon(Icons.format_line_spacing),
          //     onPressed: () {
          //       final viewState = bloc.state.views[viewIndex];
          //       final idealHeight = viewState.idealHeight(parentConstraints) ??
          //           _minHeightForType(viewState.type, parentConstraints);
          //       final event =
          //           ViewManagerEvent.setHeight(position: viewIndex, height: idealHeight + 20.0);
          //       bloc.add(event);
          //     },
          //   ),
          // ],
        ),
        body: _ManagedViewBody(state: viewState, size: viewSize),
      ),
      // ), // Container
    );
  }
}

class _ManagedViewTitle extends StatelessWidget {
  final ViewState state;
  final Size viewSize;

  const _ManagedViewTitle({Key key, @required this.state, @required this.viewSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      ViewManager.shared._buildViewTitle(context, state, viewSize);
}

///
/// Managed view body widget.
///
class _ManagedViewBody extends StatelessWidget {
  final ViewState state;
  final Size size;

  const _ManagedViewBody({Key key, @required this.state, @required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) => ViewManager.shared._buildViewBody(context, state, size);
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
  double minWidth(BoxConstraints c) => _minWidthForType(type, c);
  double minHeight(BoxConstraints c) => _minHeightForType(type, c);
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

        views.add(AnimatedPositionedDirectional(
          key: ValueKey(state.uid),
          duration: const Duration(milliseconds: 200),
          start: x,
          top: y,
          width: width,
          height: height,
          child: _ManagedViewScaffold(
            parentConstraints: constraints,
            viewState: state,
            viewSize: Size(width, height),
            viewIndex: i++,
          ),
        ));

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

///
/// ThemeData extensions.
///
extension _ExtOnThemeData on ThemeData {
  TextTheme copyOfAppBarTextThemeWithColor(Color color) =>
      appBarTheme.textTheme?.apply(bodyColor: color) ??
      primaryTextTheme?.apply(bodyColor: color) ??
      TextTheme(headline6: TextStyle(color: color));
}

///
/// AppBarTheme extensions.
///
extension _ExtOnAppBarTheme on AppBarTheme {
  IconThemeData copyOfActionsIconThemeWithColor(Color color) =>
      actionsIconTheme?.copyWith(color: color) ?? IconThemeData(color: color);
  IconThemeData copyOfIconThemeWithColor(Color color) =>
      iconTheme?.copyWith(color: color) ?? IconThemeData(color: color);
}

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
/// View types
///
enum ViewType { bible }

double minWidthForViewType(ViewType type) {
  return 229;
}

double minHeightForViewType(ViewType type) {
  return 299;
}

/*
typedef ViewBuilder = Widget Function(BuildContext context);

mixin Viewable {
  //static Size get minSize => const Size(300, 300);
  double get preferredWidth; // `null` indicates no preferredWidth
  double get preferredHeight; // `null` indicates no preferredWidth

}
*/

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
      //tec.dmPrint('loaded ViewManagerState: $jsonStr');
      final json = tec.parseJsonSync(jsonStr);
      if (json != null) return ViewManagerState.fromJson(json);
    }
    return ViewManagerState([]);
  }

  @override
  Stream<ViewManagerState> mapEventToState(ViewManagerEvent event) async* {
    final value = event.when(
      add: _add,
      remove: _remove,
      move: _move,
      setWidth: _setWidth,
      setHeight: _setHeight,
    );
    assert(value != null);
    if (value == null) {
      assert(false);
      yield state;
    } else {
      if (value != state) {
        final strValue = tec.toJsonString(value);
        //tec.dmPrint('VM mapEventToState saving state: $strValue');
        await _kvStore.setString(_key, strValue);
      }
      yield value;
    }
  }

  ViewManagerState _add(ViewType type, int position, String data) {
    //tec.dmPrint('VM add type: $type, position: $position, data: \'$data\'');
    final view = ViewState(type: type, data: data);
    final newViews = List.of(state.views); // shallow copy
    newViews.insert(position ?? newViews.length, view);
    return ViewManagerState(newViews);
  }

  ViewManagerState _remove(int position) {
    assert(position != null);
    final newViews = List.of(state.views) // shallow copy
      ..removeAt(position);
    return ViewManagerState(newViews);
  }

  ViewManagerState _move(int from, int to) {
    if (from == to) return state;
    final newViews = List.of(state.views) // shallow copy
      ..move(from: from, to: to);
    return ViewManagerState(newViews);
  }

  ViewManagerState _setWidth(int position, double width) {
    assert(state.views.isValidIndex(position));
    final newViews = List.of(state.views); // shallow copy
    newViews[position] = newViews[position].copyWith(preferredWidth: width);
    return ViewManagerState(newViews);
  }

  ViewManagerState _setHeight(int position, double height) {
    assert(state.views.isValidIndex(position));
    final newViews = List.of(state.views); // shallow copy
    newViews[position] = newViews[position].copyWith(preferredHeight: height);
    return ViewManagerState(newViews);
  }
}

///
/// ViewManagerEvent
///
@freezed
abstract class ViewManagerEvent with _$ViewManagerEvent {
  const factory ViewManagerEvent.add(
      {@required ViewType type, int position, String data}) = _Add;
  const factory ViewManagerEvent.remove(int position) = _Remove;
  const factory ViewManagerEvent.move({int fromPosition, int toPosition}) =
      _Move;
  const factory ViewManagerEvent.setWidth({int position, double width}) =
      _SetWidth;
  const factory ViewManagerEvent.setHeight({int position, double height}) =
      _SetHeight;
}

///
/// ViewState
///
@freezed
abstract class ViewState with _$ViewState {
  factory ViewState({
    ViewType type,
    double preferredWidth,
    double preferredHeight,
    String data,
  }) = _ViewState;

  /// fromJson
  factory ViewState.fromJson(Map<String, dynamic> json) =>
      _$ViewStateFromJson(json);
}

///
/// ViewManagerState
///
@freezed
abstract class ViewManagerState with _$ViewManagerState {
  factory ViewManagerState(List<ViewState> views) = _Views;

  /// fromJson
  factory ViewManagerState.fromJson(Map<String, dynamic> json) =>
      _$ViewManagerStateFromJson(json);
}

///
/// ViewManagerWidget
///
class ViewManagerWidget extends StatelessWidget {
  final ViewManagerState state;

  const ViewManagerWidget({Key key, this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => _VMViewStack(
        vmState: state,
        constraints: constraints,
      ),
    );
  }
}

class _VMViewStack extends StatefulWidget {
  final BoxConstraints constraints;
  final ViewManagerState vmState;

  const _VMViewStack({Key key, this.constraints, this.vmState})
      : super(key: key);

  @override
  _VMViewStackState createState() => _VMViewStackState();
}

class _VMViewStackState extends State<_VMViewStack> {
  @override
  void didUpdateWidget(_VMViewStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    // if (oldWidget.constraints != widget.constraints ||
    //     oldWidget.vmState != widget.vmState) {
    //   setState(() {
    //     tec.dmPrint('rebuilding view stack...');
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    final views = <_View>[];
    _layoutViews(views, widget.vmState, widget.constraints);
    return Stack(children: [for (final view in views) view.asWidget()]);
  }
}

///
/// ViewWidget
///
class ViewWidget extends StatefulWidget {
  final ViewState viewState;
  final int viewIndex;

  const ViewWidget({Key key, this.viewState, this.viewIndex}) : super(key: key);

  @override
  _ViewWidgetState createState() => _ViewWidgetState();
}

class _ViewWidgetState extends State<ViewWidget> {
  final _pageController = TecPageController(
    //initialPage: 1,
    //viewportFraction: 0.8,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ViewManagerBloc bloc() => context.bloc<ViewManagerBloc>();

    final theme = Theme.of(context);
    //final barColor = theme.canvasColor;
    final barColor = theme.appBarTheme.color ?? theme.primaryColor;
    final barTextColor =
        ThemeData.estimateBrightnessForColor(barColor) == Brightness.light
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
      child: Container(
        // decoration: BoxDecoration(
        //   border: Border(right: side, bottom: side),
        // ),
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.viewState.data}'),
            leading: bloc().state.views.length <= 1
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () {
                      final event = ViewManagerEvent.remove(widget.viewIndex);
                      bloc().add(event);
                    },
                  ),
            // actions: <Widget>[
            //   IconButton(
            //     icon: const Icon(Icons.border_outer),
            //     onPressed: () {
            //       bloc().add(ViewManagerEvent.setWidth(
            //           position: widget.viewIndex, width: null));
            //       bloc().add(ViewManagerEvent.setHeight(
            //           position: widget.viewIndex, height: null));
            //     },
            //   ),
            //   IconButton(
            //     icon: const Icon(Icons.format_textdirection_l_to_r),
            //     onPressed: () {
            //       final viewState = bloc().state.views[widget.viewIndex];
            //       final idealWidth = viewState.idealWidth ??
            //           minWidthForViewType(viewState.type);
            //       final event = ViewManagerEvent.setWidth(
            //           position: widget.viewIndex, width: idealWidth + 20.0);
            //       bloc().add(event);
            //     },
            //   ),
            //   IconButton(
            //     icon: const Icon(Icons.format_line_spacing),
            //     onPressed: () {
            //       final viewState = bloc().state.views[widget.viewIndex];
            //       final idealHeight = viewState.idealHeight ??
            //           minHeightForViewType(viewState.type);
            //       final event = ViewManagerEvent.setHeight(
            //           position: widget.viewIndex, height: idealHeight + 20.0);
            //       bloc().add(event);
            //     },
            //   ),
            // ],
          ),
          body: TecPageView(
            pageBuilder: (context, index) => (index >= -2 && index <= 2)
                ? BibleChapterView(pageIndex: index)
                : null,
            controller: _pageController,
            onPageChanged: (page) =>
                tec.dmPrint('ViewWidget onPageChanged($page)'),
          ),
        ),
      ),
    );
  }
}

class BibleChapterView extends StatelessWidget {
  final int pageIndex;

  const BibleChapterView({Key key, @required this.pageIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.deepOrangeAccent,
        borderRadius: BorderRadius.all(Radius.circular(36)),
        //border: Border.all(),
      ),
      child: Center(
        child: Text(
          'page $pageIndex',
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

//
// PRIVATE DATA AND FUNCTIONS
//

enum _Size { min, ideal }

void _layoutViews(
  List<_View> views,
  ViewManagerState state,
  BoxConstraints constraints,
) {
  // Build the list of rows, using each view's `idealWidth`.
  final rows = _buildRows(_Size.ideal, state, constraints);

  // If not all views fit, see if more will fit using `minWidth`?
  // if (rows.totalItems < state.views.length) {
  //   final minRows = _buildRows(_Size.min, state, constraints);
  //   if (minRows.totalItems > rows.totalItems) rows = minRows;
  // }

  // Balance the rows, then save them to the view list.
  rows // ignore: cascade_invocations
    ..balance()
    ..toViewList(views, constraints);
}

extension _ExtOnViewState on ViewState {
  double get minWidth => minWidthForViewType(type);
  double get minHeight => minHeightForViewType(type);
  double get idealWidth => math.max(preferredWidth ?? 0, minWidth);
  double get idealHeight => math.max(preferredHeight ?? 0, minHeight);
  double width(_Size s) => s == _Size.min ? minWidth : idealWidth;
  double height(_Size s) => s == _Size.min ? minHeight : idealHeight;
}

extension _ExtOnListOfViewState on List<ViewState> {
  double get minWidth => fold(0.0, (t, el) => t + el.minWidth);
  double get minHeight => fold(0.0, (t, el) => math.max(t, el.minHeight));
  double get idealWidth => fold(0.0, (t, el) => t + el.idealWidth);
  double get idealHeight => fold(0.0, (t, el) => math.max(t, el.idealHeight));
  double width(_Size s) => s == _Size.min ? minWidth : idealWidth;
  double height(_Size s) => s == _Size.min ? minHeight : idealHeight;
}

///
/// _buildRows
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
        rows.last.width(size) + viewState.width(size) > constraints.maxWidth) {
      // If another row won't fit, break out of the for loop.
      if (rows.isNotEmpty &&
          rows.minHeight + viewState.width(size) > constraints.maxHeight) {
        break; // ---------------------------->
      }
      rows.add(<ViewState>[]);
    }
    rows.last.add(viewState);
  }
  return rows;
}

extension _ExtOnListOfListOfViewState on List<List<ViewState>> {
  double get minHeight => fold(0.0, (t, el) => t + el.minHeight);
  double get idealHeight => fold(0.0, (t, el) => t + el.idealHeight);
  double height(_Size s) => s == _Size.min ? minHeight : idealHeight;

  int get totalItems => fold(0, (t, el) => t + el.length);

  ///
  /// Balances rows of items based on the ideal width of each item.
  ///
  void balance() {
    // Balance from the bottom up.
    for (var i = length - 2; i >= 0; i--) {
      while (_balanceRow(i)) {
        // Row `i` changed, so we need to rebalance the rows after it.
        // Rebalance from row `i + 1` down, until there a no changes.
        var changed = false;
        for (var j = i + 1; j < length - 1; j++) {
          if (_balanceRow(j)) {
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
  bool _balanceRow(int i) {
    assert(i != null && i >= 0 && i + 1 < length);
    if (i + 1 >= length) return false;

    final row1 = this[i];
    final row2 = this[i + 1];
    var changed = false;

    // Keep moving the last item in row `i` to the next row until they are in balance.
    while (row1.length > 1) {
      if (row2.idealWidth + row1.last.idealWidth <= row1.idealWidth) {
        row2.insert(0, row1.removeLast());
        changed = true;
      } else {
        break;
      }
    }

    return changed;
  }

  ///
  /// Saves the rows of view states to the given [views] list.
  ///
  void toViewList(List<_View> views, BoxConstraints constraints) {
    var i = 0;
    var y = 0.0;

    // First, clear the view list.
    views.clear();

    final yExtraPerRow =
        math.max(0.0, (constraints.maxHeight - idealHeight) / length);
    var yExtra = yExtraPerRow > 0.0 ? 0.0 : constraints.maxHeight - minHeight;

    for (final row in this) {
      var x = 0.0;

      double height;
      if (yExtraPerRow > 0.0) {
        height = row.idealHeight + yExtraPerRow;
      } else {
        final yDelta = math.min(row.idealHeight - row.minHeight, yExtra);
        yExtra -= yDelta;
        height = row.minHeight + yDelta;
      }

      final xExtraPerItem =
          math.max(0.0, (constraints.maxWidth - row.idealWidth) / row.length);
      var xExtra =
          xExtraPerItem > 0.0 ? 0.0 : constraints.maxWidth - row.minWidth;

      for (final state in row) {
        double width;
        if (xExtraPerItem > 0.0) {
          width = state.idealWidth + xExtraPerItem;
        } else {
          final xDelta = math.min(state.idealWidth - state.minWidth, xExtra);
          xExtra -= xDelta;
          width = state.minWidth + xDelta;
        }
        views.add(_View(Rect.fromLTWH(x, y, width, height),
            ViewWidget(viewState: state, viewIndex: i++)));
        x += width;
      }
      y += height;
    }
  }
}

class _View {
  final Rect rect;
  final Widget view;

  _View(this.rect, this.view);

  Widget asWidget() => AnimatedPositionedDirectional(
      duration: const Duration(milliseconds: 200),
      start: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: view);
}

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

extension _ExtOnThemeData on ThemeData {
  TextTheme copyOfAppBarTextThemeWithColor(Color color) =>
      appBarTheme.textTheme?.apply(bodyColor: color) ??
      primaryTextTheme?.apply(bodyColor: color) ??
      TextTheme(headline6: TextStyle(color: color));

  // TextTheme copyOfAppBarTextThemeWithColor(Color color) =>
  //     appBarTheme.textTheme?.copyWith(
  //         headline6: appBarTheme.textTheme?.headline6?.copyWith(color: color) ??
  //             TextStyle(color: color)) ??
  //     primaryTextTheme?.copyWith(
  //         headline6: primaryTextTheme.headline6?.copyWith(color: color) ??
  //             TextStyle(color: color)) ??
  //     TextTheme(headline6: TextStyle(color: color));
}

extension _ExtOnAppBarTheme on AppBarTheme {
  IconThemeData copyOfActionsIconThemeWithColor(Color color) =>
      actionsIconTheme?.copyWith(color: color) ?? IconThemeData(color: color);
  IconThemeData copyOfIconThemeWithColor(Color color) =>
      iconTheme?.copyWith(color: color) ?? IconThemeData(color: color);
}

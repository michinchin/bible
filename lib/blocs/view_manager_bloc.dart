import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;

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
    final value = event.when(add: _add, remove: _remove, move: _move);
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
  // const factory ViewManagerEvent.setWidth({int position, double width}) =
  //     _SetWidth;
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
    return LayoutBuilder(builder: (context, constraints) {
      final views = <_View>[];
      _layoutViews(views, state, constraints);
      if (views.isEmpty) {
        return Container();
      } else {
        return Stack(children: [for (final view in views) view.asWidget()]);
      }
    });
  }
}

///
/// ViewWidget
///
class ViewWidget extends StatelessWidget {
  final ViewState viewState;
  final int viewIndex;

  const ViewWidget({Key key, this.viewState, this.viewIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(width: 1, color: Theme.of(context).primaryColor);
    return Container(
      decoration: BoxDecoration(
        border: Border(right: side, bottom: side),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${viewState.data}'),
          actions: <Widget>[
            if (context.bloc<ViewManagerBloc>().state.views.length > 1)
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Close',
                onPressed: () {
                  final event = ViewManagerEvent.remove(viewIndex);
                  context.bloc<ViewManagerBloc>().add(event);
                },
              ),
          ],
        ),
        body: Container(),
      ),
    );
  }
}

//
// PRIVATE DATA AND FUNCTIONS
//

void _layoutViews(
  List<_View> views,
  ViewManagerState state,
  BoxConstraints constraints,
) {
  //var ranOutOfRoom = false;

  // Build an initial list of rows using `minWidth`.
  final rows = <List<ViewState>>[];
  for (final viewState in state.views) {
    // Add another row?
    if (rows.isEmpty ||
        rows.last.minWidth + viewState.minWidth > constraints.maxWidth) {
      // If another row won't fit, break out of the for loop.
      if (rows.isNotEmpty &&
          rows.minHeight + viewState.minHeight > constraints.maxHeight) {
        //ranOutOfRoom = true;
        break; // ---------------------------->
      }
      rows.add(<ViewState>[]);
    }
    rows.last.add(viewState);
  }

  // Balance the rows and convert to views list.
  rows
    ..balance()
    ..toViewList(views, constraints);
}

extension _ExtOnViewState on ViewState {
  double get minWidth => minWidthForViewType(type);
  double get minHeight => minHeightForViewType(type);
  double get idealWidth => math.max(preferredWidth ?? 0, minWidth);
  double get idealHeight => math.max(preferredHeight ?? 0, minHeight);
}

extension _ExtOnListOfViewState on List<ViewState> {
  double get minWidth => fold(0.0, (t, el) => t + el.minWidth);
  double get minHeight => fold(0.0, (t, el) => math.max(t, el.minHeight));
  double get idealWidth => fold(0.0, (t, el) => t + el.idealWidth);
  double get idealHeight => fold(0.0, (t, el) => math.max(t, el.idealHeight));
}

extension _ExtOnListOfListOfViewState on List<List<ViewState>> {
  double get minHeight => fold(0.0, (t, el) => t + el.minHeight);
  double get idealHeight => fold(0.0, (t, el) => t + el.idealHeight);

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
  /// items in the rows.
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

  void toViewList(List<_View> views, BoxConstraints constraints) {
    views.clear();
    var i = 0;
    var y = 0.0;

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
  bool isInRange(num i) => i >= 0 && i < length;

  void move({@required int from, @required int to}) {
    assert(from != null && isInRange(from) && to != null && isInRange(to));
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

/*
typedef ViewBuilder = Widget Function(BuildContext context);

mixin Viewable {
  //static Size get minSize => const Size(300, 300);
  double get preferredWidth; // `null` indicates no preferredWidth
  double get preferredHeight; // `null` indicates no preferredWidth

}

typedef ViewBuilder = Widget Function(BuildContext context);

class ViewManager {
  void addViewable({Size minSize, ViewBuilder viewBuilder}) {

  }
}

class TestView extends StatelessWidget with Viewable {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
    );
  }

  static Size get minSize => const Size(200, 200);

  @override
  Size get preferredHeight => throw UnimplementedError();

  @override
  Size get preferredWidth => throw UnimplementedError();
}
*/

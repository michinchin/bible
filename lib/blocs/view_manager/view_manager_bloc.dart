import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../ui/common/common.dart';
import '../../ui/common/tec_page_view.dart';
import '../selection/selection_bloc.dart';

part 'view_manager.dart';
part 'view_manager_bloc.freezed.dart';
part 'view_manager_bloc.g.dart';
part 'view_manager_private.dart';

const String _key = 'viewManagerState';

///
/// ViewManagerBloc
///
class ViewManagerBloc extends Bloc<ViewManagerEvent, ViewManagerState> {
  ///
  /// Returns a new [ViewManagerBloc]. This should only be done once at the
  /// appropriate place in your widget tree using `BlocProvider(create:)`.
  ///
  ViewManagerBloc({@required tec.KeyValueStore kvStore})
      : assert(kvStore != null),
        _kvStore = kvStore;

  final tec.KeyValueStore _kvStore;

  var _viewRects = <ViewRect>[]; // ignore: prefer_final_fields
  List<List<ViewState>> _rows = []; // ignore: prefer_final_fields

  ///
  /// Is the view manager full of views? True, if another view cannot fit on the screen,
  /// false otherwise. Note, this can change if the screen orientation changes, or, as
  /// in the case with iPad multitasking, the app window size changes.
  ///
  bool get isFull => _isFull;
  bool _isFull = false; // ignore: prefer_final_fields

  ///
  /// Returns the number of rows currently displayed.
  ///
  /// Note, when a view is maximized this returns the number of rows that will be
  /// displayed when the view is not maximized.
  ///
  int get rows => _rows.length;

  ///
  /// Returns the number of columns currently displayed in the given [row].
  ///
  /// Note, when a view is maximized this returns the number of columns that will be
  /// displayed when the view is not maximized.
  ///
  int columnsInRow(int row) => row < 0 || row >= _rows.length ? 0 : _rows[row].length;

  ///
  /// Returns the view at the given [row] and [column], or `null` if [row] or [column] is
  /// out of range.
  ///
  /// Note, when a view is maximized, this returns the view that will be at the given
  /// row and column when the view is not maximized.
  ///
  ViewState viewAt({int row, int column}) =>
      row < 0 || row >= _rows.length || column < 0 || column >= _rows[row].length
          ? null
          : _rows[row][column];

  ///
  /// Returns the total number of open views. Note, open does not mean visible.
  ///
  int get countOfOpenViews => state.views?.length ?? 0;

  ///
  /// Returns the number of views that are currently visible on the screen.
  /// If a view is maximized, 1 is returned.
  ///
  int get countOfVisibleViews => _viewRects.where((e) => e.isVisible).length;

  ///
  /// Returns the number of views that are currently not visible on the screen.
  ///
  int get countOfInvisibleViews => countOfOpenViews - countOfVisibleViews;

  ///
  /// Returns `true` if the view with the given [uid] is visible on the screen.
  ///
  bool isViewWithUidVisible(int uid) => rectOfViewWithUid(uid)?.isVisible ?? false;

  ///
  /// Returns the [ViewState] of the view with the given [uid], or null if none.
  ///
  ViewState stateOfViewWithUid(int uid) =>
      state.views.firstWhere((e) => e.uid == uid, orElse: () => null);

  ///
  /// Returns the index of the view with the given [uid], or -1 if not found.
  ///
  int indexOfView(int uid) => state.views.indexWhere((e) => e.uid == uid);

  ///
  /// Returns the [ViewRect] of the view with the given [uid], or null if none.
  ///
  ViewRect rectOfViewWithUid(int uid) =>
      _viewRects.firstWhere((e) => e.uid == uid, orElse: () => null);

  //-------------------------------------------------------------------------
  // Selection related:

  final _viewsWithSelections = <int>{};

  ///
  /// This should be called by views that support text selection, when their [hasSelections]
  /// state changes.
  ///
  void notifyOfSelectionsInViewWithUid(
    int uid,
    BuildContext context, {
    @required bool hasSelections,
  }) {
    assert(uid != null && context != null && hasSelections != null);

    if (hasSelections) {
      _viewsWithSelections.add(uid);
    } else {
      _viewsWithSelections.remove(uid);
    }

    // Remove invalid uid values from the set.
    for (final uid in _viewsWithSelections.toList()) {
      if (indexOfView(uid) == -1) _viewsWithSelections.remove(uid);
    }

    _updateSelectionBloc(context);
  }

  ///
  /// Returns an iterator over the uids of the views with selections that are visible.
  ///
  Iterable<int> get _visibleViewsWithSelections =>
      _viewsWithSelections.expand((uid) => isViewWithUidVisible(uid) ? [uid] : []);

  ///
  /// Updates the state of the [SelectionBloc] depending on the current state of visible
  /// views with selections.
  ///
  void _updateSelectionBloc(BuildContext context) {
    final isTextSelected = _visibleViewsWithSelections.isNotEmpty;
    final bloc = context.bloc<SelectionBloc>(); // ignore: close_sinks
    assert(bloc != null);
    bloc?.add(SelectionState(isTextSelected: isTextSelected));
  }

  ///
  /// Initial state
  ///
  @override
  ViewManagerState get initialState {
    final jsonStr = _kvStore.getString(_key);
    ViewManagerState state;
    if (tec.isNotNullOrEmpty(jsonStr)) {
      // tec.dmPrint('loaded ViewManagerState: $jsonStr');
      final json = tec.parseJsonSync(jsonStr);
      if (json != null) state = ViewManagerState.fromJson(json);
    }
    if (state == null || state.views.isEmpty) {
      state = _defaultViewManagerState;
    }
    return state;
  }

  @override
  Stream<ViewManagerState> mapEventToState(ViewManagerEvent event) async* {
    final value = event.when(
      add: _add,
      remove: _remove,
      maximize: _maximize,
      restore: _restore,
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
    return ViewManagerState(
      newViews,
      state.maximizedViewUid == 0 ? 0 : nextUid,
      tec.nextIntWithJsSafeWraparound(nextUid, wrapTo: 1),
    );
  }

  ViewManagerState _remove(int uid) {
    final position = indexOfView(uid);
    if (position < 0) return state;
    final newViews = List.of(state.views) // shallow copy
      ..removeAt(position);
    if (newViews.isEmpty) return _defaultViewManagerState;
    return ViewManagerState(
      newViews,
      state.maximizedViewUid == uid ? 0 : state.maximizedViewUid,
      state.nextUid,
    );
  }

  ViewManagerState _maximize(int uid) {
    final position = indexOfView(uid);
    if (position < 0) return state;
    return ViewManagerState(state.views, uid, state.nextUid);
  }

  ViewManagerState _restore() {
    return ViewManagerState(state.views, 0, state.nextUid);
  }

  ViewManagerState _move(int from, int to) {
    if (from == to) return state;
    final newViews = List.of(state.views) // shallow copy
      ..move(from: from, to: to);
    return ViewManagerState(newViews, state.maximizedViewUid, state.nextUid);
  }

  ViewManagerState _setWidth(int position, double width) {
    assert(state.views.isValidIndex(position));
    final newViews = List.of(state.views); // shallow copy
    newViews[position] = newViews[position].copyWith(preferredWidth: width);
    return ViewManagerState(newViews, state.maximizedViewUid, state.nextUid);
  }

  ViewManagerState _setHeight(int position, double height) {
    assert(state.views.isValidIndex(position));
    final newViews = List.of(state.views); // shallow copy
    newViews[position] = newViews[position].copyWith(preferredHeight: height);
    return ViewManagerState(newViews, state.maximizedViewUid, state.nextUid);
  }

  ViewManagerState _setData(int uid, String data) {
    final position = indexOfView(uid);
    if (position < 0) return state;
    final newViews = List.of(state.views); // shallow copy
    newViews[position] = newViews[position].copyWith(data: data);
    return ViewManagerState(newViews, state.maximizedViewUid, state.nextUid);
  }
}

///
/// ViewManagerEvent
///
@freezed
abstract class ViewManagerEvent with _$ViewManagerEvent {
  const factory ViewManagerEvent.add({@required String type, int position, String data}) = _Add;
  const factory ViewManagerEvent.remove(int uid) = _Remove;
  const factory ViewManagerEvent.maximize(int uid) = _Maximize;
  const factory ViewManagerEvent.restore() = _Restore;
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
/// View rectangle and other info.
///
@immutable
class ViewRect {
  final int uid;
  final bool isVisible;
  final int row;
  final int column;
  final Rect rect;

  const ViewRect({
    @required this.uid,
    @required this.isVisible,
    @required this.row,
    @required this.column,
    @required this.rect,
  });
}

///
/// ViewManagerState
///
@freezed
abstract class ViewManagerState with _$ViewManagerState {
  factory ViewManagerState(List<ViewState> views, int maximizedViewUid, int nextUid) = _Views;

  /// fromJson
  factory ViewManagerState.fromJson(Map<String, dynamic> json) {
    ViewManagerState state;
    try {
      state = _$ViewManagerStateFromJson(json);
    } catch (_) {}
    return state ?? _defaultViewManagerState;
  }
}

final _defaultViewManagerState = ViewManagerState([ViewState(uid: 1, type: 'BibleChapter')], 0, 2);

extension ViewManagerExtOnState on ViewManagerState {}

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

///
/// Signature of the function that is called when the current page is changed.
///
typedef PageableViewOnPageChanged = void Function(BuildContext context, ViewState state, int page);

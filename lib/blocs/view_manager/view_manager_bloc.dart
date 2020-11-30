import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../ui/common/common.dart';
import '../../ui/common/tec_page_view.dart';
import '../selection/selection_bloc.dart';
import 'view_data.dart';
import 'view_manager_event.dart';
import 'view_manager_state.dart';
import 'view_state.dart';

export 'view_data.dart';
export 'view_manager_event.dart';
export 'view_manager_state.dart';
export 'view_state.dart';

part 'view_manager.dart';

part 'view_manager_bloc.freezed.dart';

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
        _kvStore = kvStore,
        _globalKey = GlobalKey(),
        super(_initialState(kvStore));

  static ViewManagerState _initialState(tec.KeyValueStore kvStore) {
    final jsonStr = kvStore?.getString(_key);
    ViewManagerState state;
    if (tec.isNotNullOrEmpty(jsonStr)) {
      // tec.dmPrint('loaded ViewManagerState: $jsonStr');
      final json = tec.parseJsonSync(jsonStr);
      if (json != null) {
        try {
          state = ViewManagerState.fromJson(json);
        } catch (_) {}
      }
    }
    if (state == null || state.views.isEmpty) {
      return ViewManager.defaultState();
    }
    return state;
  }

  final tec.KeyValueStore _kvStore;
  final GlobalKey _globalKey;

  // ignore_for_file: prefer_final_fields

  final _blocs = <int, ViewDataBloc>{};

  ViewDataBloc dataBlocWithView(int uid) => _blocs[uid];

  /// List of ViewRect objects, one for each open view.
  var _viewRects = <ViewRect>[];

  /// The uid of the previous build's maximized view, or zero if none.
  var _prevBuildMaxedViewUid = 0;

  /// Rows and columns of the open views that fit in the view manager.
  List<List<ViewState>> _rows = [];

  /// List of the open views that did not fit in `_rows`.
  List<ViewState> _overflow = [];

  ///
  /// Returns the view manager rect in global coordinates.
  ///
  Rect get globalRect {
    return globalRectOfWidgetWithKey(_globalKey, _size ?? Size.zero) ?? Rect.zero;
  }

  ///
  /// If we're running on a phone or a small app window, limit number of views to 2.
  ///
  bool get numViewsLimited => _numViewsLimited;
  var _numViewsLimited = false;

  ///
  /// Returns the size of the view manager view.
  ///
  Size get size => _size;
  var _size = Size.zero;

  ///
  /// Is the view manager full of views? True, if another view cannot fit on the screen,
  /// false otherwise. Note, this can change if the screen orientation changes, or, as
  /// in the case with iPad multitasking, the app window size changes.
  ///
  bool get isFull => _isFull;
  bool _isFull = false;

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
  bool isViewVisible(int uid) => rectOfView(uid)?.isVisible ?? false;

  ///
  /// Returns the [ViewState] of the view with the given [uid], or null if none.
  ///
  ViewState stateOfView(int uid) => state.views.firstWhere((e) => e.uid == uid, orElse: () => null);

  ///
  /// Returns the index of the view with the given [uid], or -1 if not found.
  ///
  int indexOfView(int uid) => state.views.indexWhere((e) => e.uid == uid);

  ///
  /// Returns the [ViewRect] of the view with the given [uid], or null if none.
  ///
  ViewRect rectOfView(int uid) => _viewRects.firstWhere((e) => e.uid == uid, orElse: () => null);

  ///
  /// Returns the global [Rect] of the view with the given [uid], or null if none.
  ///
  Rect globalRectOfView(int uid) {
    final gr = globalRect;
    return _viewRects
        .firstWhere((e) => e.uid == uid, orElse: () => null)
        ?.rect
        ?.translate(gr?.left ?? 0.0, gr?.top ?? 0.0);
  }

  ///
  /// Returns the insets of the view with the given [uid].
  ///
  EdgeInsets insetsOfView(int uid) {
    final rect = rectOfView(uid)?.rect;
    if (rect != null && size != null && size != Size.zero) {
      return insetsFromParentSizeAndChildRect(size, rect);
    }
    return EdgeInsets.zero;
  }

  ///
  /// Returns the global insets of the view with the given [uid].
  ///
  EdgeInsets globalInsetsOfView(int uid, BuildContext context) {
    final rect = globalRectOfView(uid);
    final mq = MediaQuery.of(context);
    if (rect != null && mq?.size != null) {
      return insetsFromParentSizeAndChildRect(mq.size, rect);
    }
    return mq?.padding ?? EdgeInsets.zero;
  }

  //-------------------------------------------------------------------------
  // Getting and updating view specific data:

  ///
  /// Returns the String data associated with the view with the given [uid] or null if none.
  ///
  String dataWithView(int uid) => _kvStore?.getString('vm_$uid');

  ///
  /// Updates the String [data] associated with the view with the given [uid], or removes
  /// it if [data] is null.
  ///
  Future<void> updateDataWithView(int uid, String data) {
    // tec.dmPrint('ViewManagerBloc.updateDataWithView uid: $uid, data: $data');
    return data == null ? _kvStore?.remove('vm_$uid') : _kvStore?.setString('vm_$uid', data);
  }

  //-------------------------------------------------------------------------
  // Keyboard focus related:

  int _viewWithKeyboardFocus = 0;

  ///
  /// This should be called by a view before it requests keyboard focus.
  ///
  void requestingKeyboardFocusInView(int uid) {
    assert(uid != null && uid > 0);
    _viewWithKeyboardFocus = uid;
  }

  ///
  /// This should be called by a view when it releases keyboard focus.
  ///
  void releasingKeyboardFocusInView(int uid) {
    if (_viewWithKeyboardFocus == uid) _viewWithKeyboardFocus = 0;
  }

  //-------------------------------------------------------------------------
  // Selection related:

  final _viewsWithSelections = <int, Object>{};

  ///
  /// This should be called by views that support text selection, when their [hasSelections]
  /// state changes.
  ///
  void notifyOfSelectionsInView(
    int uid,
    Object selectionObject,
    BuildContext context, {
    @required bool hasSelections,
  }) {
    assert(uid != null && context != null && hasSelections != null);

    if (hasSelections) {
      _viewsWithSelections[uid] = selectionObject;
    } else {
      _viewsWithSelections.remove(uid);
    }

    // Remove invalid uid values from the set.
    for (final uid in List.of(_viewsWithSelections.keys)) {
      if (indexOfView(uid) == -1) _viewsWithSelections.remove(uid);
    }

    _updateSelectionBloc(context);
  }

  ///
  /// Returns an iterator over the uids of the views with selections that are visible.
  ///
  Iterable<int> get visibleViewsWithSelections =>
      _viewsWithSelections.keys.expand((uid) => isViewVisible(uid) ? [uid] : []);

  ///
  /// Returns the selection object for the view with the given [uid], or null if none.
  ///
  Object selectionObjectWithViewUid(int uid) => _viewsWithSelections[uid];

  ///
  /// Updates the state of the [SelectionBloc] depending on the current state of visible
  /// views with selections.
  ///
  void _updateSelectionBloc(BuildContext context) {
    final views = visibleViewsWithSelections.toList();
    final bloc = context.read<SelectionBloc>(); // ignore: close_sinks
    assert(bloc != null);
    bloc?.add(SelectionState(isTextSelected: views.isNotEmpty, viewsWithSelections: views));

    // tec.dmPrint('');
    // tec.dmPrint('SELECTED REFERENCES:');
    // for (final uid in visibleViewsWithSelections) {
    //   tec.dmPrint(selectionObjectWithViewUid(uid));
    // }
    // tec.dmPrint('');
  }

  @override
  Stream<ViewManagerState> mapEventToState(ViewManagerEvent event) async* {
    final value = await event.when(
      add: _add,
      remove: _remove,
      maximize: _maximize,
      restore: _restore,
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
        // remove any 'ignore' build info...and save state
        final json = value.toJson();
        json['rebuild'] = 'build';
        final strValue = tec.toJsonString(json);
        // tec.dmPrint('VM mapEventToState saving state: $strValue');
        await _kvStore.setString(_key, strValue);
      }
      yield value;
    }
  }

  Future<ViewManagerState> _add(String type, int position, String data) async {
    final nextUid = (state.nextUid ?? 1);
    final viewState = ViewState(uid: nextUid, type: type);
    final newViews = List.of(state.views); // shallow copy
    // tec.dmPrint('VM add type: $type, uid: $nextUid, position: $position, data: \'$data\'');
    newViews.insert(position ?? newViews.length, viewState);
    await updateDataWithView(nextUid, data);

    var maximizedViewUid = state.maximizedViewUid == 0 ? 0 : nextUid;

    // open maximized on phones when...
    // there is 1 view currently
    // or a view is already maximized
    if ((numViewsLimited ?? false) && (state.maximizedViewUid != 0 || state.views.length == 1)) {
      maximizedViewUid = nextUid;
    }

    return ViewManagerState(
      newViews,
      maximizedViewUid,
      tec.nextIntWithJsSafeWraparound(nextUid, wrapTo: 1),
    );
  }

  Future<ViewManagerState> _remove(int uid) async {
    final position = indexOfView(uid);
    if (position < 0) return state;
    await updateDataWithView(uid, null); // Clear its data, if any.
    final newViews = List.of(state.views) // shallow copy
      ..removeAt(position);
    if (newViews.isEmpty) return ViewManager.defaultState();
    return ViewManagerState(
      newViews,
      state.maximizedViewUid == uid ? 0 : state.maximizedViewUid,
      state.nextUid,
    );
  }

  Future<ViewManagerState> _maximize(int uid) async {
    final position = indexOfView(uid);
    if (position < 0) return state;
    return ViewManagerState(state.views, uid, state.nextUid);
  }

  Future<ViewManagerState> _restore() async {
    return ViewManagerState(state.views, 0, state.nextUid);
  }

  Future<ViewManagerState> _move(int from, int to) async {
    if (from == to) return state;
    final newViews = List.of(state.views) // shallow copy
      ..move(from: from, to: to);
    return ViewManagerState(
      newViews,
      state.maximizedViewUid,
      state.nextUid,
    );
  }

  Future<ViewManagerState> _setWidth(int position, double width) async {
    assert(state.views.isValidIndex(position));
    final newViews = List.of(state.views); // shallow copy
    newViews[position] = newViews[position].copyWith(preferredWidth: width);
    return ViewManagerState(
      newViews,
      state.maximizedViewUid,
      state.nextUid,
    );
  }

  Future<ViewManagerState> _setHeight(int position, double height) async {
    assert(state.views.isValidIndex(position));
    final newViews = List.of(state.views); // shallow copy
    newViews[position] = newViews[position].copyWith(preferredHeight: height);
    return ViewManagerState(
      newViews,
      state.maximizedViewUid,
      state.nextUid,
    );
  }
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
  }) : assert(uid != null && isVisible != null && row != null && column != null && rect != null);

  ViewRect copyWith({
    int uid,
    bool isVisible,
    int row,
    int column,
    Rect rect,
  }) =>
      ViewRect(
        uid: uid ?? this.uid,
        isVisible: isVisible ?? this.isVisible,
        row: row ?? this.row,
        column: column ?? this.column,
        rect: rect ?? this.rect,
      );
}

///
/// ViewManagerWidget
///
class ViewManagerWidget extends StatelessWidget {
  final ViewManagerState state;
  final Widget topLeftWidget;
  final Widget topRightWidget;
  final Widget bottomRightWidget;

  const ViewManagerWidget({
    Key key,
    this.state,
    this.topLeftWidget,
    this.topRightWidget,
    this.bottomRightWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // tec.dmPrint('ViewManagerWidget build()');
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) => _VMViewStack(
          key: context.viewManager?._globalKey,
          vmState: state,
          constraints: constraints,
          topLeftWidget: topLeftWidget,
          topRightWidget: topRightWidget,
          bottomRightWidget: bottomRightWidget,
        ),
      ),
    );
  }
}

///
/// Signature of a function that creates a widget for a given view state and index.
///
typedef IndexedBuilderWithViewState = Widget Function(
    BuildContext context, ViewState state, Size size, int index);

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

extension ViewManagerExtOnBuildContext on BuildContext {
  ViewManagerBloc get viewManager => BlocProvider.of<ViewManagerBloc>(this);
}

extension ViewManagerExtOnViewState on ViewState {
  ViewData dataWith(BuildContext context) => ViewData.fromContext(context, uid);
}

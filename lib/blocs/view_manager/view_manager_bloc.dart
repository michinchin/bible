import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../main_menu.dart';
import '../../ui/common/common.dart';
import '../../ui/common/tec_page_view.dart';
import '../sheet/sheet_manager_bloc.dart';

part 'view_manager.dart';
part 'view_manager_bloc.freezed.dart';
part 'view_manager_bloc.g.dart';
part 'view_manager_private.dart';

const String _key = 'viewManagerState';

///
/// ViewManagerBloc
///
class ViewManagerBloc extends Bloc<ViewManagerEvent, ViewManagerState> {
  final tec.KeyValueStore _kvStore;

  ///
  /// Returns a new [ViewManagerBloc]. This should only be done once at the
  /// appropriate place in your widget tree using `BlocProvider(create:)`.
  ///
  ViewManagerBloc({@required tec.KeyValueStore kvStore})
      : assert(kvStore != null),
        _kvStore = kvStore;

  ///
  /// Returns the index of the view with the given uid, or -1 if not found.
  ///
  int indexOfView(int uid) => state.views.indexWhere((e) => e.uid == uid);

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
      state = _defaultState;
    }
    return state;
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

  final _defaultState = ViewManagerState([ViewState(uid: 1, type: 'BibleChapter')], 2);

  ViewManagerState _add(String type, int position, String data) {
    final nextUid = (state.nextUid ?? 1);
    final viewState = ViewState(uid: nextUid, type: type, data: data);
    final newViews = List.of(state.views); // shallow copy
    // tec.dmPrint('VM add type: $type, uid: $nextUid, position: $position, data: \'$data\'');
    newViews.insert(position ?? newViews.length, viewState);
    return ViewManagerState(newViews, tec.nextIntWithJsSafeWraparound(nextUid, wrapTo: 1));
  }

  ViewManagerState _remove(int uid) {
    final position = indexOfView(uid);
    if (position < 0) return state;
    final newViews = List.of(state.views) // shallow copy
      ..removeAt(position);
    if (newViews.isEmpty) return _defaultState;
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
    final position = indexOfView(uid);
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

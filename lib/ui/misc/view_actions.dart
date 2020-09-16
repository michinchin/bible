import 'dart:convert';
import 'dart:math' as math;

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/bible_chapter_state.dart';
import '../bible/chapter_view.dart';
import '../common/common.dart';
import '../library/library.dart';
import '../menu/main_menu.dart';
import '../note/note_view.dart';
import '../study/study_view.dart';

const _menuWidth = 175.0;

List<Widget> defaultActionsBuilder(BuildContext context, ViewState state, Size size) {
  // ignore: close_sinks
  final vm = context.bloc<ViewManagerBloc>();
  final topRight = vm.state.maximizedViewUid == state.uid ||
      (vm.columnsInRow(0) - 1) == vm.indexOfView(state.uid);

  var insets = const EdgeInsets.all(0);
  final rect = vm.rectOfView(state.uid)?.rect;
  final vmSize = vm.size;
  if (rect != null && vmSize != null) {
    final mq = MediaQuery.of(context);
    insets = EdgeInsets.fromLTRB(
      math.max(0, rect.left + (mq?.padding?.left ?? 0.0)),
      math.max(0, rect.top + (mq?.padding?.top ?? 0.0)),
      math.max(0, vmSize.width - rect.right),
      mq?.padding?.bottom ?? 0.0,
    );
  }

  return [
    IconButton(
      icon: const Icon(SFSymbols.square_stack, size: 20),
      tooltip: 'Windows',
      color: Theme.of(context).textColor.withOpacity(0.5),
      onPressed: () {
        TecAutoScroll.stopAutoscroll();
        _showViewMenu(context: context, state: state, insets: insets);
      },
    ),
    if (topRight)
      IconButton(
        icon: const Icon(Icons.more_vert),
        tooltip: 'Main Menu',
        color: Theme.of(context).textColor.withOpacity(0.5),
        onPressed: () => showMainMenu(context),
      ),
  ];
}

Future<void> _showViewMenu({BuildContext context, ViewState state, EdgeInsetsGeometry insets}) {
  return showTecModalPopup<void>(
    useRootNavigator: true,
    context: context,
    alignment: Alignment.topRight,
    edgeInsets: insets,
    builder: (context) {
      return TecPopupSheet(
        child: _MenuItems(state: state),
      );
    },
  );
}

class _MenuItems extends StatelessWidget {
  final ViewState state;

  const _MenuItems({Key key, this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final bloc = context.bloc<ViewManagerBloc>();
    final isMaximized = bloc?.state?.maximizedViewUid != 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((bloc?.state?.views?.length ?? 0) > 1)
          _menuItem(context, isMaximized ? FeatherIcons.minimize2 : FeatherIcons.maximize2,
              isMaximized ? 'Restore' : 'Maximize', () {
            Navigator.of(context).maybePop();
            bloc?.add(isMaximized
                ? const ViewManagerEvent.restore()
                : ViewManagerEvent.maximize(state.uid));
          }),
        if (((bloc?.countOfInvisibleViews ?? 0) >= 1 || isMaximized)) ...[
          _titleDivider(context, isMaximized ? 'Switch To' : 'Switch With'),
          ..._generateOffScreenItems(context, state.uid)
        ],
        _titleDivider(context, 'Open New'),
        //...generateAddMenuItems(context, state.uid),
        _menuItemForType(bibleChapterType, context: context, viewUid: state.uid, onTap: () async {
          final bibleId = await selectVolume(context,
              title: 'Select Bible Translation',
              filter: const VolumesFilter(
                volumeType: VolumeType.bible,
              ));
          tec.dmPrint('selected $bibleId');

          if (bibleId != null) {
            final previous = BibleChapterState.fromJson(state.data);
            if (previous != null) {
              final current = BibleChapterState(bibleId, previous.bcv, previous.page);
              // following line is approximate if we wanted to change translation in save view
              //bloc?.add(ViewManagerEvent.setData(uid: state.uid, data: current.toString()));
              bloc?.add(ViewManagerEvent.add(type: bibleChapterType, data: current.toString()));
            }
          }

          await Navigator.of(context).maybePop();
        }),
        _menuItemForType(studyViewType, context: context, viewUid: state.uid, onTap: () async {
          final volumeId = await selectVolume(context,
              title: 'Select Study Content',
              filter: const VolumesFilter(
                volumeType: VolumeType.studyContent,
              ));
          tec.dmPrint('selected $volumeId');

          if (volumeId != null) {
            // TODO(ron): ...
            // final previous = BibleChapterState.fromJson(state.data);
            // if (previous != null) {
            //   final current = BibleChapterState(bibleId, previous.bcv, previous.page);
            //   // following line is approximate if we wanted to change translation in save view
            //   //bloc?.add(ViewManagerEvent.setData(uid: state.uid, data: current.toString()));
                 bloc?.add(const ViewManagerEvent.add(type: studyViewType, data: '{}'));
            // }
          }

          await Navigator.of(context).maybePop();
        }),
        _menuItemForType(noteViewType, context: context, viewUid: state.uid),
        if ((bloc?.state?.views?.length ?? 0) > 1) ...[
          const SizedBox(width: _menuWidth, child: Divider()),
          _menuItem(context, Icons.close, 'Close View', () {
            Navigator.of(context).maybePop();
            bloc?.add(ViewManagerEvent.remove(state.uid));
          }),
        ],
      ],
    );
  }

  Iterable<Widget> _generateOffScreenItems(BuildContext context, int viewUid) {
    // ignore: close_sinks
    final bloc = context.bloc<ViewManagerBloc>();
    final vm = ViewManager.shared;
    final items = <Widget>[];
    for (final view in bloc.state.views) {
      if (!bloc.isViewVisible(view.uid)) {
        String title;
        Map<String, dynamic> data;

        if (view.data != null) {
          data = jsonDecode(view.data) as Map<String, dynamic>;
        }

        if (data != null && data.containsKey('title')) {
          title = data['title'] as String;
        } else {
          title = vm.titleForType(view.type);
        }

        items.add(_menuItem(context, vm.iconForType(view.type), '$title', () {
          if (bloc.state.maximizedViewUid == viewUid) {
            bloc?.add(ViewManagerEvent.maximize(view.uid));
            Navigator.of(context).maybePop();
          } else {
            final thisViewPos = bloc.indexOfView(viewUid);
            final hiddenViewPos = bloc.indexOfView(view.uid);
            bloc?.add(ViewManagerEvent.move(
                fromPosition: bloc.indexOfView(view.uid), toPosition: bloc.indexOfView(viewUid)));
            bloc?.add(
                ViewManagerEvent.move(fromPosition: thisViewPos + 1, toPosition: hiddenViewPos));
            Navigator.of(context).maybePop();
          }
        }));
      }
    }
    return items;
  }

  Iterable<Widget> generateAddMenuItems(BuildContext context, int viewUid) {
    // ignore: close_sinks
    final vm = ViewManager.shared;
    return vm.types.map<Widget>((type) {
      final title = vm.titleForType(type);
      if (title == null) {
        // null titles are views that cannot be created from the menu
        return Container();
      }
      return _menuItemForType(type, context: context, viewUid: viewUid);
    });
  }

  Widget _menuItemForType(
    String type, {
    @required BuildContext context,
    @required int viewUid,
    void Function() onTap,
  }) {
    assert(tec.isNotNullOrEmpty(type) && context != null && viewUid != null);
    final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
    final vm = ViewManager.shared;
    return _menuItem(
        context,
        vm.iconForType(type),
        '${vm.titleForType(type)}',
        onTap ??
            () {
              Navigator.of(context).maybePop();
              final position = bloc?.indexOfView(viewUid) ?? -1;
              bloc?.add(ViewManagerEvent.add(
                  type: type,
                  data: vm.dataForType(type),
                  position: position == -1 ? null : position + 1));
            });
  }
}

Widget _titleDivider(BuildContext context, String title) {
  final textColor = Theme.of(context).textColor.withOpacity(0.5);
  return SizedBox(
    width: _menuWidth,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TecText(title, style: TextStyle(fontSize: 12, color: textColor)),
        const Expanded(child: Divider(indent: 10))
      ],
    ),
  );
}

Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
  final textScaleFactor = scaleFactorWith(context, maxScaleFactor: 1.2);
  final textColor = Theme.of(context).textColor.withOpacity(onTap == null ? 0.2 : 0.5);
  final iconSize = 24.0 * textScaleFactor;

  return CupertinoButton(
    padding: const EdgeInsets.only(top: 8, bottom: 8), // EdgeInsets.zero,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon == null)
          SizedBox(width: iconSize)
        else
          Icon(icon, color: textColor, size: iconSize),
        const SizedBox(width: 10),
        TecText(
          title,
          textScaleFactor: textScaleFactor,
          style: TextStyle(color: textColor),
        ),
      ],
    ),
    borderRadius: null,
    onPressed: onTap,
  );
}

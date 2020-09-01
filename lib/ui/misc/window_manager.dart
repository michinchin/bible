import 'dart:convert';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/bible_chapter_state.dart';
import '../bible/chapter_view.dart';
import '../library/library.dart';
import '../note/note_view.dart';

Future<void> showWindowDialog({BuildContext context, Widget Function(BuildContext) builder}) =>
    showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (c) => Dialog(
            // this property has been removed in flutter 1.20
            // useMaterialBorderRadius: true,
            backgroundColor: Colors.transparent,
            child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(15),
                child: builder(c))));

class WindowManager extends StatelessWidget {
  final ViewState state;
  const WindowManager({this.state});

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final bloc = context.bloc<ViewManagerBloc>();
    final isMaximized = bloc?.state?.maximizedViewUid != 0;

    return Stack(
      alignment: Alignment.topRight,
      children: [
        ListView(
          shrinkWrap: true,
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
              _titleDivider(context, isMaximized ? 'Switch' : 'Open'),
              ..._generateOffScreenItems(context, state.uid)
            ],
            _titleDivider(context, 'New'),
            //...generateAddMenuItems(context, state.uid),
            _menuItem(context, FeatherIcons.book, 'Bible', () async {
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
            _menuItemForType(noteViewType, context: context, viewUid: state.uid),
            if ((bloc?.state?.views?.length ?? 0) > 1) ...[
              const Divider(),
              _menuItem(context, Icons.close, 'Close View', () {
                Navigator.of(context).maybePop();
                bloc?.add(ViewManagerEvent.remove(state.uid));
              }),
            ],
          ],
        ),
//        IconButton(
//          icon: Icon(
//            Icons.close,
//            color: Theme.of(context).textColor.withOpacity(0.5),
//          ),
//          onPressed: Navigator.of(context).maybePop,
//        )
      ],
    );
  }

  Widget _titleDivider(BuildContext context, String title) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TecText(
            title,
            style: TextStyle(fontSize: 12, color: Theme.of(context).textColor.withOpacity(0.5)),
          ),
          const Expanded(
            child: Divider(
              indent: 10,
            ),
          )
        ],
      );

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
            bloc?.add(ViewManagerEvent.move(
                fromPosition: thisViewPos + 1, toPosition: hiddenViewPos));
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
  }) {
    assert(tec.isNotNullOrEmpty(type) && context != null && viewUid != null);
    final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
    final vm = ViewManager.shared;
    return _menuItem(context, vm.iconForType(type), '${vm.titleForType(type)}', () {
      Navigator.of(context).maybePop();
      final position = bloc?.indexOfView(viewUid) ?? -1;
      bloc?.add(ViewManagerEvent.add(
          type: type, data: vm.dataForType(type), position: position == -1 ? null : position + 1));
    });
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onPressed) {
    return ListTile(
      dense: true,
      onTap: onPressed,
      leading: Icon(
        icon,
        color: Theme.of(context).textColor.withOpacity(0.5),
      ),
      title: TecText(title),
    );
  }
}

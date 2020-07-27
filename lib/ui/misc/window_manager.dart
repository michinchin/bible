import 'dart:convert';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';

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
    final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
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
            ..._generateAddMenuItems(context, state.uid),
            _menuItem(context, FeatherIcons.bookOpen, 'Translation', () {
              showWindowDialog(context: context, builder: (c) => BibleTranslationSelection());
            }),
            if ((bloc?.state?.views?.length ?? 0) > 1) ...[
              const Divider(),
              _menuItem(context, Icons.close, 'Close View', () {
                Navigator.of(context).maybePop();
                bloc?.add(ViewManagerEvent.remove(state.uid));
              }),
            ],
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).textColor.withOpacity(0.5),
          ),
          onPressed: Navigator.of(context).maybePop,
        )
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
    final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
    final vm = ViewManager.shared;
    final items = <Widget>[];
    for (final each in bloc.state.views) {
      if (!bloc.isViewVisible(each.uid)) {
        String title;

        final data = jsonDecode(each.data) as Map<String, dynamic>;
        if (data != null && data.containsKey('title')) {
          title = data['title'] as String;
        }
        else {
          title = vm.titleForType(each.type);
        }

        items.add(_menuItem(context, vm.iconForType(each.type), '$title', () {
          if (bloc.state.maximizedViewUid == viewUid) {
            bloc?.add(
                ViewManagerEvent.move(fromPosition: bloc.indexOfView(each.uid), toPosition: 0));
            bloc?.add(ViewManagerEvent.maximize(each.uid));
            Navigator.of(context).maybePop();
          } else {
            bloc?.add(
                ViewManagerEvent.move(fromPosition: bloc.indexOfView(each.uid), toPosition: 0));
            Navigator.of(context).maybePop();
          }
        }));
      }
    }
    return items;
  }

  Iterable<Widget> _generateAddMenuItems(BuildContext context, int viewUid) {
    final vm = ViewManager.shared;
    return vm.types.map<Widget>((type) {
      final title = vm.titleForType(type);
      if (title == null) {
        // null titles are views that cannot be created from the menu
        return Container();
      }

      return _menuItem(context, vm.iconForType(type), '${vm.titleForType(type)}', () {
        Navigator.of(context).maybePop();
        final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
        final position = bloc?.indexOfView(viewUid) ?? -1;
        bloc?.add(ViewManagerEvent.add(
            type: type, data: '', position: position == -1 ? null : position + 1));
      });
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
        title: TecText(
          title,
        ));
  }
}

class BibleTranslationSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const bt = [
      'New International Version',
      'New Living Translation',
      'Christian Standard Bible',
      'Amplified Bible',
      'The Message',
      'The Voice',
    ];
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ListView(children: [
            for (final each in bt)
              ListTile(
                  title: Text(each),
                  onTap: () => Navigator.of(context).popUntil((route) => route.isFirst))
          ]),
        ));
  }
}

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/view_manager/view_manager_bloc.dart';
import '../common/common.dart';
import '../menu/main_menu.dart';

const _menuWidth = 175.0;

List<Widget> defaultActionsBuilder(BuildContext context, ViewState state, Size size) {
  // ignore: close_sinks
  final vmBloc = context.bloc<ViewManagerBloc>();
  final topRight = vmBloc.state.maximizedViewUid == state.uid ||
      (vmBloc.columnsInRow(0) - 1) == vmBloc.indexOfView(state.uid);

  var insets = const EdgeInsets.all(0);
  final rect = vmBloc.rectOfView(state.uid)?.rect;
  final vmSize = vmBloc.size;
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
    final vmBloc = context.bloc<ViewManagerBloc>();
    final isMaximized = vmBloc?.state?.maximizedViewUid != 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((vmBloc?.state?.views?.length ?? 0) > 1)
          _menuItem(context, isMaximized ? FeatherIcons.minimize2 : FeatherIcons.maximize2,
              isMaximized ? 'Restore' : 'Maximize', () {
            Navigator.of(context).maybePop();
            vmBloc?.add(isMaximized
                ? const ViewManagerEvent.restore()
                : ViewManagerEvent.maximize(state.uid));
          }),
        if (((vmBloc?.countOfInvisibleViews ?? 0) >= 1 || isMaximized)) ...[
          _titleDivider(context, isMaximized ? 'Switch To' : 'Switch With'),
          ..._generateOffScreenItems(context, state.uid)
        ],
        _titleDivider(context, 'Open New'),
        ...generateAddMenuItems(context, state.uid),
        if ((vmBloc?.state?.views?.length ?? 0) > 1) ...[
          const SizedBox(width: _menuWidth, child: Divider()),
          _menuItem(context, Icons.close, 'Close View', () {
            Navigator.of(context).maybePop();
            vmBloc?.add(ViewManagerEvent.remove(state.uid));
          }),
        ],
      ],
    );
  }

  Iterable<Widget> _generateOffScreenItems(BuildContext context, int viewUid) {
    // ignore: close_sinks
    final vmBloc = context.bloc<ViewManagerBloc>();
    final vm = ViewManager.shared;
    final items = <Widget>[];
    for (final view in vmBloc?.state?.views) {
      if (!vmBloc.isViewVisible(view.uid)) {
        final title = vm.menuTitleWith(context: context, state: view);
        items.add(_menuItem(context, vm.iconWithType(view.type), '$title', () {
          if (vmBloc.state.maximizedViewUid == viewUid) {
            vmBloc?.add(ViewManagerEvent.maximize(view.uid));
            Navigator.of(context).maybePop();
          } else {
            final thisViewPos = vmBloc.indexOfView(viewUid);
            final hiddenViewPos = vmBloc.indexOfView(view.uid);
            vmBloc?.add(ViewManagerEvent.move(
                fromPosition: vmBloc.indexOfView(view.uid),
                toPosition: vmBloc.indexOfView(viewUid)));
            vmBloc?.add(
                ViewManagerEvent.move(fromPosition: thisViewPos + 1, toPosition: hiddenViewPos));
            Navigator.of(context).maybePop();
          }
        }));
      }
    }
    return items;
  }

  Iterable<Widget> generateAddMenuItems(BuildContext context, int viewUid) {
    assert(context != null && viewUid != null);
    final vm = ViewManager.shared;
    return vm.types.map<Widget>((type) {
      final title = vm.menuTitleWith(type: type);
      // Types that cannot be created from the menu return `null` for the menu title.
      if (title == null) return Container(width: _menuWidth);
      return _menuItem(context, vm.iconWithType(type), '$title', () async {
        tec.dmPrint('Adding new view of type $type.');
        await vm.onAddView(context, type, currentViewId: viewUid);
        await Navigator.of(context).maybePop();
      });
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

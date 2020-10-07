import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/shared_bible_ref_bloc.dart';
import '../../blocs/view_data/volume_view_data.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/const.dart';
import '../common/common.dart';
import '../common/tec_modal_popup_menu.dart';
import 'main_menu.dart';

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
      tooltip: 'View Menu',
      color: Theme.of(context).textColor.withOpacity(0.5),
      onPressed: () {
        TecAutoScroll.stopAutoscroll();
        showTecModalPopupMenu(
          context: context,
          insets: insets,
          minWidth: 125,
          menuItemsBuilder: (menuContext) => _buildMenuItemsForViewWithState(
            state,
            context: context,
            menuContext: menuContext,
          ),
        );
      },
    ),
    if (state.type == Const.viewTypeChapter)
      IconButton(
        icon: const Icon(SFSymbols.play, size: 20),
        tooltip: 'Play Audio',
        color: Theme.of(context).textColor.withOpacity(0.5),
        onPressed: () {},
      ),
    if (state.type == Const.viewTypeStudy)
      IconButton(
          icon: Icon(platformAwareMoreIcon(context)),
          onPressed: () {
            // TecAutoScroll.stopAutoscroll();
            // showTecModalPopupMenu(context: context, state: state, insets: insets);
          }),
    if (topRight)
      IconButton(
        icon: const Icon(Icons.account_circle_outlined),
        tooltip: 'Main Menu',
        color: Theme.of(context).textColor.withOpacity(0.5),
        onPressed: () => showMainMenu(context),
      ),
  ];
}

List<TableRow> _buildMenuItemsForViewWithState(
  ViewState state, {
  BuildContext context,
  BuildContext menuContext,
}) {
  // ignore: close_sinks
  final vmBloc = context.bloc<ViewManagerBloc>();
  final isMaximized = vmBloc?.state?.maximizedViewUid != 0;

  final viewData = ChapterViewData.fromContext(context, state.uid);
  final useSharedRef = viewData.useSharedRef;

  return [
    if ((vmBloc?.state?.views?.length ?? 0) > 1)
      tecModalPopupMenuItem(
          menuContext,
          isMaximized ? FeatherIcons.minimize2 : FeatherIcons.maximize2,
          isMaximized ? 'Restore' : 'Maximize', () {
        Navigator.of(menuContext).maybePop();
        vmBloc?.add(
            isMaximized ? const ViewManagerEvent.restore() : ViewManagerEvent.maximize(state.uid));
      }),
    if (((vmBloc?.countOfInvisibleViews ?? 0) >= 1 || isMaximized)) ...[
      tecModalPopupMenuDivider(menuContext, isMaximized ? 'Switch To' : 'Switch With'),
      ..._generateOffScreenItems(menuContext, state.uid)
    ],
    tecModalPopupMenuDivider(menuContext, 'Open New'),
    ...generateAddMenuItems(menuContext, state.uid),
    if ((vmBloc?.state?.views?.length ?? 0) > 1 &&
        {Const.viewTypeChapter, Const.viewTypeStudy}.contains(state.type)) ...[
      tecModalPopupMenuDivider(menuContext),
      tecModalPopupMenuItem(
        menuContext,
        useSharedRef ? Icons.link_off : Icons.link,
        useSharedRef ? 'Un-link Reference' : 'Link Reference',
        () {
          Navigator.of(menuContext).maybePop();
          final viewDataBloc = context.bloc<ViewDataBloc>();
          viewDataBloc?.update(viewData.copyWith(useSharedRef: !useSharedRef));
          if (!useSharedRef) {
            context.bloc<SharedBibleRefBloc>().update(viewData.bcv);
          }
        },
      ),
    ],
    if ((vmBloc?.state?.views?.length ?? 0) > 1) ...[
      tecModalPopupMenuDivider(menuContext),
      tecModalPopupMenuItem(menuContext, Icons.close, 'Close View', () {
        Navigator.of(menuContext).maybePop();
        vmBloc?.add(ViewManagerEvent.remove(state.uid));
      }),
    ],
  ];
}

Iterable<TableRow> _generateOffScreenItems(BuildContext menuContext, int viewUid) {
  // ignore: close_sinks
  final vmBloc = menuContext.bloc<ViewManagerBloc>();
  final vm = ViewManager.shared;
  final items = <TableRow>[];
  for (final view in vmBloc?.state?.views) {
    if (!vmBloc.isViewVisible(view.uid)) {
      final title = vm.menuTitleWith(context: menuContext, state: view);
      items.add(tecModalPopupMenuItem(menuContext, vm.iconWithType(view.type), '$title', () {
        if (vmBloc.state.maximizedViewUid == viewUid) {
          vmBloc?.add(ViewManagerEvent.maximize(view.uid));
          Navigator.of(menuContext).maybePop();
        } else {
          final thisViewPos = vmBloc.indexOfView(viewUid);
          final hiddenViewPos = vmBloc.indexOfView(view.uid);
          vmBloc?.add(ViewManagerEvent.move(
              fromPosition: vmBloc.indexOfView(view.uid), toPosition: vmBloc.indexOfView(viewUid)));
          vmBloc?.add(
              ViewManagerEvent.move(fromPosition: thisViewPos + 1, toPosition: hiddenViewPos));
          Navigator.of(menuContext).maybePop();
        }
      }));
    }
  }
  return items;
}

Iterable<TableRow> generateAddMenuItems(BuildContext menuContext, int viewUid) {
  assert(menuContext != null && viewUid != null);
  final vm = ViewManager.shared;
  return vm.types.map<TableRow>((type) {
    // Types that cannot be created from the menu return `null` for the menu title.
    final title = vm.menuTitleWith(type: type);
    if (title == null) return TableRow(children: [Container(), Container()]);

    return tecModalPopupMenuItem(menuContext, vm.iconWithType(type), '$title', () async {
      tec.dmPrint('Adding new view of type $type.');
      await vm.onAddView(menuContext, type, currentViewId: viewUid);
      await Navigator.of(menuContext).maybePop();
    });
  });
}

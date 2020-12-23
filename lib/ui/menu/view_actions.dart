import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/const.dart';
import '../common/tec_modal_popup_menu.dart';
import '../volume/volume_view_data_bloc.dart';

List<Widget> defaultActionsBuilder(BuildContext context, ViewState state, Size size) {
  // ignore: close_sinks
  final vmBloc = context.viewManager;
  final isMaximized = vmBloc?.state?.maximizedViewUid != 0;
  final isTopRightView = vmBloc.state.maximizedViewUid == state.uid ||
      (vmBloc.columnsInRow(0) - 1) == vmBloc.indexOfView(state.uid);

  return [
    if ((vmBloc?.countOfInvisibleViews ?? 0) >= 1 && isMaximized)
      IconButton(
        icon: const Icon(SFSymbols.arrow_up_arrow_down_circle, size: 20),
        onPressed: () {
          ViewState view;
          if (vmBloc.indexOfView(vmBloc.state.maximizedViewUid) == vmBloc.state.views.length - 1) {
            view = vmBloc.state.views.first;
          } else {
            view = vmBloc.state.views.firstWhere((v) =>
                vmBloc.indexOfView(v.uid) == vmBloc.indexOfView(vmBloc.state.maximizedViewUid) + 1);
          }
          _onSwitchViews(vmBloc, vmBloc.state.maximizedViewUid, view);
        },
      ),
    IconButton(
      icon: const Icon(SFSymbols.square_stack, size: 20),
      tooltip: 'View Menu',
      onPressed: () {
        TecAutoScroll.stopAutoscroll();
        showTecModalPopupMenu(
          context: context,
          insets: vmBloc.insetsOfView(state.uid),
          alignment: Alignment.topRight,
          minWidth: 125,
          menuItemsBuilder: (menuContext) => buildMenuItemsForViewWithState(
            state,
            context: context,
            menuContext: menuContext,
          ),
        );
      },
    ),
    if (isTopRightView) const SizedBox(width: 40),
    // IconButton(
    //   icon: const Icon(SFSymbols.person_crop_circle),
    //   tooltip: 'Main Menu',
    //   onPressed: () => showMainMenu(context),
    // ),
  ];
}

List<TableRow> buildMenuItemsForViewWithState(
  ViewState state, {
  BuildContext context,
  BuildContext menuContext,
}) {
  // ignore: close_sinks
  final vmBloc = context.viewManager;
  final isMaximized = vmBloc?.state?.maximizedViewUid != 0;

  final viewData = VolumeViewData.fromContext(context, state.uid);
  final useSharedRef = viewData.useSharedRef;

  final items = <TableRow>[];

  if ((vmBloc?.state?.views?.length ?? 0) > 1) {
    items.add(tecModalPopupMenuDivider(menuContext, title: 'View options'));

    if (isMaximized) {
      items.add(tecModalPopupMenuItem(
          menuContext,
          vmBloc.numViewsLimited
              ? ((MediaQuery.of(context).orientation == Orientation.landscape)
                  ? Icons.vertical_split_outlined
                  : Icons.horizontal_split_outlined)
              : FeatherIcons.minimize2,
          vmBloc.numViewsLimited ? 'Split screen' : 'Restore', () {
        Navigator.of(menuContext).maybePop();
        vmBloc?.restore();
      }));
    } else {
      items.add(tecModalPopupMenuItem(
          menuContext,
          vmBloc.numViewsLimited ? Icons.article_outlined : FeatherIcons.maximize2,
          vmBloc.numViewsLimited ? 'Full screen' : 'Maximize', () {
        Navigator.of(menuContext).maybePop();
        vmBloc?.maximize(state.uid);
      }));
    }

    if ((vmBloc?.countOfVisibleViews ?? 0) > 1) {
      items.add(tecModalPopupMenuItem(menuContext,
          vmBloc.numViewsLimited ? Icons.article_outlined : FeatherIcons.eyeOff, 'Hide', () {
        Navigator.of(menuContext).maybePop();
        vmBloc?.hide(state.uid);
      }));
    }

    if (state.type == Const.viewTypeVolume) {
      items.add(tecModalPopupMenuItem(
        menuContext,
        useSharedRef ? Icons.link_off_outlined : Icons.link_outlined,
        useSharedRef ? 'Unlink chapter' : 'Link chapter',
        () {
          Navigator.of(menuContext).maybePop();
          final viewDataBloc = context.tbloc<VolumeViewDataBloc>();
          assert(viewDataBloc != null);
          viewDataBloc?.update(context, viewData.copyWith(useSharedRef: !useSharedRef));
        },
      ));
    }

    items.add(tecModalPopupMenuItem(menuContext, Icons.close, 'Close', () {
      Navigator.of(menuContext).maybePop();
      var nextMaxUid = -1;

      // on a phone - if maximized, maximize the underneath one
      if (state.uid == vmBloc?.state?.maximizedViewUid &&
          (vmBloc?.numViewsLimited ?? false) &&
          (vmBloc?.state?.views?.length ?? 0) > 2) {
        final views = vmBloc?.state?.views;
        if (vmBloc.indexOfView(vmBloc.state.maximizedViewUid) == vmBloc.state.views.length - 1) {
          nextMaxUid = views.first.uid;
        } else {
          nextMaxUid = views
              .firstWhere((v) =>
                  vmBloc.indexOfView(v.uid) ==
                  vmBloc.indexOfView(vmBloc.state.maximizedViewUid) + 1)
              .uid;
        }
      }

      vmBloc?.remove(state.uid);

      if (nextMaxUid > 0) {
        vmBloc?.maximize(nextMaxUid);
      }
    }));
  }

  if (((vmBloc?.countOfInvisibleViews ?? 0) >= 1)) {
    items.addAll([
      tecModalPopupMenuDivider(menuContext, title: 'Restore'),
      ..._generateOffScreenItems(menuContext, state.uid),
    ]);
  }

  items.addAll([
    tecModalPopupMenuDivider(menuContext, title: 'Open new'),
    ...generateAddMenuItems(menuContext, state.uid),
  ]);

  return items;
}

void _onSwitchViews(ViewManagerBloc vmBloc, int viewUid, ViewState view) {
  if (vmBloc.state.maximizedViewUid == viewUid) {
    vmBloc?.maximize(view.uid);
  } else {
    vmBloc?.show(view.uid);
  }
}

Iterable<TableRow> _generateOffScreenItems(BuildContext menuContext, int viewUid) {
  // ignore: close_sinks
  final vmBloc = menuContext.viewManager;
  final vm = ViewManager.shared;
  final items = <TableRow>[];
  for (final view in vmBloc?.state?.views) {
    if (!vmBloc.isViewVisible(view.uid)) {
      final title = vm.menuTitleWith(context: menuContext, state: view);
      items.add(tecModalPopupMenuItem(menuContext, vm.iconWithType(view.type), '$title', () {
        _onSwitchViews(vmBloc, viewUid, view);
        Navigator.of(menuContext).maybePop();
      }));
    }
  }
  return items;
}

Iterable<TableRow> generateAddMenuItems(BuildContext menuContext, int viewUid) {
  assert(menuContext != null && viewUid != null);
  final vm = ViewManager.shared;
  return vm.types.expand<TableRow>((type) {
    // Types that cannot be created from the menu return `null` for the menu title.
    final title = vm.menuTitleWith(type: type);
    if (title == null) return [];

    TableRow row({String title, IconData icon, String tab}) =>
        tecModalPopupMenuItem(menuContext, icon ?? vm.iconWithType(type), '$title', () async {
          tec.dmPrint('Adding new view of type $type.');
          await vm.onAddView(menuContext, type,
              currentViewId: viewUid, options: tab == null ? null : <String, dynamic>{'tab': tab});
          await Navigator.of(menuContext).maybePop();
        });

    if (type == Const.viewTypeVolume) {
      return [
        row(title: 'Bible', icon: FeatherIcons.bookOpen, tab: 'Bible'),
        row(title: 'Study Bible', icon: FeatherIcons.bookOpen, tab: 'Study'),
        row(title: 'Commentary', icon: FeatherIcons.bookOpen, tab: 'Commentaries'),
        row(title: 'Devotional', icon: FeatherIcons.bookOpen, tab: 'Devotional'),
      ];
    } else {
      return [row(title: title)];
    }
  });
}

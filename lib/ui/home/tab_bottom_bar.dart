import 'package:bible/ui/ugc/ugc_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/sheet/tab_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/const.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../common/tec_page_route.dart';
import 'expandable_fab.dart';

class TabBottomBarItem {
  final TecTab tab;
  final IconData icon;
  final String label;
  final Widget widget;

  const TabBottomBarItem({this.tab, this.icon, this.label, this.widget});
}

class TabBottomBar extends StatefulWidget {
  final List<TabBottomBarItem> tabs;

  const TabBottomBar({Key key, @required this.tabs}) : super(key: key);

  @override
  _TabBottomBarState createState() => _TabBottomBarState();
}

class _TabBottomBarState extends State<TabBottomBar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabManagerBloc, TabManagerState>(buildWhen: (p, n) {
      return p.tab != n.tab;
    }, builder: (context, tabState) {
      return Scaffold(
        drawer: const UGCView(),
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: (tabState.tab == TecTab.reader)
            ? BlocBuilder<SheetManagerBloc, SheetManagerState>(
                builder: (context, sheetState) {
                  return AnimatedOpacity(
                    opacity: (sheetState.type == SheetType.main) ? 1.0 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: _ReaderFAB(tabs: widget.tabs),
                    ),
                  );
                },
              )
            : _TabFAB(),
        bottomNavigationBar: (tabState.tab == TecTab.reader) ? null : TecTabBar(tabs: widget.tabs),
        body: Container(
          color: Theme.of(context).backgroundColor,
          child: SafeArea(
            left: false,
            right: false,
            bottom: false,
            child: Stack(
              children: [
                for (var i = 0; i < widget.tabs.length; i++)
                  Visibility(
                    maintainState: true,
                    visible: widget.tabs[i].tab == tabState.tab,
                    child: Navigator(
                      key: ValueKey(i),
                      onGenerateRoute: (settings) => TecPageRoute<dynamic>(
                        settings: settings,
                        builder: (context) {
                          return widget.tabs[i].widget;
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _TabFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 2,
      onPressed: () => context.tabManager.add(TecTab.reader),
      backgroundColor: Colors.white,
      child: const Icon(TecIcons.tecartabiblelogo, color: Const.tecartaBlue, size: 28),
    );
  }
}

class _ReaderFAB extends StatelessWidget {
  final List<TabBottomBarItem> tabs;

  const _ReaderFAB({Key key, @required this.tabs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // void _onSwitchViews(ViewManagerBloc vmBloc, int viewUid, ViewState view) {
    //   if (vmBloc.state.maximizedViewUid == viewUid) {
    //     vmBloc?.add(ViewManagerEvent.maximize(view.uid));
    //   } else {
    //     final thisViewPos = vmBloc.indexOfView(viewUid);
    //     final hiddenViewPos = vmBloc.indexOfView(view.uid);
    //     vmBloc?.add(ViewManagerEvent.move(
    //         fromPosition: vmBloc.indexOfView(view.uid), toPosition: vmBloc.indexOfView(viewUid)));
    //     vmBloc
    //         ?.add(ViewManagerEvent.move(fromPosition: thisViewPos + 1, toPosition: hiddenViewPos));
    //   }
    // }

    List<FABIcon> offScreenViews(BuildContext context) {
      final vm = ViewManager.shared;
      final items = <FABIcon>[];
      for (final view in context.viewManager?.state?.views) {
        if (!context.viewManager.isViewVisible(view.uid)) {
          final title = vm.menuTitleWith(context: context, state: view);
          items.add(FABIcon(
              title: title,
              onPressed: () {
                // for now, don't add functionality
                // _onSwitchViews(vmBloc, viewUid, view);
                // Navigator.of(menuContext).maybePop();
              },
              iconData: Icons.ac_unit));
          // items.add(tecModalPopupMenuItem(menuContext, vm.iconWithType(view.type), '$title', () {

          // }));
        }
      }
      return items;
    }

    return ExpandableFAB(
      icons: offScreenViews(context),
      backgroundColor: Const.tecartaBlue,
      mainIcon: TecIcons.tecartabiblelogo,
      tabs: tabs,
    );
  }
}

class TecTabBar extends StatelessWidget {
  final VoidCallback pressedCallback;
  final List<TabBottomBarItem> tabs;
  final TabManagerBloc tabManager;

  const TecTabBar({@required this.tabs, this.pressedCallback, this.tabManager});

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final tm = (tabManager == null) ? context.tabManager : tabManager;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 65, top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final tabItem in tabs)
              if (tabItem.icon != null)
                SheetIconButton(
                  icon: tabItem.icon,
                  text: tabItem.label,
                  color: tm.state.tab == tabItem.tab ? Const.tecartaBlue : null,
                  onPressed: () {
                    if (pressedCallback != null) {
                      pressedCallback();
                    }

                    tm.add(tabItem.tab);
                  },
                ),
          ],
        ),
      ),
    );
  }
}

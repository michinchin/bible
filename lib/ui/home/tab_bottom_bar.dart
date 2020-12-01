import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/sheet/tab_manager_bloc.dart';
import '../../models/const.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../common/tec_page_route.dart';
import '../ugc/ugc_view.dart';
import 'reader_fab.dart';

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
      // if the tab didn't change or we're showing the overlay...
      return p.tab != n.tab && n.tab != TecTab.overlay;
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
                      child: ReaderFAB(
                        backgroundColor: Const.tecartaBlue,
                        mainIcon: TecIcons.tecartabiblelogo,
                        tabs: widget.tabs,
                      ),
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
      color: Theme.of(context).appBarTheme.color,
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

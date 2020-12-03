import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/sheet/tab_manager_bloc.dart';
import '../../models/const.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../common/common.dart';
import '../common/tec_navigator.dart';
import '../common/tec_page_route.dart';
import 'home_screen.dart';

class TabBottomBarItem {
  final TecTab tab;
  final IconData icon;
  final String label;
  final Widget widget;

  const TabBottomBarItem({
    this.tab,
    this.icon,
    this.label,
    this.widget,
  });
}

class TabScaffoldWrap extends StatefulWidget {
  final List<TabBottomBarItem> tabs;
  final TecTab currentTab;

  const TabScaffoldWrap({Key key, @required this.tabs, @required this.currentTab})
      : super(key: key);

  @override
  _TabScaffoldWrapState createState() => _TabScaffoldWrapState();
}

class _TabScaffoldWrapState extends State<TabScaffoldWrap> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabManagerCubit, TecTab>(buildWhen: (p, n) {
      // if the tab didn't change or we're showing the overlay...
      return p != n && n != TecTab.overlay;
    }, builder: (context, tab) {
      return Scaffold(
        // drawer: const UGCView(),
        backgroundColor: Colors.transparent,
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: _TabFAB(),
        bottomNavigationBar: TecTabBar(
          tabs: widget.tabs,
          tabManager: context.tabManager,
        ),
        body: Stack(
          children: [
            for (var i = 0; i < widget.tabs.length; i++)
              Visibility(
                maintainState: true,
                visible: widget.tabs[i].tab == tab,
                child: NavigatorWithHeroController(
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
      );
    });
  }
}

// : TecTabBar(tabs: tabs),S
class _TabFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 2,
      onPressed: () {
        Navigator.of(context).pop();
      },
      backgroundColor: Colors.white,
      child: const Icon(TecIcons.tecartabiblelogo, color: Const.tecartaBlue, size: 28),
    );
  }
}

class TecTabBar extends StatelessWidget {
  final VoidCallback pressedCallback;
  final List<TabBottomBarItem> tabs;
  final TabManagerCubit tabManager;

  const TecTabBar({@required this.tabs, this.pressedCallback, this.tabManager});

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    // final tm = (tabManager == null) ? context.tabManager : tabManager;

    return BottomAppBar(
      elevation: 10,
      color: Theme.of(context).appBarTheme.color,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Padding(
        padding: EdgeInsets.only(
            left: 15, right: 65, top: 15, bottom: TecScaffoldWrapper.navigationBarPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final tabItem in tabs)
              if (tabItem.icon != null)
                SheetIconButton(
                  icon: tabItem.icon,
                  text: tabItem.label,
                  color: tabManager != null
                      ? (tabManager.state == tabItem.tab ? Const.tecartaBlue : null)
                      : null,
                  onPressed: () {
                    if (pressedCallback != null) {
                      pressedCallback();
                    }
                    if (tabManager == null) {
                      showTabView(context: context, tab: tabItem.tab, tabs: tabs);
                    } else {
                      tabManager.changeTab(tabItem.tab);
                    }
                  },
                ),
          ],
        ),
      ),
    );
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TecTab { today, library, plans, store, reader, switcher }
enum TecTabEvent {
  today,
  library,
  plans,
  store,
  reader,
  switcher,
  hideTabBar,
  showTabBar,
}

// barHiddenState - maintains whether a tab has currently hidden the tab bar
// i.e. viewing VOTD - which hides the bar, tap bible switches to reader, shows the bar
// switching back to Today tab should rehide the bar
// hitting back from the votd screen reshows the bar in the today tab

class TabManagerState extends Equatable {
  final TecTab tab;
  final bool hideBottomBar;
  final Map<TecTab, bool> barHiddenState;

  const TabManagerState(this.tab, this.barHiddenState, {this.hideBottomBar = false});

  @override
  List<Object> get props => [tab.index, hideBottomBar];
}

class TabManagerBloc extends Bloc<TecTabEvent, TabManagerState> {
  TabManagerBloc() : super(const TabManagerState(TecTab.today, <TecTab, bool>{}));

  @override
  Stream<TabManagerState> mapEventToState(TecTabEvent event) async* {
    switch (event) {
      case TecTabEvent.today:
      case TecTabEvent.library:
      case TecTabEvent.plans:
      case TecTabEvent.store:
      case TecTabEvent.reader:
      case TecTabEvent.switcher:
        yield TabManagerState(TecTab.values[event.index], state.barHiddenState,
            hideBottomBar: state.barHiddenState[TecTab.values[event.index]] ?? false);
        break;
      case TecTabEvent.hideTabBar:
        final map = Map<TecTab, bool>.from(state.barHiddenState);
        map[state.tab] = true;
        yield TabManagerState(state.tab, map, hideBottomBar: true);
        break;
      case TecTabEvent.showTabBar:
        final map = Map<TecTab, bool>.from(state.barHiddenState);
        map[state.tab] = false;
        yield TabManagerState(state.tab, map, hideBottomBar: false);
        break;
    }
  }

  void changeTab(TecTab tab) {
    add(TecTabEvent.values[tab.index]);
  }
}

extension TabManagerExtOnBuildContext on BuildContext {
  TabManagerBloc get tabManager => BlocProvider.of<TabManagerBloc>(this);
}

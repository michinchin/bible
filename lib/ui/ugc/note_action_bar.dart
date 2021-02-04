import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_views/tec_views.dart';

import '../common/common.dart';
import '../common/tec_action_bar.dart';
import '../common/tec_modal_popup_menu.dart';
import '../menu/view_actions.dart';

class NoteViewActionBar extends StatelessWidget {
  final ViewState state;
  final Size size;

  const NoteViewActionBar({Key key, @required this.state, @required this.size})
      : assert(state != null && size != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionBar(
      viewUid: state.uid,
      elevation: defaultActionBarElevation,
      items: [
        ActionBarItem(
          title: 'Note',
          priority: 0,
          icon: const Icon(FeatherIcons.chevronDown),
          onTap: () {
            showTecModalPopupMenu(
              context: context,
              insets: context.viewManager.insetsOfView(state.uid),
              alignment: Alignment.topCenter,
              minWidth: 125,
              menuItemsBuilder: (menuContext) => buildMenuItemsForViewWithState(
                state,
                context: context,
                menuContext: menuContext,
              ),
            );
          },
        ),
      ],
    );
  }
}

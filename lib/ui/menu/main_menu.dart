import 'package:bible/ui/menu/zendesk_help.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_user_account/tec_user_account_ui.dart' as tua;
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../common/tec_modal_popup_menu.dart';
import 'main_menu_model.dart';
import 'notifications_view.dart';
import 'settings.dart';

Future<void> showMainMenu(BuildContext context) {
  TecAutoScroll.stopAutoscroll();
  return showTecModalPopupMenu(
    context: context,
    insets: const EdgeInsets.symmetric(horizontal: 15),
    menuItemsBuilder: (menuContext) => _buildMenuItems(
      MainMenuModel(),
      context: context,
      menuContext: menuContext,
    ),
  );
}

List<TableRow> _buildMenuItems(
  MainMenuModel menuModel, {
  BuildContext context,
  BuildContext menuContext,
}) {
  const rowPadding = 20.0;

  return [
    tecModalPopupMenuTitle('TecartaBible', showClose: true),
    tecModalPopupMenuItem(
      menuContext,
      FeatherIcons.user,
      AppSettings.shared.userAccount.isSignedIn
          ? '${AppSettings.shared.userAccount.user.email}'
          : 'Account',
      () {
        Navigator.of(menuContext).pop();
        tua.showSignInDlg(
            context: menuContext,
            account: AppSettings.shared.userAccount,
            useRootNavigator: true,
            appName: Const.appNameForUA);
      },
      rowPadding: rowPadding,
      scaleFont: true,
      // subtitle: AppSettings.shared.userAccount.isSignedIn
      //     ? '${AppSettings.shared.userAccount.user.firstName}'
      //     : 'Sign in'
    ),
    // tecModalPopupMenuItem(
    //   menuContext,
    //   tec.platformIs(tec.Platform.iOS) ? FeatherIcons.share : FeatherIcons.share2,
    //   'Share app',
    //   () => menuModel.shareApp(menuContext),
    // ),
    tecModalPopupMenuDivider(menuContext, rowPadding: rowPadding),

    tecModalPopupMenuItem(
        menuContext, FeatherIcons.bell, 'Notifications', () => showNotifications(context),
        subtitle: 'Reminders for daily verse, devotional of the day, and more.',
        rowPadding: rowPadding,
        scaleFont: true),

    tecModalPopupMenuDivider(menuContext, rowPadding: rowPadding),
    tecModalPopupMenuItem(
        menuContext, FeatherIcons.settings, 'Settings', () => showSettings(context),
        subtitle: 'Font Size, line spacing, dark mode', rowPadding: rowPadding, scaleFont: true),
    // if (tec.platformIs(tec.Platform.iOS))
    //   tecModalPopupMenuItem(
    //     menuContext,
    //     Icons.restore,
    //     'Restore Purchases',
    //     null,
    //   ),
    tecModalPopupMenuDivider(menuContext, rowPadding: rowPadding),

    tecModalPopupMenuItem(
        menuContext, FeatherIcons.info, 'About', () => menuModel.showAboutDialog(menuContext),
        subtitle: 'App Info, version number, website link',
        rowPadding: rowPadding,
        scaleFont: true),
        
    tecModalPopupMenuDivider(menuContext, rowPadding: rowPadding),

    tecModalPopupMenuItem(
        menuContext, FeatherIcons.helpCircle, 'Help Desk', () => showZendeskHelp(menuContext),
        subtitle: 'FAQ & Other Help Questions', rowPadding: rowPadding, scaleFont: true),
  ];
}

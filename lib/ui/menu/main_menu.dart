import 'package:bible/ui/menu/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_user_account/tec_user_account_ui.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/app_theme_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../models/pref_item.dart';
import '../common/tec_modal_popup_menu.dart';
import '../misc/text_settings.dart';
import 'main_menu_model.dart';

const tecartaBlue = Color(0xff4a7dee);

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
  return [
    TableRow(children: [
      AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const CloseButton(),
        title: const Text('Tecarta'),
      ),
      TableRowInkWell(
        onTap: null,
        child: Container(),
      )
    ]),
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
    tecModalPopupMenuDivider(menuContext),

    tecModalPopupMenuItem(menuContext, FeatherIcons.bell, 'Notifications', null,
        subtitle: 'Reminders for daily verse, devotional of the day, and more.'),

    tecModalPopupMenuDivider(menuContext),
    tecModalPopupMenuItem(
        menuContext, FeatherIcons.settings, 'Settings', () => showSettings(context),
        subtitle: 'Font Size, line spacing, dark mode'),
    // if (tec.platformIs(tec.Platform.iOS))
    //   tecModalPopupMenuItem(
    //     menuContext,
    //     Icons.restore,
    //     'Restore Purchases',
    //     null,
    //   ),
    tecModalPopupMenuDivider(menuContext),

    tecModalPopupMenuItem(menuContext, FeatherIcons.helpCircle, 'Help & Feedback',
        () => menuModel.emailFeedback(menuContext),
        subtitle: 'App Features, Support, and FAQs'),
    tecModalPopupMenuDivider(menuContext),

    tecModalPopupMenuItem(
        menuContext, FeatherIcons.info, 'About', () => menuModel.showAboutDialog(menuContext),
        subtitle: 'App Info, version number, website link'),
  ];
}

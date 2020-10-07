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
  final prefBloc = context.bloc<PrefItemsBloc>(); //ignore: close_sinks
  return [
    tecModalPopupMenuItem(
      menuContext,
      tec.platformIs(tec.Platform.iOS) ? FeatherIcons.share : FeatherIcons.share2,
      'Share app',
      () => menuModel.shareApp(menuContext),
    ),
    tecModalPopupMenuItem(
      menuContext,
      FeatherIcons.bell,
      'Notifications',
      null,
    ),
    tecModalPopupMenuItem(
      menuContext,
      Icons.lightbulb_outline,
      'Dark theme',
      () => context.bloc<ThemeModeBloc>().add(ThemeModeEvent.toggle),
      getSwitchValue: AppSettings.shared.isDarkTheme,
    ),
    tecModalPopupMenuItem(
      menuContext,
      Icons.link,
      'Include Link in Copy/Share',
      () => prefBloc.add(
          PrefItemEvent.update(prefItem: prefBloc.toggledPrefItem(PrefItemId.includeShareLink))),
      getSwitchValue: () => prefBloc.itemBool(PrefItemId.includeShareLink),
    ),
    tecModalPopupMenuItem(
      menuContext,
      Icons.play_circle_outline,
      'Autoscroll',
      () => TecAutoScroll.setEnabled(enabled: !TecAutoScroll.isEnabled()),
      getSwitchValue: TecAutoScroll.isEnabled,
    ),
    tecModalPopupMenuItem(
      menuContext,
      Icons.format_size,
      'Text Settings',
      () {
        Navigator.of(menuContext).pop();
        showTextSettingsDialog(menuContext);
      },
    ),
    tecModalPopupMenuDivider(menuContext),
    tecModalPopupMenuItem(
        menuContext,
        FeatherIcons.user,
        AppSettings.shared.userAccount.isSignedIn
            ? '${AppSettings.shared.userAccount.user.email}'
            : 'Account', () {
      Navigator.of(menuContext).pop();
      tua.showSignInDlg(
          context: menuContext,
          account: AppSettings.shared.userAccount,
          useRootNavigator: true,
          appName: Const.appNameForUA);
    }),
    if (tec.platformIs(tec.Platform.iOS))
      tecModalPopupMenuItem(
        menuContext,
        Icons.restore,
        'Restore Purchases',
        null,
      ),
    tecModalPopupMenuItem(
      menuContext,
      FeatherIcons.helpCircle,
      'Help & Feedback',
      () => menuModel.emailFeedback(menuContext),
    ),
    tecModalPopupMenuItem(
      menuContext,
      FeatherIcons.info,
      'About',
      () => menuModel.showAboutDialog(menuContext),
    ),
  ];
}

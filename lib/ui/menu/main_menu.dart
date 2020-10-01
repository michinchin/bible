import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_user_account/tec_user_account_ui.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/app_theme_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/labels.dart';
import '../../models/pref_item.dart';
import '../common/common.dart';
import '../misc/text_settings.dart';
import 'menu_model.dart';

const tecartaBlue = Color(0xff4a7dee);

Future<void> showMainMenu(BuildContext context) {
  TecAutoScroll.stopAutoscroll();

  return showTecModalPopup<void>(
    useRootNavigator: true,
    context: context,
    alignment: Alignment.topRight,
    builder: (context) {
      return TecPopupSheet(
        child: MainMenu(menuModel: MenuModel()),
      );
    },
  );
}

class MainMenu extends StatefulWidget {
  final MenuModel menuModel;
  const MainMenu({this.menuModel});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    final prefBloc = context.bloc<PrefItemsBloc>(); //ignore: close_sinks
    final textScaleFactor = scaleFactorWith(context, maxScaleFactor: 1.2);
    final iconSize = (24.0 * textScaleFactor).roundToDouble();

    TableRow _tableRow({
      IconData icon,
      String title,
      bool Function() switchValue,
      GestureTapCallback onTap,
    }) {
      final textColor = Theme.of(context).textColor.withOpacity(onTap == null ? 0.2 : 0.5);
      Widget _cell(Widget child) => TableRowInkWell(
            onTap: onTap == null ? null : () => setState(() => onTap()),
            child: child,
          );

      return TableRow(
        children: [
          _cell(icon == null ? Container() : Icon(icon, color: textColor, size: iconSize)),
          _cell(
            Container(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
              child: TecText(
                title,
                textScaleFactor: textScaleFactor,
                style: TextStyle(color: textColor),
              ),
            ),
          ),
          _cell(
            switchValue == null
                ? Container(padding: const EdgeInsets.fromLTRB(0, 16, 0, 16))
                : Switch.adaptive(
                    activeColor: tecartaBlue,
                    value: switchValue() ?? false,
                    onChanged: onTap == null ? null : (_) => setState(() => onTap()),
                  ),
          ),
        ],
      );
    }

    TableRow _divider() =>
        TableRow(decoration: BoxDecoration(color: Theme.of(context).dividerColor), children: [
          const SizedBox(width: 1, height: 1),
          Container(),
          Container(),
        ]);

    return Material(
      color: Colors.transparent, // Theme.of(context).scaffoldBackgroundColor,
      child: Table(
        columnWidths: {
          0: FixedColumnWidth(iconSize),
        },
        defaultColumnWidth: const IntrinsicColumnWidth(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _tableRow(
            icon: tec.platformIs(tec.Platform.iOS) ? FeatherIcons.share : FeatherIcons.share2,
            title: 'Share app',
            onTap: () => widget.menuModel.shareApp(context),
          ),
          _tableRow(
            icon: FeatherIcons.bell,
            title: 'Notifications',
            onTap: null,
          ),
          _tableRow(
            icon: Icons.lightbulb_outline,
            switchValue: AppSettings.shared.isDarkTheme,
            title: 'Dark theme',
            onTap: () => context.bloc<ThemeModeBloc>().add(ThemeModeEvent.toggle),
          ),
          _tableRow(
            icon: Icons.link,
            switchValue: () => prefBloc.itemBool(PrefItemId.includeShareLink),
            title: 'Include Link in Copy/Share',
            onTap: () {
              prefBloc.add(PrefItemEvent.update(
                  prefItem: prefBloc.toggledPrefItem(PrefItemId.includeShareLink)));
            },
          ),
          _tableRow(
            title: 'Autoscroll',
            icon: Icons.play_circle_outline,
            switchValue: TecAutoScroll.isEnabled,
            onTap: () => TecAutoScroll.setEnabled(enabled: !TecAutoScroll.isEnabled()),
          ),
          _tableRow(
            icon: Icons.format_size,
            title: 'Text Settings',
            onTap: () {
              Navigator.of(context).pop();
              showTextSettingsDialog(context);
            },
          ),
          _divider(),
          _tableRow(
              icon: FeatherIcons.user,
              title: AppSettings.shared.userAccount.isSignedIn
                  ? '${AppSettings.shared.userAccount.user.email}'
                  : 'Account',
              onTap: () {
                Navigator.of(context).pop();
                tua.showSignInDlg(
                    context: context,
                    account: AppSettings.shared.userAccount,
                    useRootNavigator: true,
                    appName: Labels.appNameForUA);
              }),
          if (tec.platformIs(tec.Platform.iOS))
            _tableRow(
              icon: Icons.restore,
              title: 'Restore Purchases',
              onTap: null,
            ),
          _tableRow(
            icon: FeatherIcons.helpCircle,
            title: 'Help & Feedback',
            onTap: () => widget.menuModel.emailFeedback(context),
          ),
          _tableRow(
            icon: FeatherIcons.info,
            title: 'About',
            onTap: () => widget.menuModel.showAboutDialog(context),
          ),
        ],
      ),
    );
  }
}

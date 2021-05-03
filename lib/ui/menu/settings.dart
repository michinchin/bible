import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:tec_bloc/tec_bloc.dart';
import 'package:tec_user_account/tec_user_account_ui.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../blocs/app_theme_bloc.dart';
import '../../blocs/prefs_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../models/notifications/notifications_model.dart';
import '../../models/pref_item.dart';
import '../common/common.dart';
import '../misc/text_settings.dart';
import '../volume/volume_view_data_bloc.dart';
import 'main_menu_model.dart';
import 'zendesk_help.dart';

void showSettings(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
        builder: (c) => SettingsView(
              menuModel: MainMenuModel(),
            ),
        fullscreenDialog: true));

class SettingsView extends StatefulWidget {
  final MainMenuModel menuModel;

  const SettingsView({Key key, this.menuModel}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final isSignedIn = AppSettings.shared.userAccount.isSignedIn;
    return Scaffold(
      appBar: MinHeightAppBar(
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
      ),
      body: Container(
          color: Theme.of(context).canvasColor,
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10),
                Expanded(
                  child: ListView(children: [
                    _TitleSettingTile(
                      title: isSignedIn ? AppSettings.shared.userAccount.user.email : 'Account',
                      icon: FeatherIcons.user,
                      subtitle: 'Edit and manage your account details.',
                    ),
                    _SecondaryTiles(accountTiles(context)),
                    const _TitleSettingTile(
                      title: 'Read',
                      icon: FeatherIcons.book,
                      subtitle: 'Adjust how you read your Bible',
                    ),
                    _SecondaryTiles(readTiles(context)),
                    const _TitleSettingTile(
                      title: 'Notifications',
                      icon: FeatherIcons.bell,
                      subtitle: 'Manage your reminders',
                    ),
                    _GreyContainer(
                      child: ListTile(
                        dense: true,
                        leading: const Icon(FeatherIcons.sun),
                        title: const Text('Daily notifications'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => NotificationsModel.showNotificationsView(context),
                      ),
                    ),
                    const _TitleSettingTile(
                        title: 'Audio',
                        subtitle: 'Adjust how you listen to your Bible',
                        icon: FeatherIcons.volume2),
                    const _GreyContainer(
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.record_voice_over_outlined),
                        title: Text('Voice'),
                        trailing: Icon(Icons.chevron_right),
                      ),
                    ),
                    const _TitleSettingTile(
                      title: 'About',
                      icon: FeatherIcons.smartphone,
                      subtitle: 'More about the app',
                    ),
                    _SecondaryTiles(aboutTiles(context)),
                    const _TitleSettingTile(
                      title: 'Help',
                      subtitle: 'Get quick assistance',
                      icon: FeatherIcons.helpCircle,
                    ),
                    _SecondaryTiles(helpTiles(context)),
                  ]),
                )
              ],
            ),
          )),
    );
  }

  List<Widget> accountTiles(BuildContext context) {
    if (AppSettings.shared.userAccount.isSignedIn) {
      final lastSyncTime = tec.dateTimeFromDbInt(AppSettings.shared.userAccount.user.lastSyncTime);
      return [
        ListTile(
          dense: true,
          leading: const Icon(FeatherIcons.refreshCcw),
          title: const Text('Sync Now'),
          trailing: Text(
            'Last synced: ${tec.shortDate(lastSyncTime)}',
            style: const TextStyle(fontSize: 10),
          ),
          onTap: () async {
            await tecShowProgressDlg(
                context: context,
                title: 'Syncing',
                future: AppSettings.shared.userAccount.syncUserDb<void>(fullSync: true));
            TecToast.show(context, 'Success');
          },
        ),
        ListTile(
          dense: true,
          leading: const Icon(FeatherIcons.mail),
          title: const Text('Change email'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          dense: true,
          leading: const Icon(FeatherIcons.key),
          title: const Text('Change password'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          dense: true,
          leading: const Icon(FeatherIcons.logOut),
          title: const Text('Sign Out'),
          onTap: () async {
            await tecShowProgressDlg(
                context: context,
                title: 'Signing out',
                future: AppSettings.shared.userAccount.logOut<void>());
            setState(() {});
          },
        ),
      ];
    } else {
      return [
        ListTile(
          dense: true,
          leading: const Icon(FeatherIcons.logIn),
          title: const Text('Sign In'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            await tua.showSignInDlg(
                context: context,
                account: AppSettings.shared.userAccount,
                appName: Const.appNameForUA);
            setState(() {});
          },
        ),
      ];
    }
  }

  List<Widget> aboutTiles(BuildContext context) {
    return [
      ListTile(
        dense: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Version',
              style: TextStyle(fontSize: 10),
            ),
            Text(
              AppSettings.shared.deviceInfo.version,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      ListTile(
        dense: true,
        leading: const Icon(Icons.public),
        title: const Text('Website'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => launcher.launch(Const.tecartaBibleLink),
      ),
      ListTile(
        dense: true,
        leading: const Icon(Icons.description),
        title: const Text('Terms Of Service'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => launcher.launch(Const.termsLink),
      ),
      ListTile(
        dense: true,
        leading: const Icon(FeatherIcons.lock),
        title: const Text('Privacy Policy'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => launcher.launch(Const.privacyLink),
      )
    ];
  }

  List<Widget> helpTiles(BuildContext context) {
    return [
      ListTile(
        dense: true,
        leading: const Icon(Icons.info_outline),
        title: const Text('FAQs'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showZendeskHelp(context),
      ),
      ListTile(
          dense: true,
          leading: const Icon(FeatherIcons.mail),
          title: const Text('Email Feedback'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => MainMenuModel().emailFeedback(context)),
    ];
  }

  List<Widget> readTiles(BuildContext context) {
    // final color = Theme.of(context).textColor;
    // final textStyle = TextStyle(fontSize: 15, color: color);

    return [
      _SettingsSwitch(
          secondary: const Icon(FeatherIcons.moon),
          title: const Text('Dark theme'),
          onChanged: () => context.tbloc<ThemeModeBloc>().add(ThemeModeEvent.toggle),
          value: AppSettings.shared.isDarkTheme()),
      _SettingsSwitch(
        secondary: const Icon(Icons.sync_alt),
        title: const Text('Sync chapter'),
        onChanged: () {
          final useSharedRef = PrefsBloc.toggle(PrefItemId.syncChapter);

          // update open views...
          BookChapterVerse bcv;

          for (final view in context.viewManager?.state?.views) {
            final viewDataBloc = context.viewManager.dataBlocWithView(view.uid);
            final viewData = viewDataBloc?.state;
            if (viewData is VolumeViewData) {
              bcv ??= viewData.bcv;
              viewDataBloc?.update(
                  context, viewData.copyWith(useSharedRef: useSharedRef, bcv: bcv));
            }
          }
        },
        value: PrefsBloc.getBool(PrefItemId.syncChapter),
      ),
      BlocBuilder<PrefsBloc, PrefBlocState>(builder: (context, state) {
        return _SettingsSwitch(
          enabled: PrefsBloc.getBool(PrefItemId.syncChapter),
          secondary: Transform.rotate(angle: 90 * math.pi / 180, child: const Icon(Icons.sync_alt)),
          title: const Text('Sync verse'),
          onChanged: () => PrefsBloc.toggle(PrefItemId.syncVerse),
          value: PrefsBloc.getBool(PrefItemId.syncVerse),
        );
      }),
      _SettingsSwitch(
        secondary: const Icon(Icons.link),
        title: const Text('Include Link with Share'),
        onChanged: () => PrefsBloc.toggle(PrefItemId.includeShareLink),
        value: PrefsBloc.getBool(PrefItemId.includeShareLink),
      ),
      _SettingsSwitch(
        secondary: const Icon(Icons.close),
        title: const Text('Close Sheet after Copy/Share'),
        onChanged: () => PrefsBloc.toggle(PrefItemId.closeAfterCopyShare),
        value: PrefsBloc.getBool(PrefItemId.closeAfterCopyShare),
      ),
      _SettingsSwitch(
        secondary: const Icon(Icons.unfold_more),
        title: const Text('Autoscroll'),
        onChanged: () => TecAutoScroll.setEnabled(enabled: !TecAutoScroll.isEnabled()),
        value: TecAutoScroll.isEnabled(),
      ),
      ListTile(
        dense: true,
        leading: const Icon(Icons.format_size),
        title: const Text('Text Settings'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          while (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
          showTextSettingsDialog(context);
        },
      )
    ];
  }
}

class _GreyContainer extends StatelessWidget {
  final Widget child;
  const _GreyContainer({this.child});
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
        decoration: ShapeDecoration(
            color: isDarkMode ? Theme.of(context).cardColor : const Color(0xFFF0F0F0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        margin: const EdgeInsets.all(15),
        child: child);
  }
}

class _SecondaryTiles extends StatelessWidget {
  final List<Widget> tiles;
  const _SecondaryTiles(this.tiles);
  @override
  Widget build(BuildContext context) {
    return _GreyContainer(
      child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (c, i) => const Divider(
                height: 5,
                indent: 10,
                endIndent: 10,
              ),
          itemCount: tiles.length,
          itemBuilder: (c, i) => tiles[i]),
    );
  }
}

class _SettingsSwitch extends StatefulWidget {
  final bool value;
  final Function onChanged;
  final Widget title;
  final Widget secondary;
  final bool enabled;

  const _SettingsSwitch(
      {this.value, this.onChanged, this.title, this.secondary, this.enabled = true});

  @override
  __SettingsSwitchState createState() => __SettingsSwitchState();
}

class __SettingsSwitchState extends State<_SettingsSwitch> {
  bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      activeTrackColor: Const.tecartaBlue.withOpacity(0.5),
      activeColor: Colors.white,
      value: _value,
      onChanged: widget.enabled
          ? (_) {
              setState(() {
                _value = !_value;
              });
              widget.onChanged();
            }
          : null,
      title: widget.title,
      secondary: widget.secondary,
    );
  }
}

class _TitleSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const _TitleSettingTile({this.icon, this.title, this.subtitle, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(5),
                    decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        color: Const.tecartaBlue),
                    child: Icon(
                      icon,
                      size: 18,
                      color: Colors.white,
                    )),
                const VerticalDivider(color: Colors.transparent),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                  )
                ]),
              ],
            ),
          ]),
        ]),
      ),
    );
  }
}

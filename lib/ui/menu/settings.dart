import 'dart:math' as math;

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' show TecUtilExtOnBuildContext;
import 'package:tec_views/tec_views.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/app_theme_bloc.dart';
import '../../blocs/prefs_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/pref_item.dart';
import '../common/common.dart';
import '../misc/text_settings.dart';
import '../volume/volume_view_data_bloc.dart';
import 'main_menu_model.dart';
import 'notifications_view.dart';
import 'zendesk_help.dart';

void showSettings(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
        builder: (c) => SettingsView(
              menuModel: MainMenuModel(),
            ),
        fullscreenDialog: true));

class SettingsView extends StatelessWidget {
  final MainMenuModel menuModel;

  const SettingsView({this.menuModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinHeightAppBar(
        appBar: AppBar(
          title: const Text('Settings'),
          elevation: 0,
        ),
      ),
      body: Container(
          color: Theme.of(context).canvasColor,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 10),
                Expanded(
                  child: ListView(children: [
                    _TitleSettingTile(
                      title: 'Account',
                      icon: FeatherIcons.user,
                      trailing: FlatButton.icon(
                          icon: Text('Sync now',
                              style: TextStyle(color: Theme.of(context).textColor)),
                          label: Icon(Icons.sync, color: Theme.of(context).textColor),
                          onPressed: () {
                            final ua = AppSettings.shared.userAccount;
                            if (ua.user.isSignedIn) {
                              ua.syncUserDb<void>(
                                  itemTypes: ua.itemTypesToSync,
                                  completion: (ua, status) {
                                    if (status == 200) {
                                      TecToast.show(context, 'Successfully Synced');
                                    } else {
                                      TecToast.show(context, 'Failed to Sync');
                                    }
                                    return;
                                  });
                            } else {
                              TecToast.show(context, 'Sign in to Sync');
                            }
                          }),
                    ),
                    const _TitleSettingTile(title: 'Read', icon: FeatherIcons.bookmark),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, bottom: 10),
                      child: Column(children: readTiles(context)),
                    ),
                    _TitleSettingTile(
                      title: 'Notifications',
                      icon: FeatherIcons.bell,
                      onPressed: () => showNotifications(context),
                    ),
                    const _TitleSettingTile(title: 'Audio', icon: FeatherIcons.volume1),
                    _TitleSettingTile(
                      title: 'About',
                      icon: FeatherIcons.info,
                      onPressed: () => menuModel.showAboutDialog(context),
                    ),
                    _TitleSettingTile(
                      title: 'Help',
                      icon: FeatherIcons.helpCircle,
                      onPressed: () => showZendeskHelp(context),
                    ),
                  ]),
                )
              ],
            ),
          )),
    );
  }

  List<Widget> readTiles(BuildContext context) {
    final color = Theme.of(context).textColor;
    final textStyle = TextStyle(fontSize: 15, color: color);

    return [
      _SettingsSwitch(
          secondary: Icon(Icons.lightbulb_outline, color: color),
          title: Text('Dark theme', style: textStyle),
          onChanged: () => context.tbloc<ThemeModeBloc>().add(ThemeModeEvent.toggle),
          value: AppSettings.shared.isDarkTheme()),
      _SettingsSwitch(
        secondary: Icon(Icons.sync_alt, color: color),
        title: Text('Sync chapter', style: textStyle),
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
          secondary: Transform.rotate(
              angle: 90 * math.pi / 180, child: Icon(Icons.sync_alt, color: color)),
          title: Text('Sync verse', style: textStyle),
          onChanged: () => PrefsBloc.toggle(PrefItemId.syncVerse),
          value: PrefsBloc.getBool(PrefItemId.syncVerse),
        );
      }),
      _SettingsSwitch(
        secondary: Icon(Icons.link, color: color),
        title: Text('Include Link with Share', style: textStyle),
        onChanged: () => PrefsBloc.toggle(PrefItemId.includeShareLink),
        value: PrefsBloc.getBool(PrefItemId.includeShareLink),
      ),
      _SettingsSwitch(
        secondary: Icon(Icons.close, color: color),
        title: Text('Close Sheet after Copy/Share', style: textStyle),
        onChanged: () => PrefsBloc.toggle(PrefItemId.closeAfterCopyShare),
        value: PrefsBloc.getBool(PrefItemId.closeAfterCopyShare),
      ),
      _SettingsSwitch(
        secondary: Icon(Icons.play_circle_outline, color: color),
        title: Text('Autoscroll', style: textStyle),
        onChanged: () => TecAutoScroll.setEnabled(enabled: !TecAutoScroll.isEnabled()),
        value: TecAutoScroll.isEnabled(),
      ),
      ListTile(
        dense: true,
        leading: Icon(Icons.format_size, color: color),
        title: Text('Text Settings', style: textStyle),
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
    return SwitchListTile.adaptive(
      dense: true,
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
  final VoidCallback onPressed;
  final Widget trailing;

  const _TitleSettingTile({this.icon, this.title, this.trailing, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      style: const TextStyle(fontSize: 18.0),
    );
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 25,
                ),
                const VerticalDivider(color: Colors.transparent),
                titleWidget,
              ],
            ),
            if (trailing != null)
              Padding(padding: const EdgeInsets.only(right: 15), child: trailing)
          ]),
          const Divider(indent: 40),
        ]),
      ),
    );
  }
}

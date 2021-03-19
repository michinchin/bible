import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../../version.dart';

class MainMenuModel {
  Future<void> shareApp(BuildContext context) async {
    await Navigator.of(context).maybePop();
    return Share.share(Const.tecartaBibleLink);
  }

  /// Opens the native email UI with an email for questions or comments.
  Future<void> emailFeedback(BuildContext context) async {
    var email = 'biblesupport@tecarta.com';
    if (TecPlatform.isAndroid) {
      email = 'androidsupport@tecarta.com';
    } else if (TecPlatform.isIOS) {
      email = 'iossupport@tecarta.com';
    }

    final di = AppSettings.shared.deviceInfo;
    dmPrint('Running on ${di.productName} with ${di.model} ${di.version}');
    const version = (appVersion == 'DEBUG-VERSION' ? '(debug version)' : 'v$appVersion');
    final subject = 'Feedback regarding TecartaBible $version '
        'on ${di.productName} with ${di.model} ${di.version}';
    const body = 'I have the following question or comment:\n\n\n';

    final url = Uri.encodeFull('mailto:$email?subject=$subject&body=$body');

    try {
      if (await launcher.canLaunch(url)) {
        await launcher.launch(url, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      final msg = 'Error emailing: ${e.toString()}';
      await Navigator.of(context).maybePop();
      TecToast.show(context, msg);
      dmPrint(msg);
    }
    await Navigator.of(context).maybePop();
  }

  Future<void> showAboutDialog(BuildContext context) async {
    await tecShowSimpleAlertDialog<void>(
      context: context,
      barrierDismissible: true,
      // useRootNavigator: false,
      title: 'About',
      content:
          'Tecarta Bible is a full featured bible app with access to thousands of study notes, maps, charts, book introductions and more!\n\nVersion: $appVersion',
      actions: <Widget>[
        TecDialogButton(
          child: const TecText('Okay'),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        TecDialogButton(
          child: const TecText('Website'),
          onPressed: () {
            Navigator.of(context).maybePop();
            launcher.launch(Const.tecartaBibleLink);
          },
        ),
      ],
    );
    // return Navigator.of(context).maybePop();
  }
}

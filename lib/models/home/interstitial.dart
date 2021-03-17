import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tec_native_ad/interstitial.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../ui/iap/iap_dialog.dart';
import '../../version.dart';
import '../app_settings.dart';
import '../const.dart';
import '../iap/iap_io.dart';

const _removeAdsVolumeId = 7003;
const _removeAdsId = 'inapp.7003';

class Interstitial {
  static Future<void> init({int viewProductId = -1}) async {
    // show ads for this product?
    if (!await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(_removeAdsVolumeId) &&
        !await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(viewProductId)) {
      await TecInterstitial.init(Const.prefNativeAdId);
    }
  }

  static Future<bool> show(BuildContext context,
      {bool force = false, int viewProductId = -1}) async {
    // show ads for this product?
    if (!force) {
      if (await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(_removeAdsVolumeId) ||
          await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(viewProductId)) {
        return false;
      }
    }

    Future<void> _handlePurchase(
      BuildContext context,
      String inAppId, {
      bool isRestoration,
      IAPError error,
    }) async {
      // if (!mounted) return;
      if (error != null) {
        tec.dmPrint('IAP FAILED WITH ERROR: ${error?.message}');
      } else if (tec.isNotNullOrEmpty(inAppId)) {
        final id = int.tryParse(inAppId.split('.').last);
        if (id != null) {
          if (!await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(id)) {
            await AppSettings.shared.userAccount.userDb.addLicenseForFullVolume(id);
          }
          if (!isRestoration) {
            // TO-DO(ron): ...
            // await _newPurchase(id);

            await tecShowSimpleAlertDialog<bool>(
              context: context,
              content: 'In-app purchase was successful! :)',
              useRootNavigator: false,
              actions: <Widget>[
                TecDialogButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            );
          }
        }
      }
    }

    void _buyProduct() {
      InAppPurchases.shared.purchase(
          context,
          (inAppId, isRestoration, error) =>
              _handlePurchase(context, inAppId, isRestoration: isRestoration, error: error),
          _removeAdsId,
          consumable: tec.platformIs(tec.Platform.android));
      Navigator.of(context).pop();
    }

    Future<void> _removeAds(BuildContext context) async {
      final ua = AppSettings.shared.userAccount;
      if (ua.user.userId == 0) {
        await showSignInForPurchases(context, ua).then((_) {
          ua.userDb.hasLicenseToFullVolume(_removeAdsVolumeId).then((hasLicense) {
            if (!hasLicense) {
              _buyProduct();
            } else {
              Navigator.of(context).pop();
            }
          });
        });
      } else {
        _buyProduct();
      }
    }

    const message = 'Thank you for supporting the TecartaBible '
        'App! To support the app\'s continued '
        'development, a dismissible ad will occasionally appear '
        'after you have read a devotional or verse of the day. Remove all ads '
        'by paying a small fee.';

    const shortMessage = 'Thank you for supporting the TecartaBible '
        'App! Remove all ads by paying a small fee.';

    return TecInterstitial.show(context, _removeAds,
        feedbackAppLabel: 'Bible App', appVersion: appVersion, message: message, shortMessage: shortMessage, force: force);
  }
}

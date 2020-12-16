import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tec_native_ad/tec_native_ad.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../ui/iap/iap_dialog.dart';
import '../app_settings.dart';
import '../iap/iap.dart';

const prefLastInterstitialShown = 'tec_interstitial_last';
const minMillsBetweenAds = 15 * 60 * 1000; // 1/4 hr
var _adStartTime = DateTime.now();
String _adUnitId = '';
int _productId = -1;
const removeAdsVolumeId = 7005;
const removeAdsId = 'inapp.7005';

class Interstitial {
  static Future<void> init(BuildContext context, {int productId, String adUnitId}) async {
    if (kIsWeb) return;
    _adStartTime = DateTime.now();

    // does this product have ads ?
    if (!await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(removeAdsVolumeId)) {
      NativeAdController.instance.loadAds(adUnitId: adUnitId);
      _adUnitId = adUnitId;
      if (!await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(productId)) {
        _productId = productId;
      }
    } else {
      _productId = -1;
      _adUnitId = '';
    }
  }

  static Future<bool> show(BuildContext context) async {
    if (kIsWeb) return false;
    const minViewTime = Duration(seconds: 15);

    // does this product have a license?
    if (await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(removeAdsVolumeId) ||
        (_productId != -1 &&
            await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(_productId))) {
      return false;
    }

    final lastAdShown = DateTime.fromMillisecondsSinceEpoch(
        tec.Prefs.shared.getInt(prefLastInterstitialShown, defaultValue: 0));

    if (/*!kDebugMode && */
        DateTime.now().difference(_adStartTime) > minViewTime &&
            DateTime.now().difference(lastAdShown) >
                const Duration(milliseconds: minMillsBetweenAds)) {
      final numAds = await NativeAdController.instance.numAdsAvailable(_adUnitId);

      if (numAds > 0) {
        await Navigator.of(context, rootNavigator: true)
            .push(MaterialPageRoute<void>(builder: (_) => InterstitialScreen(_adUnitId)));

        await tec.Prefs.shared
            .setInt(prefLastInterstitialShown, DateTime.now().millisecondsSinceEpoch);

        return true;
      }
    }

    return false;
  }
}

class InterstitialScreen extends StatefulWidget {
  final String adUnitId;

  const InterstitialScreen(this.adUnitId);

  @override
  _InterstitialState createState() {
    return _InterstitialState();
  }
}

class _InterstitialState extends State<InterstitialScreen> {
  var _maxAdHeight = 0;
  GlobalKey textKey = GlobalKey();
  GlobalKey windowKey = GlobalKey();
  var _smallScreen = false;
  var _okToClose = false;

  Future<void> findReservedHeight(Duration _) async {
    final bigBox = windowKey.currentContext.findRenderObject();
    final box = textKey.currentContext.findRenderObject();
    if (bigBox is RenderBox && box is RenderBox) {
      // reserve the height of the box + some padding...
      final newMaxAdHeight = bigBox.size.height - box.size.height - 30;

      if (newMaxAdHeight != _maxAdHeight) {
        setState(() {
          _maxAdHeight = newMaxAdHeight.floor();
        });
      }
    }
  }

  void _buyProduct() {
    InAppPurchases.shared.purchase(
        context,
        (inAppId, isRestoration, error) =>
            _handlePurchase(context, inAppId, isRestoration: isRestoration, error: error),
        removeAdsId,
        consumable: Platform.isAndroid);
    Navigator.of(context).pop();
  }

  Future<void> _handlePurchase(
    BuildContext context,
    String inAppId, {
    bool isRestoration,
    IAPError error,
  }) async {
    if (!mounted) return;
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
            // title: 'In-app Purchase',
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

  void _removeAds(BuildContext context) {
    final ua = AppSettings.shared.userAccount;
    if (ua.user.userId == 0) {
      showSignInForPurchases(context, ua).then((_) {
        ua.userDb.hasLicenseToFullVolume(removeAdsVolumeId).then((hasLicense) {
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

  /// Opens the native email UI with an email for questions or comments.
  Future<void> _emailFeedback(BuildContext context, String uniqueId) async {
    var email = 'iossupport@tecarta.com';
    if (!Platform.isIOS) {
      email = 'androidsupport@tecarta.com';
    }
    final di = AppSettings.shared.deviceInfo;
    tec.dmPrint('Running on ${di.productName} with ${tec.platformName} ${di.version}');
    final version = (AppSettings.shared.deviceInfo.version == 'DEBUG-VERSION'
        ? '(debug version)'
        : 'v${AppSettings.shared.deviceInfo.version}');
    final subject = 'Feedback regarding Bible App $version '
        'with ${di.productName} ${tec.platformName} ${di.version}';
    final adHeadline = (await NativeAdController.instance.getHeadline(widget.adUnitId, uniqueId))
        .replaceAll('&', '%26');
    final body =
        'I have the following question or comment about an ad with headline ($adHeadline):\n\n\n';
    final url = Uri.encodeFull('mailto:$email?subject=$subject&body=$body');

    try {
      if (await launcher.canLaunch(url)) {
        await launcher.launch(url, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      final msg = 'Error emailing: ${e.toString()}';
      Navigator.pop(context); // Dismiss the ad.
      TecToast.show(context, msg);
    }
  }

  Future<bool> onWillPop() {
    return Future.value(_okToClose || !Platform.isAndroid);
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = Color.fromARGB(255, 71, 146, 206);
    const redColor = Color.fromARGB(255, 239, 83, 80);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          body: SafeArea(
        bottom: false,
        child: OrientationBuilder(builder: (context, _) {
          _smallScreen = (windowSizeWith(context).height <= 700);

          WidgetsBinding.instance.addPostFrameCallback(findReservedHeight);

          return SizedBox(
              key: windowKey,
              width: windowSizeWith(context).width,
              child: Stack(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_maxAdHeight == 0) Container(),
                    if (_maxAdHeight > 0)
                      Container(
                        width: windowSizeWith(context).width,
                        height: _maxAdHeight.toDouble(),
                        child: TecNativeAd(
                          adUnitId: widget.adUnitId,
                          uniqueId: 'devo-1',
                          adFormat: 'large',
                          darkMode: Theme.of(context).brightness != Brightness.light,
                          maxHeight: _maxAdHeight,
                        ),
                      ),
                    const Spacer(),
                    Column(
                      key: textKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Text('Why am I seeing this ad?',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Theme.of(context).textColor : Colors.black87,
                                  fontSize: 16.0)),
                        ),
                        if (_smallScreen)
                          const Padding(
                            padding:
                                EdgeInsets.only(top: 5.0, left: 15.0, right: 15.0, bottom: 10.0),
                            child: Text(
                                'To support the app\'s continued '
                                'development, a dismissible ad will occasionally appear '
                                'after you have read a devotional.',
                                style: TextStyle(fontSize: 16.0, height: 1.2)),
                          ),
                        if (!_smallScreen)
                          const Padding(
                            padding:
                                EdgeInsets.only(top: 5.0, left: 15.0, right: 15.0, bottom: 30.0),
                            child: Text(
                                'Thank you for supporting the TecartaBible '
                                'App! To support the app\'s continued '
                                'development, a dismissible ad will occasionally appear '
                                'after you have read a devotional or verse of the day. Remove all ads '
                                'by paying a small fee.',
                                style: TextStyle(fontSize: 16.0, height: 1.2)),
                          ),
                        Padding(
                          padding: EdgeInsets.only(bottom: ((_smallScreen) ? 10.0 : 30.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              OutlineButton(
                                child: const Text('REMOVE ADS',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: redColor)),
                                onPressed: () {
                                  _removeAds(context);
                                },
                                borderSide: const BorderSide(width: 1.0, color: redColor),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                              ),
                              OutlineButton(
                                child: const Text('SEND FEEDBACK',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                    )),
                                onPressed: () {
                                  _emailFeedback(context, 'devo-1');
                                },
                                borderSide: const BorderSide(width: 1.0, color: blueColor),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(top: 10.0, left: 10.0),
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [boxShadow()],
                    border: Border.all(color: Colors.black26, width: 1.0),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    color: isDarkMode ? Colors.white : Colors.black,
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () {
                      _okToClose = true;
                      Navigator.maybePop(context);
                    },
                  ),
                ),
              ]));
        }),
      )),
    );
  }
}

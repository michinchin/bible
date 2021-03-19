import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../../models/iap/iap.dart';
import '../common/common.dart';
import 'volume_image.dart';

class VolumeDetail extends StatefulWidget {
  final Volume volume;
  final String heroPrefix;

  const VolumeDetail({Key key, this.volume, this.heroPrefix}) : super(key: key);

  @override
  _VolumeDetailState createState() => _VolumeDetailState();
}

class _VolumeDetailState extends State<VolumeDetail> {
  @override
  Widget build(BuildContext context) {
    // We're deliberately using `scaleFactorWith` instead of `textScaleFactor...` because
    // if the user has their device text scaling set very high, it can cause overflow
    // the the name and publisher text.
    final textScaleFactor = scaleFactorWith(
      context,
      dampingFactor: 0.5,
      minScaleFactor: 1,
      maxScaleFactor: 3,
    );
    final padding = (16.0 * textScaleFactor).roundToDouble();

    return Scaffold(
      appBar: MinHeightAppBar(
        appBar: AppBar(
          elevation: 0,
          //title: TecText(volume.name, maxLines: 2, textAlign: TextAlign.center),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _VolumeCard(
              volume: widget.volume,
              textScaleFactor: textScaleFactor,
              padding: padding,
              heroPrefix: widget.heroPrefix,
            ),
            _VolumeDescription(
              volume: widget.volume,
              textScaleFactor: textScaleFactor,
              padding: padding,
            ),
          ],
        ),
      ),
    );
  }
}

class _VolumeCard extends StatelessWidget {
  final Volume volume;
  final double textScaleFactor;
  final double padding;
  final String heroPrefix;

  //final Widget buttons;
  const _VolumeCard({
    this.volume,
    this.textScaleFactor,
    this.padding,
    this.heroPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        //final halfPad = (padding / 2.0).roundToDouble();

        dmPrint(
            '_VolumeCard building with hero tag: "${heroTagForVolume(volume, heroPrefix)}"');

        final cardHeight = math.min(350.0, (constraints.maxWidth * 0.5).roundToDouble() + 50.0);

        final titleStyle = TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).textColor);
        final subtitleStyle = TextStyle(fontSize: 14, color: Theme.of(context).textColor);

        Widget image() => TecCard(
              color: Colors.transparent,
              padding: 0,
              elevation: defaultElevation,
              cornerRadius: 8,
              builder: (context) => VolumeImage(volume: volume),
            );

        return Padding(
          padding: EdgeInsets.only(right: padding, left: padding),
          child: SizedBox(
            height: cardHeight,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  padding: EdgeInsets.only(top: padding),
                  child: TecCard(
                    padding: 0,
                    elevation: defaultElevation,
                    color: Theme.of(context).cardColor,
                    builder: (c) => Container(),
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
                            child: isNotNullOrEmpty(heroPrefix)
                                ? Hero(
                                    tag: heroTagForVolume(volume, heroPrefix),
                                    child: image(),
                                  )
                                : image(),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: padding * 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TecText(
                                    volume.name,
                                    style: titleStyle,
                                    textScaleFactor: textScaleFactor,
                                  ),
                                  SizedBox(height: padding),
                                  TecText(
                                    volume.publisher,
                                    style: subtitleStyle,
                                    textScaleFactor: textScaleFactor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: (padding * 0.5).roundToDouble()),
                        ],
                      ),
                    ),
                    _Buttons(volume: volume, textScaleFactor: textScaleFactor, padding: padding),
                    SizedBox(height: (padding * 0.6).roundToDouble()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// BlocProvider<IsLicensedBloc>(
//   create: (context) => IsLicensedBloc(volumeIds: [widget.volume.id]),
//   child: BlocBuilder<IsLicensedBloc, bool>(
//     builder: (context, isLicensed) {
//       return BlocBuilder<DownloadsBloc, DownloadsState>(
//         condition: (previous, current) =>
//             previous.items[widget.volume.id] != current.items[widget.volume.id],
//         builder: (context, downloads) {
//           return _VolumeCard(
//             volume: widget.volume,
//             isLicensed: isLicensed,
//             isDownloaded: VolumesRepository.shared.isLocalVolume(widget.volume.id) ||
//                 downloads.items[widget.volume.id]?.status == DownloadStatus.complete,
//             price: _priceStr,
//             textScaleFactor: textScaleFactor,
//             padding: padding,
//           );
//         },
//       );
//     },
//   ),
// ),

class _Buttons extends StatefulWidget {
  final Volume volume;
  final double textScaleFactor;
  final double padding;

  const _Buttons({
    Key key,
    this.volume,
    this.textScaleFactor,
    this.padding,
  }) : super(key: key);

  @override
  _ButtonsState createState() => _ButtonsState();
}

class _ButtonsState extends State<_Buttons> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  var _isPurchasing = false;
  var _isLicensed = false;
  String _priceStr;

  Future<void> _refresh() async {
    if (!mounted) return;

    _isLicensed =
        await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(widget.volume.id);
    if (!mounted) return;

    if (_priceStr == null && !_isLicensed && widget.volume.onSale && widget.volume.price != 0.0) {
      final details = await InAppPurchases.shared.detailsWithProduct(widget.volume.appStoreId);
      if (!mounted) return;
      _priceStr = details?.price;

      // `detailsWithProduct` may fail on the simulator, but we still want to be able to test
      // purchasing, so set `_priceStr` to an empty string.
      if (_priceStr == null && AppSettings.shared.deviceInfo.isSimulator) {
        _priceStr = '';
      }
    }

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final div = SizedBox(width: widget.padding);

    final outlinedButtonStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.all(4),
    ).copyWith(
      side: MaterialStateProperty.resolveWith<BorderSide>(
        (states) {
          if (states.contains(MaterialState.pressed)) {
            return BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            );
          }
          return null; // Defer to the widget's default.
        },
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        div,
        if (!_isLicensed)
          Expanded(
            child: OutlinedButton(
              child: TecText(_priceStr == null ? '' : 'Buy $_priceStr',
                  textScaleFactor: widget.textScaleFactor),
              style: outlinedButtonStyle,
              onPressed: _isPurchasing || _priceStr == null
                  ? null
                  : () {
                      _isPurchasing = true;
                      _refresh();
                      InAppPurchases.shared.purchase(
                        context,
                        (inAppId, isRestoration, error) => _handlePurchase(context, inAppId,
                            isRestoration: isRestoration, error: error),
                        widget.volume.appStoreId,
                        simulatePurchase: AppSettings.shared.deviceInfo.isSimulator,
                      );
                    },
            ),
          ),
        if (_isLicensed)
          Expanded(
            child: OutlinedButton(
              child: TecText('Download', textScaleFactor: widget.textScaleFactor),
              style: outlinedButtonStyle,
              onPressed: null,
            ),
          ),
        // if (!isLicensed && widget.volume.isForSale && widget.showReadNow) ...[
        //   div,
        //   Expanded(
        //     child: OutlinedButton(
        //       style: outlinedButtonStyle,
        //       child: const TecText(
        //         'Free Plan',
        //         autoSize: true,
        //         maxLines: 2,
        //         textAlign: TextAlign.center,
        //       ),
        //       onPressed: () async {
        //         await _showCreatePlanDialog(context, widget.volume,
        //             inApp: inApp, price: price);
        //       },
        //     ),
        //   ),],
        div,
      ],
    );
  }

  Future<void> _handlePurchase(
    BuildContext context,
    String inAppId, {
    bool isRestoration,
    IAPError error,
  }) async {
    if (error != null) {
      dmPrint('IAP FAILED WITH ERROR: ${error?.message}');
    } else if (isNotNullOrEmpty(inAppId)) {
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

    _isPurchasing = false;
    unawaited(_refresh());
  }
}

class _VolumeDescription extends StatelessWidget {
  final Volume volume;
  final double textScaleFactor;
  final double padding;

  const _VolumeDescription({
    Key key,
    this.volume,
    this.textScaleFactor,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14,
      height: 1.3,
      color: Theme.of(context).textColor,
    );

    return Padding(
      padding: EdgeInsets.all(padding * 1.5),
      child: TecFutureBuilder<String>(
        futureBuilder: () => _descriptionWithVolume(volume),
        builder: (context, description, error) {
          return TecText(
            description ?? '',
            style: textStyle,
            // We're deliberately using `contentTextScaleFactorWith` here because this is
            // a large amount of text and we want it to scale with the user's text scale setting.
            textScaleFactor: contentTextScaleFactorWith(context),
            // textAlign: TextAlign.justify,
          );
        },
      ),
    );
  }
}

Future<String> _descriptionWithVolume(Volume volume) async {
  // dmPrint('calling _descriptionWithVolume(${volume.id})');

  try {
    final prefix = TecPlatform.isIOS ? 'IOS' : 'PLAY';
    final url = '$cloudFrontStreamUrl/products-desc/${prefix}_TecartaBible.${volume.id}.json.gz';
    final response = await http.get(Uri.parse(url));
    final jsonStr = isNullOrEmpty(response?.bodyBytes) ? null : utf8.decode(response.bodyBytes);
    final dynamic json = jsonDecode(jsonStr);
    if (json is String) {
      return json;
    }
  }
  // ignore: avoid_catches_without_on_clauses
  catch (e) {
    dmPrint('_descriptionWithVolume(${volume.id}) failed with error: $e');
  }

  return '';
}

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../../models/iap.dart';
import '../common/common.dart';
import 'volume_image.dart';

class VolumeDetail extends StatefulWidget {
  final Volume volume;

  const VolumeDetail({Key key, this.volume}) : super(key: key);

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

    return TecScaffoldWrapper(
      child: Scaffold(
        appBar: MinHeightAppBar(
          appBar: AppBar(
              //title: TecText(volume.name, maxLines: 2, textAlign: TextAlign.center),
              ),
        ),
        body: ListView(
          children: [
            _VolumeCard(
              volume: widget.volume,
              textScaleFactor: textScaleFactor,
              padding: padding,
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

  //final Widget buttons;
  const _VolumeCard({
    this.volume,
    this.textScaleFactor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        //final halfPad = (padding / 2.0).roundToDouble();

        final cardHeight = math.min(350.0, (constraints.maxWidth * 0.5).roundToDouble() + 50.0);

        final titleStyle = TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).textColor);
        final subtitleStyle = TextStyle(fontSize: 14, color: Theme.of(context).textColor);

        return Padding(
          padding: EdgeInsets.only(right: padding, left: padding),
          child: Container(
            height: cardHeight,
            //width: MediaQuery.of(context).size.width - padding * 2,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  padding: EdgeInsets.only(top: padding),
                  child: TecCard(
                    padding: 0,
                    elevation: 4,
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
                            child: Hero(
                              tag: '${volume.hashCode}-${volume.id}',
                              child: TecCard(
                                color: Colors.transparent,
                                padding: 0,
                                elevation: 4,
                                cornerRadius: 8,
                                builder: (context) => VolumeImage(
                                  volume: volume,
                                  heroAnimated: false,
                                ),
                              ),
                            ),
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
    }

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final div = SizedBox(width: widget.padding);
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        div,
        if (!_isLicensed)
          Expanded(
            child: OutlineButton(
              padding: const EdgeInsets.all(4),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: TecText(_priceStr == null ? '' : 'Buy $_priceStr',
                  textScaleFactor: widget.textScaleFactor),
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
            child: OutlineButton(
              padding: const EdgeInsets.all(4),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: TecText('Download', textScaleFactor: widget.textScaleFactor),
              onPressed: null,
            ),
          ),
        // if (!isLicensed && widget.volume.isForSale && widget.showReadNow) ...[
        //   div,
        //   Expanded(
        //     child: OutlineButton(
        //       padding: const EdgeInsets.all(5),
        //       splashColor: Colors.transparent,
        //       highlightColor: Colors.transparent,
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
      tec.dmPrint('IAP FAILED WITH ERROR: ${error?.message}');
    } else if (tec.isNotNullOrEmpty(inAppId)) {
      final id = int.tryParse(inAppId.split('.').last);
      if (id != null) {
        if (!await AppSettings.shared.userAccount.userDb.hasLicenseToFullVolume(id)) {
          await AppSettings.shared.userAccount.userDb.addLicenseForFullVolume(id);
        }
        if (!isRestoration) {
          // TODO(ron): ...
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
  tec.dmPrint('calling _descriptionWithVolume(${volume.id})');

  try {
    final prefix = tec.platformIs(tec.Platform.iOS) ? 'IOS' : 'PLAY';
    final url = '${tec.streamUrl}/products-desc/${prefix}_TecartaBible.${volume.id}.json.gz';
    final response = await http.get(url);
    final jsonStr = tec.isNullOrEmpty(response?.bodyBytes) ? null : utf8.decode(response.bodyBytes);
    final dynamic json = jsonDecode(jsonStr);
    if (json is String) {
      return json;
    }
  }
  // ignore: avoid_catches_without_on_clauses
  catch (e) {
    tec.dmPrint('_descriptionWithVolume(${volume.id}) failed with error: $e');
  }

  return '';
}

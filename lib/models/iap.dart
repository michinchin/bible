import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

// import '../screens/choose_plan_screen.dart';
// import 'app_bloc.dart';

class InAppPurchases {
  static InAppPurchases _iap;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  Future<void> Function(String inAppId, bool restoration) _purchaseHandler;
  BuildContext _context;
  PurchaseDetails _pendingPurchase;
  BehaviorSubject<int> _inappUpdate;

  static void init(BuildContext context,
      Future<void> Function(String inAppId, bool restoration) purchaseHandler) {
    _iap ??= InAppPurchases(purchaseHandler);
    _iap._inappUpdate = BehaviorSubject<int>.seeded(0);
    _iap._context = context;
  }

  static void restorePurchases() {
    if (_iap != null) {
      _iap._restorePurchases();
    }
  }

  static void purchase(String productId,
      {bool consumable = true}) {
    if (_iap != null) {
      _iap._purchase(productId, consumable);
    }
  }

  static Stream<int> inAppUpdateStream() {
    if (_iap != null) {
      return _iap._inappUpdate.stream;
    }

    return null;
  }

  Future<void> _purchase(String productId,
      bool consumable) async {
    final available = await InAppPurchaseConnection.instance.isAvailable();

    if (available) {
      //ignore: prefer_collection_literals
      final ids = <String>[productId].toSet();

      final response =
          await InAppPurchaseConnection.instance.queryProductDetails(ids);

      if (response.notFoundIDs.isNotEmpty) {
        tec.dmPrint('Could not retrieve products');
        return;
      }

      final purchaseParam = PurchaseParam(
          productDetails: response.productDetails.first,
          sandboxTesting: false);

      try {
        if (consumable) {
          await InAppPurchaseConnection.instance
              .buyConsumable(purchaseParam: purchaseParam);
        } else {
          await InAppPurchaseConnection.instance
              .buyNonConsumable(purchaseParam: purchaseParam);
        }
      }
      catch (e) {
        if (e.code == 'storekit_duplicate_product_object') {
          await tecShowSimpleAlertDialog<bool>(
            context: _context,
            title: 'In-app Purchase',
            content: 'There is a duplicate inapp purchase with the current account :(',
            useRootNavigator: false,
            actions: <Widget>[
              TecDialogButton(
                child: const Text('Ok'),
                onPressed: () => Navigator.of(_context).pop(false),
              ),
            ],
          );
        }
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;

    _inappUpdate?.close();
    _inappUpdate = null;
  }

  InAppPurchases(
      Future<void> Function(String inAppId, bool restoration) purchaseHandler) {
    _purchaseHandler = purchaseHandler;
    InAppPurchaseConnection.enablePendingPurchases();

    final purchaseUpdates =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen(_handlePurchaseUpdates);

    InAppPurchaseConnection.instance.isAvailable().then((available) {
      if (!available) {
        tec.dmPrint('Unable to initialize in-apps...');
        return;
      }
    });
  }

  Future<void> _restorePurchases() async {
    if (!await InAppPurchaseConnection.instance.isAvailable()) {
      return;
    }

    final response = await InAppPurchaseConnection.instance.queryPastPurchases();

    if (response.error != null) {
      if (Platform.isIOS) {
        final message =
            response.error.details['NSLocalizedDescription'].toString();

        await tecShowSimpleAlertDialog<bool>(
          context: _context,
          content: message,
          useRootNavigator: false,
          actions: <Widget>[
            TecDialogButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(_context).pop(false),
            ),
          ],
        );
      } else {
        tec.dmPrint('Unable to restore purchases...');
      }
    } else {
      await _handlePurchaseUpdates(response.pastPurchases, restoration: true);

      if (Platform.isIOS) {
        if (response.pastPurchases.isEmpty) {
          await tecShowSimpleAlertDialog<bool>(
            context: _context,
            content: 'The App Store didn\'t find any purchases to restore.',
            useRootNavigator: false,
            actions: <Widget>[
              TecDialogButton(
                child: const Text('Ok'),
                onPressed: () => Navigator.of(_context).pop(false),
              ),
            ],
          );
        } else {
          // TODO(ron): ...
          // await navigatorPush(_context, (_) => const ChoosePlanScreen(),
          //     rootNavigator: true, arguments: ChoosePlanScreen.booksTab);
        }
      }
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetails,
      {bool restoration = false}) async  {
    var updateListeners = false;

    for (final details in purchaseDetails) {
      if (restoration) {
        // restoring purchases
        if (_purchaseHandler != null) {
          await _purchaseHandler(details.productID, restoration);
        }
      }
      else {
        switch (details.status) {
          case PurchaseStatus.pending:
            // possibly show busy cursor here
            _pendingPurchase = details;
            break;

          case PurchaseStatus.purchased:
            updateListeners = true;

            if (_purchaseHandler != null) {
              await _purchaseHandler(details.productID,
                  Platform.isIOS && _pendingPurchase == null);
            }

            if (details.pendingCompletePurchase) {
              await InAppPurchaseConnection.instance.completePurchase(details);
            }
            _pendingPurchase = null;
            break;

          case PurchaseStatus.error:
            if (details.pendingCompletePurchase) {
              await InAppPurchaseConnection.instance.completePurchase(details);
            }
            _pendingPurchase = null;
            break;
        }
      }
    }

    if (updateListeners) {
      _inappUpdate.add(_inappUpdate.value + 1);
    }
  }
}

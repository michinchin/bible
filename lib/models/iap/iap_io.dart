import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_widgets/tec_widgets.dart';

export 'package:in_app_purchase/in_app_purchase.dart' show IAPError, ProductDetails;

typedef InAppPurchaseHandler = Future<void> Function(
    String inAppId, bool isRestoration, IAPError error);

class InAppPurchases {
  static InAppPurchases get shared => _iap;
  static InAppPurchases _iap;

  static void init() {
    _iap ??= InAppPurchases._();
  }

  InAppPurchases._() {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
    _subscription = InAppPurchase.instance.purchaseStream.listen(_handlePurchaseUpdates);
    InAppPurchase.instance.isAvailable().then((available) {
      if (!available) {
        dmPrint('WARNING: Unable to initialize in-app purchases.');
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _inappUpdate?.close();
    _inappUpdate = null;
    if (identical(this, _iap)) _iap = null;
  }

  BehaviorSubject<int> _inappUpdate = BehaviorSubject<int>.seeded(0);
  StreamSubscription<List<PurchaseDetails>> _subscription;

  Future<ProductDetails> detailsWithProduct(String productId) async {
    ProductDetailsResponse response;
    try {
      response = await InAppPurchase.instance.queryProductDetails({productId});
    } catch (e) {
      dmPrint('InAppPurchases detailsWithProduct($productId) error: $e');
    }
    return (response?.productDetails?.isEmpty ?? true) ? null : response.productDetails.first;
  }

  Future<void> purchase(
    BuildContext context,
    InAppPurchaseHandler purchaseHandler,
    String productId, {
    bool consumable = false,
    bool simulatePurchase = false,
  }) async {
    assert(context != null && purchaseHandler != null && isNotNullOrEmpty(productId));

    if (!(await InAppPurchase.instance.isAvailable())) {
      dmPrint('WARNING: Cannot purchase $productId, the in-app purchase lib is not available.');
      unawaited(purchaseHandler?.call(
          productId,
          false,
          IAPError(
              source: null, code: null, message: 'In-app purchase connection is unavailable.')));
      return; //------------------------------------------------------------>
    }

    if (simulatePurchase) {
      await Future<void>.delayed(const Duration(seconds: 1));
      unawaited(purchaseHandler?.call(productId, false, null));
      return; //------------------------------------------------------------>
    }

    final ids = {productId};
    final response = await InAppPurchase.instance.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      dmPrint('ERROR: InAppPurchases queryProductDetails($productId) failed.');
      unawaited(purchaseHandler?.call(
          productId,
          false,
          IAPError(
              source: null,
              code: null,
              message: 'In-app purchase for $productId does not exist.')));
      return; //------------------------------------------------------------>
    }

    final purchaseParam = PurchaseParam(productDetails: response.productDetails.first);

    _purchaseHandler = purchaseHandler;

    try {
      if (consumable) {
        await InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
      } else {
        await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      if (e.code == 'storekit_duplicate_product_object') {
        await tecShowSimpleAlertDialog<bool>(
          context: context,
          title: 'In-app Purchase',
          content: 'There is a duplicate in-app purchase with the current account :(',
          useRootNavigator: false,
          actions: <Widget>[
            TecDialogButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        );
      }

      unawaited(_purchaseHandler?.call(
          productId,
          false,
          IAPError(
              source: null,
              code: null,
              message: 'In-app purchase for $productId failed with error: $e')));
      _purchaseHandler = null;
    }
  }

  Future<void> restorePurchases(
    BuildContext context,
    InAppPurchaseHandler purchaseHandler,
  ) async {
    assert(context != null && purchaseHandler != null);

    if (!(await InAppPurchase.instance.isAvailable())) {
      dmPrint('WARNING: Cannot restore purchases, the in-app purchase lib is not available.');
      unawaited(purchaseHandler?.call(
          null,
          true,
          IAPError(
              source: null, code: null, message: 'In-app purchase connection is unavailable.')));
      return; //------------------------------------------------------------>
    }

    await InAppPurchase.instance.restorePurchases();

    TecToast.show(context, 'Purchases have been restored.');
  }

  InAppPurchaseHandler _purchaseHandler;
  PurchaseDetails _pendingPurchase;

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetails, {
    bool isRestoration = false,
  }) async {
    var clearPurchaseHandler = false;
    for (final details in purchaseDetails) {
      final productId = details.productID;
      if (isRestoration) {
        if (details.status == PurchaseStatus.purchased) {
          clearPurchaseHandler = true;
          if (_purchaseHandler != null) {
            await _purchaseHandler(productId, isRestoration, null);
          } else {
            dmPrint('ERROR: While restoring $productId, _purchaseHandler is null!');
          }
        }
      } else {
        switch (details.status) {
          case PurchaseStatus.pending:
            _pendingPurchase = details;
            break;

          case PurchaseStatus.purchased:
            clearPurchaseHandler = true;

            if (details.pendingCompletePurchase) {
              await InAppPurchase.instance.completePurchase(details);
            }

            if (_purchaseHandler != null) {
              await _purchaseHandler(
                  productId, TecPlatform.isIOS && _pendingPurchase == null, null);
            } else {
              dmPrint('ERROR: While purchasing $productId, _purchaseHandler is null!');
            }

            _pendingPurchase = null;
            _inappUpdate.add(_inappUpdate.value + 1);
            break;

          case PurchaseStatus.error:
            clearPurchaseHandler = true;

            if (details.pendingCompletePurchase) {
              await InAppPurchase.instance.completePurchase(details);
            }

            dmPrint('ERROR purchasing $productId: ${details.error}');

            if (_purchaseHandler != null) {
              await _purchaseHandler(
                  productId, TecPlatform.isIOS && _pendingPurchase == null, details.error);
            } else {
              dmPrint('ERROR: While purchasing $productId, _purchaseHandler is null!');
            }

            _pendingPurchase = null;
            break;

          case PurchaseStatus.restored:
            dmPrint('restore is not implemented yet :(');
            break;
        }
      }
    }

    if (clearPurchaseHandler) _purchaseHandler = null;
  }
}

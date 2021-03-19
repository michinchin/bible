import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pedantic/pedantic.dart';
import 'package:tec_util/tec_util.dart';

typedef InAppPurchaseHandler = Future<void> Function(
    String inAppId, bool isRestoration, IAPError error);

class InAppPurchases {
  static InAppPurchases get shared => _iap;
  static InAppPurchases _iap;

  static void init() {
    _iap ??= InAppPurchases._();
  }

  InAppPurchases._() {
    dmPrint('WARNING: Unable to initialize in-app purchases in WEB app.');
  }

  void dispose() {
    if (identical(this, _iap)) _iap = null;
  }

  Future<ProductDetails> detailsWithProduct(String productId) async => null;

  Future<void> purchase(
    BuildContext context,
    InAppPurchaseHandler purchaseHandler,
    String productId, {
    bool consumable = false,
    bool simulatePurchase = false,
  }) async {
    assert(context != null && purchaseHandler != null && isNotNullOrEmpty(productId));
    unawaited(purchaseHandler?.call(productId, false,
        IAPError(source: null, code: null, message: 'In-app purchase connection is unavailable.')));
  }

  Future<void> restorePurchases(
    BuildContext context,
    InAppPurchaseHandler purchaseHandler,
  ) async {
    assert(context != null && purchaseHandler != null);
    unawaited(purchaseHandler?.call(null, true,
        IAPError(source: null, code: null, message: 'In-app purchase connection is unavailable.')));
  }
}

class ProductDetails {
  ProductDetails(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      this.skProduct,
      this.skuDetail});

  final String id;
  final String title;
  final String description;
  final String price;
  final dynamic skProduct;
  final dynamic skuDetail;
}

class IAPError {
  IAPError({@required this.source, @required this.code, @required this.message, this.details});

  /// Which source is the error on.
  final dynamic source;

  /// The error code.
  final String code;

  /// A human-readable error message, possibly null.
  final String message;

  /// Error details, possibly null.
  final dynamic details;
}

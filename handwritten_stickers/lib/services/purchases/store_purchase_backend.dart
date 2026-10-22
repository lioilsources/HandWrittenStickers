import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'purchase_backend.dart';

/// App Store (StoreKit 2) and Google Play through `in_app_purchase`.
///
/// There is no server: ownership is whatever the store reports on this
/// device. StoreKit 2 verifies transactions on the device and Play signs
/// its purchase tokens, but nothing here checks a receipt against a
/// backend, so a jailbroken or patched device can unlock packs. That is
/// accepted for packs at 0.99 USD; do not treat this as secure.
class StorePurchaseBackend extends PurchaseBackend {
  final InAppPurchase _iap;
  final StreamController<PurchaseEvent> _updates =
      StreamController<PurchaseEvent>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  StorePurchaseBackend({InAppPurchase? iap})
    : _iap = iap ?? InAppPurchase.instance {
    // Listen from the start: the store delivers interrupted purchases
    // (app killed mid-purchase, Ask to Buy approved later) on launch.
    _subscription = _iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object e) => debugPrint('Purchases: stream error ($e)'),
    );
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      final kind = switch (p.status) {
        PurchaseStatus.purchased ||
        PurchaseStatus.restored => PurchaseEventKind.owned,
        PurchaseStatus.pending => PurchaseEventKind.pending,
        PurchaseStatus.canceled => PurchaseEventKind.cancelled,
        PurchaseStatus.error => PurchaseEventKind.error,
      };
      _updates.add(PurchaseEvent(p.productID, kind, p.error?.message));
      // Unfinished transactions are redelivered (and on Android refunded
      // after three days), so every final state is acknowledged.
      if (p.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(p);
        } catch (e) {
          debugPrint('Purchases: completePurchase failed ($e)');
        }
      }
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      return await _iap.isAvailable();
    } catch (e) {
      debugPrint('Purchases: store unavailable ($e)');
      return false;
    }
  }

  @override
  Future<List<StoreProduct>> products(Set<String> ids) async {
    final response = await _iap.queryProductDetails(ids);
    if (response.error != null) {
      debugPrint('Purchases: product query failed (${response.error})');
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Purchases: unknown products ${response.notFoundIDs}');
    }
    return [
      for (final d in response.productDetails)
        StoreProduct(id: d.id, title: d.title, price: d.price, raw: d),
    ];
  }

  @override
  Future<void> buy(StoreProduct product) async {
    final details = product.raw;
    if (details is! ProductDetails) {
      throw StateError('${product.id} did not come from the store');
    }
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
  }

  @override
  Future<void> restore() => _iap.restorePurchases();

  @override
  Stream<PurchaseEvent> get updates => _updates.stream;

  @override
  void dispose() {
    _subscription?.cancel();
    _updates.close();
  }
}

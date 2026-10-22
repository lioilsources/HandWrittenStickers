import 'dart:async';

/// A product as the store sells it (localised title and price).
class StoreProduct {
  final String id;
  final String title;

  /// Formatted price in the user's currency, e.g. `25,00 Kč`.
  final String price;

  /// Backend-specific product object (`ProductDetails` for the stores).
  final Object? raw;

  const StoreProduct({
    required this.id,
    required this.title,
    required this.price,
    this.raw,
  });
}

enum PurchaseEventKind {
  /// Bought now or restored: the product is owned.
  owned,

  /// Waiting for approval (Ask to Buy, pending card payment).
  pending,
  cancelled,
  error,
}

/// One update from the store about one product.
class PurchaseEvent {
  final String productId;
  final PurchaseEventKind kind;
  final String? message;

  const PurchaseEvent(this.productId, this.kind, [this.message]);
}

/// The store, behind an interface: [StorePurchaseBackend] talks to the App
/// Store / Google Play, [FakePurchaseBackend] serves tests and debug builds.
/// Swapping in RevenueCat later only means another implementation.
abstract class PurchaseBackend {
  Future<bool> isAvailable();

  /// Products the store knows; ids it does not know are left out.
  Future<List<StoreProduct>> products(Set<String> ids);

  /// Starts a purchase; the result arrives through [updates].
  Future<void> buy(StoreProduct product);

  /// Asks the store to replay owned products through [updates].
  Future<void> restore();

  Stream<PurchaseEvent> get updates;

  void dispose() {}
}

/// In-memory store for tests and `--dart-define=HWS_PACKS=…` builds.
class FakePurchaseBackend extends PurchaseBackend {
  final Map<String, String> prices;
  final Set<String> owned;
  bool available;

  /// What the next [buy] does; [PurchaseEventKind.owned] buys.
  PurchaseEventKind nextOutcome;

  final List<String> bought = [];
  int restoreCalls = 0;
  final StreamController<PurchaseEvent> _updates =
      StreamController<PurchaseEvent>.broadcast(sync: true);

  FakePurchaseBackend({
    this.prices = const {},
    Set<String>? owned,
    this.available = true,
    this.nextOutcome = PurchaseEventKind.owned,
  }) : owned = owned ?? {};

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<List<StoreProduct>> products(Set<String> ids) async => [
    for (final id in ids)
      if (prices.containsKey(id))
        StoreProduct(id: id, title: id, price: prices[id]!),
  ];

  @override
  Future<void> buy(StoreProduct product) async {
    bought.add(product.id);
    if (nextOutcome == PurchaseEventKind.owned) owned.add(product.id);
    _updates.add(PurchaseEvent(product.id, nextOutcome));
  }

  @override
  Future<void> restore() async {
    restoreCalls++;
    for (final id in owned) {
      _updates.add(PurchaseEvent(id, PurchaseEventKind.owned));
    }
  }

  @override
  Stream<PurchaseEvent> get updates => _updates.stream;

  @override
  void dispose() => _updates.close();
}

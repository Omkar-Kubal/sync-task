import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/crash/crash_reporter.dart';
import '../../settings/providers/settings_controller.dart';
import 'receipt_pro_billing_service.dart';
import 'receipt_pro_products.dart';

final receiptProBillingServiceProvider = Provider<ReceiptProBillingService>((
  ref,
) {
  return InAppPurchaseReceiptProBillingService();
});

final receiptProEntitlementStoreProvider = Provider<ReceiptProEntitlementStore>(
  (ref) {
    return SharedPreferencesReceiptProEntitlementStore(
      ref.watch(sharedPreferencesProvider),
    );
  },
);

final receiptProEntitlementProvider =
    AsyncNotifierProvider<ReceiptProEntitlement, ReceiptProEntitlementState>(
      ReceiptProEntitlement.new,
    );

enum ReceiptProEntitlementStatus {
  catalogLoading,
  purchasing,
  restoring,
  pending,
  pro,
  free,
  error,
}

class ReceiptProEntitlementState {
  const ReceiptProEntitlementState({
    required this.status,
    required this.catalog,
    this.message,
  });

  final ReceiptProEntitlementStatus status;
  final ReceiptProCatalog catalog;
  final String? message;

  bool get isPro => status == ReceiptProEntitlementStatus.pro;

  ReceiptProEntitlementState copyWith({
    ReceiptProEntitlementStatus? status,
    ReceiptProCatalog? catalog,
    String? message,
    bool clearMessage = false,
  }) {
    return ReceiptProEntitlementState(
      status: status ?? this.status,
      catalog: catalog ?? this.catalog,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}

abstract interface class ReceiptProEntitlementStore {
  Future<bool> isUnlocked();
  Future<void> saveUnlimitedReceiptsUnlock();
  Future<void> clearUnlock();
}

class SharedPreferencesReceiptProEntitlementStore
    implements ReceiptProEntitlementStore {
  const SharedPreferencesReceiptProEntitlementStore(this._preferences);

  static const _unlockedKey = 'receipt_pro_unlimited_unlocked';
  static const _productIdKey = 'receipt_pro_product_id';
  static const _purchasedAtKey = 'receipt_pro_purchased_at';

  final SharedPreferences? _preferences;

  Future<SharedPreferences> get _store async =>
      _preferences ?? SharedPreferences.getInstance();

  @override
  Future<bool> isUnlocked() async {
    final preferences = await _store;
    final unlocked = preferences.getBool(_unlockedKey) ?? false;
    final productId = preferences.getString(_productIdKey);
    return unlocked && productId == syncTasksReceiptsUnlimitedProductId;
  }

  @override
  Future<void> saveUnlimitedReceiptsUnlock() async {
    final preferences = await _store;
    final results = await Future.wait([
      preferences.setBool(_unlockedKey, true),
      preferences.setString(_productIdKey, syncTasksReceiptsUnlimitedProductId),
      preferences.setString(
        _purchasedAtKey,
        DateTime.now().toUtc().toIso8601String(),
      ),
    ]);
    if (results.any((saved) => !saved)) {
      throw StateError('Unable to persist the receipt purchase.');
    }
  }

  @override
  Future<void> clearUnlock() async {
    final preferences = await _store;
    final results = await Future.wait([
      preferences.remove(_unlockedKey),
      preferences.remove(_productIdKey),
      preferences.remove(_purchasedAtKey),
    ]);
    if (results.any((removed) => !removed)) {
      throw StateError('Unable to clear the receipt purchase.');
    }
  }
}

class ReceiptProEntitlement extends AsyncNotifier<ReceiptProEntitlementState> {
  StreamSubscription<List<ReceiptProPurchaseEvent>>? _purchaseSubscription;
  Future<void> _ownershipMutationTail = Future<void>.value();
  int _ownershipQueryGeneration = 0;
  int _ownershipRevision = 0;

  ReceiptProBillingService get _billing =>
      ref.read(receiptProBillingServiceProvider);
  ReceiptProEntitlementStore get _store =>
      ref.read(receiptProEntitlementStoreProvider);

  @override
  Future<ReceiptProEntitlementState> build() async {
    final service = ref.watch(receiptProBillingServiceProvider);
    ref.watch(receiptProEntitlementStoreProvider);
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = service.purchaseUpdates.listen(
      _handlePurchases,
      onError: _handlePurchaseStreamError,
    );
    ref.onDispose(() => _purchaseSubscription?.cancel());

    final locallyUnlocked = await _readCachedUnlock(
      fallback: false,
      source: 'startup',
    );
    final available = await _isBillingAvailable(service);
    if (!available) {
      return ReceiptProEntitlementState(
        status: locallyUnlocked
            ? ReceiptProEntitlementStatus.pro
            : ReceiptProEntitlementStatus.error,
        catalog: ReceiptProCatalog.unavailable(
          'Payments are not available on this device.',
        ),
        message: 'Payments are not available on this device.',
      );
    }

    final catalog = await _loadCatalog(service);
    final revision = _ownershipRevision;
    final queryGeneration = ++_ownershipQueryGeneration;
    final ownership = await service.queryOwnership();
    return _serializeOwnership(() async {
      if (queryGeneration != _ownershipQueryGeneration ||
          revision != _ownershipRevision) {
        final latest = state.value;
        final unlocked = await _readCachedUnlock(
          fallback: latest?.isPro ?? false,
          source: 'startup_stale',
        );
        return latest?.isPro == true || unlocked
            ? ReceiptProEntitlementState(
                status: ReceiptProEntitlementStatus.pro,
                catalog: catalog,
              )
            : latest ??
                  ReceiptProEntitlementState(
                    status: ReceiptProEntitlementStatus.free,
                    catalog: catalog,
                  );
      }
      return _stateFromOwnership(
        ownership,
        catalog: catalog,
        locallyUnlocked: locallyUnlocked,
        source: 'startup',
      );
    });
  }

  Future<void> buyUnlimitedReceipts() async {
    final current = await future;
    if (current.isPro ||
        current.status == ReceiptProEntitlementStatus.purchasing) {
      return;
    }
    final plan = current.catalog.unlimitedReceipts;
    if (!plan.available || plan.price == null) {
      state = AsyncData(
        current.copyWith(
          status: ReceiptProEntitlementStatus.error,
          message:
              plan.unavailableReason ??
              'Unlimited receipts are not available yet.',
        ),
      );
      return;
    }

    state = AsyncData(
      current.copyWith(
        status: ReceiptProEntitlementStatus.purchasing,
        clearMessage: true,
      ),
    );
    _breadcrumb('purchase_started');
    try {
      await _billing.buyUnlimitedReceipts();
    } catch (_) {
      _breadcrumb('purchase_launch_error');
      state = AsyncData(
        current.copyWith(
          status: ReceiptProEntitlementStatus.error,
          message: 'Google Play could not start the purchase. Please retry.',
        ),
      );
    }
  }

  Future<void> restore() => reconcile(source: 'restore', restoring: true);

  void clearTransientMessage() {
    final current = state.value;
    if (current == null ||
        current.message == null ||
        current.status != ReceiptProEntitlementStatus.free) {
      return;
    }
    state = AsyncData(current.copyWith(clearMessage: true));
  }

  Future<void> reconcile({
    String source = 'manual',
    bool restoring = false,
  }) async {
    final current = await future;
    if (restoring) {
      state = AsyncData(
        current.copyWith(
          status: ReceiptProEntitlementStatus.restoring,
          clearMessage: true,
        ),
      );
    }

    _breadcrumb('${source}_query_started');
    final revision = _ownershipRevision;
    final queryGeneration = ++_ownershipQueryGeneration;
    final ownership = await _billing.queryOwnership();
    await _serializeOwnership(() async {
      if (queryGeneration != _ownershipQueryGeneration ||
          revision != _ownershipRevision) {
        _breadcrumb('${source}_stale_result_ignored');
        return;
      }
      final next = await _stateFromOwnership(
        ownership,
        catalog: current.catalog,
        locallyUnlocked: await _readCachedUnlock(
          fallback: current.isPro,
          source: source,
        ),
        source: source,
        emptyMessage: restoring
            ? 'No active unlimited receipts purchase found.'
            : null,
      );
      state = AsyncData(next);
    });
  }

  Future<void> retry() async {
    var current = await future;
    final plan = current.catalog.unlimitedReceipts;
    if (!plan.available) {
      await reloadCatalog();
      current = await future;
      if (!current.catalog.unlimitedReceipts.available) return;
    }
    await reconcile(source: 'retry');
  }

  Future<void> reloadCatalog() async {
    final current = await future;
    state = AsyncData(
      current.copyWith(
        status: ReceiptProEntitlementStatus.catalogLoading,
        clearMessage: true,
      ),
    );
    final available = await _isBillingAvailable(_billing);
    if (!available) {
      state = AsyncData(
        current.copyWith(
          status: current.isPro
              ? ReceiptProEntitlementStatus.pro
              : ReceiptProEntitlementStatus.error,
          catalog: ReceiptProCatalog.unavailable(
            'Payments are not available on this device.',
          ),
          message: 'Payments are not available on this device.',
        ),
      );
      return;
    }

    final revision = _ownershipRevision;
    final catalog = await _loadCatalog(_billing);
    if (revision != _ownershipRevision) return;
    state = AsyncData(
      current.copyWith(
        status: current.isPro
            ? ReceiptProEntitlementStatus.pro
            : ReceiptProEntitlementStatus.free,
        catalog: catalog,
        message: catalog.errorMessage,
        clearMessage: catalog.errorMessage == null,
      ),
    );
  }

  Future<ReceiptProEntitlementState> _stateFromOwnership(
    ReceiptProOwnershipSnapshot ownership, {
    required ReceiptProCatalog catalog,
    required bool locallyUnlocked,
    required String source,
    String? emptyMessage,
  }) async {
    if (ownership.ownsUnlimitedReceipts) {
      try {
        final acknowledged = await _deliverOwnedPurchases(ownership.events);
        _breadcrumb('${source}_owned');
        return ReceiptProEntitlementState(
          status: ReceiptProEntitlementStatus.pro,
          catalog: catalog,
          message: acknowledged
              ? null
              : 'Purchase is active. Google Play confirmation will retry.',
        );
      } catch (_) {
        _breadcrumb('${source}_persistence_error');
        return ReceiptProEntitlementState(
          status: locallyUnlocked
              ? ReceiptProEntitlementStatus.pro
              : ReceiptProEntitlementStatus.error,
          catalog: catalog,
          message: locallyUnlocked
              ? 'Unlimited receipts are active, but confirmation could not be refreshed.'
              : 'Purchase confirmed, but access could not be saved. Please restore.',
        );
      }
    }

    if (!ownership.isAuthoritative) {
      _breadcrumb('${source}_query_error');
      return ReceiptProEntitlementState(
        status: locallyUnlocked
            ? ReceiptProEntitlementStatus.pro
            : ReceiptProEntitlementStatus.error,
        catalog: catalog,
        message:
            ownership.queryError ??
            'Unable to verify purchases with Google Play.',
      );
    }

    try {
      await _store.clearUnlock();
    } catch (_) {
      _breadcrumb('${source}_clear_error');
      return ReceiptProEntitlementState(
        status: locallyUnlocked
            ? ReceiptProEntitlementStatus.pro
            : ReceiptProEntitlementStatus.error,
        catalog: catalog,
        message: 'Unable to update receipt purchase access. Please retry.',
      );
    }

    if (ownership.pendingUnlimitedReceipts) {
      _breadcrumb('${source}_pending');
      return ReceiptProEntitlementState(
        status: ReceiptProEntitlementStatus.pending,
        catalog: catalog,
        message:
            'Purchase pending. Unlimited receipts unlock after payment is confirmed.',
      );
    }

    _breadcrumb('${source}_free');
    return ReceiptProEntitlementState(
      status: ReceiptProEntitlementStatus.free,
      catalog: catalog,
      message: emptyMessage,
    );
  }

  Future<void> _handlePurchases(List<ReceiptProPurchaseEvent> events) async {
    if (events.any(
      (event) => event.productId == syncTasksReceiptsUnlimitedProductId,
    )) {
      _ownershipQueryGeneration++;
    }
    await _serializeOwnership(() async {
      for (final event in events) {
        final isReceiptProduct =
            event.productId == syncTasksReceiptsUnlimitedProductId;
        if (!isReceiptProduct) continue;
        final current =
            state.value ??
            ReceiptProEntitlementState(
              status: ReceiptProEntitlementStatus.catalogLoading,
              catalog: ReceiptProCatalog.fromProductPrices(const {}),
            );
        switch (event.state) {
          case ReceiptProPurchaseState.purchased:
          case ReceiptProPurchaseState.restored:
            try {
              final acknowledged = await _deliverOwnedPurchases([event]);
              _breadcrumb('purchase_delivered');
              state = AsyncData(
                current.copyWith(
                  status: ReceiptProEntitlementStatus.pro,
                  message: acknowledged
                      ? null
                      : 'Purchase is active. Google Play confirmation will retry.',
                  clearMessage: acknowledged,
                ),
              );
            } catch (_) {
              _breadcrumb('purchase_delivery_error');
              state = AsyncData(
                current.copyWith(
                  status: ReceiptProEntitlementStatus.error,
                  message:
                      'Purchase confirmed, but access could not be saved. Please restore.',
                ),
              );
            }
          case ReceiptProPurchaseState.pending:
            if (current.isPro) continue;
            _breadcrumb('purchase_pending');
            state = AsyncData(
              current.copyWith(
                status: ReceiptProEntitlementStatus.pending,
                message:
                    'Purchase pending. Unlimited receipts unlock after payment is confirmed.',
              ),
            );
          case ReceiptProPurchaseState.canceled:
            if (current.isPro) continue;
            _breadcrumb('purchase_canceled');
            state = AsyncData(
              current.copyWith(
                status: ReceiptProEntitlementStatus.free,
                clearMessage: true,
              ),
            );
          case ReceiptProPurchaseState.error:
            if (current.isPro) continue;
            _breadcrumb('purchase_error');
            state = AsyncData(
              current.copyWith(
                status: ReceiptProEntitlementStatus.error,
                message: 'The purchase did not complete. Please retry.',
              ),
            );
        }
      }
    });
  }

  Future<void> _handlePurchaseStreamError(Object _, StackTrace __) async {
    await _serializeOwnership(() async {
      final current =
          state.value ??
          ReceiptProEntitlementState(
            status: ReceiptProEntitlementStatus.catalogLoading,
            catalog: ReceiptProCatalog.fromProductPrices(const {}),
          );
      if (current.isPro) return;
      _breadcrumb('purchase_stream_error');
      state = AsyncData(
        current.copyWith(
          status: ReceiptProEntitlementStatus.error,
          message:
              'Google Play purchase updates were interrupted. Please retry.',
        ),
      );
    });
  }

  Future<T> _serializeOwnership<T>(Future<T> Function() action) {
    final result = Completer<T>();
    _ownershipMutationTail = _ownershipMutationTail.then((_) async {
      try {
        result.complete(await action());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

  Future<bool> _readCachedUnlock({
    required bool fallback,
    required String source,
  }) async {
    try {
      return await _store.isUnlocked();
    } catch (_) {
      _breadcrumb('${source}_cache_read_error');
      return fallback;
    }
  }

  Future<bool> _deliverOwnedPurchases(
    List<ReceiptProPurchaseEvent> events,
  ) async {
    final ownedEvents = events.where(
      (event) =>
          event.productId == syncTasksReceiptsUnlimitedProductId &&
          (event.state == ReceiptProPurchaseState.purchased ||
              event.state == ReceiptProPurchaseState.restored),
    );
    if (ownedEvents.isEmpty) return true;

    await _store.saveUnlimitedReceiptsUnlock();
    _ownershipRevision++;
    var acknowledged = true;
    for (final event in ownedEvents) {
      if (!event.pendingCompletePurchase) continue;
      try {
        await _billing.completePurchase(event);
      } catch (_) {
        acknowledged = false;
        _breadcrumb('purchase_acknowledgment_error');
      }
    }
    return acknowledged;
  }

  Future<bool> _isBillingAvailable(ReceiptProBillingService service) async {
    try {
      return await service.isAvailable();
    } catch (_) {
      _breadcrumb('billing_availability_error');
      return false;
    }
  }

  Future<ReceiptProCatalog> _loadCatalog(
    ReceiptProBillingService service,
  ) async {
    try {
      return await service.loadCatalog();
    } catch (_) {
      _breadcrumb('catalog_query_error');
      return ReceiptProCatalog.unavailable(
        'Unable to load the Google Play product. Please retry.',
      );
    }
  }

  void _breadcrumb(String message) {
    CrashReporter.unawaitedCapture(
      CrashReporter.addBreadcrumb(message, category: 'receipt_billing'),
      hint: 'Receipt billing breadcrumb failed',
    );
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// MonetizationService — نظام تحقيق الدخل الهجين.
///
/// النموذج:
///   • Free: 7 مدخلات/شهر + 3 بذور
///   • Pro Monthly: 4.99$ → غير محدود
///   • Pro Yearly: 29.99$ (توفير 50%)
///   • Lifetime: 79.99$ (دفعة واحدة)
class MonetizationService extends StateNotifier<MonetizationState> {
  MonetizationService() : super(const MonetizationState()) {
    _init();
  }

  static final _iap = InAppPurchase.instance;

  // ═══════════════════════════════════════════════════════════════
  // Product IDs — يجب إنشاؤها في Play Console و App Store
  // ═══════════════════════════════════════════════════════════════
  static const String proMonthlyId = 'nabd_pro_monthly';
  static const String proYearlyId = 'nabd_pro_yearly';
  static const String lifetimeId = 'nabd_lifetime';

  static const Set<String> productIds = {
    proMonthlyId,
    proYearlyId,
    lifetimeId,
  };

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  // ═══════════════════════════════════════════════════════════════
  // Init
  // ═══════════════════════════════════════════════════════════════

  Future<void> _init() async {
    final available = await _iap.isAvailable();
    if (!available) {
      state = state.copyWith(storeAvailable: false);
      return;
    }

    state = state.copyWith(storeAvailable: true);
    _purchaseSub = _iap.purchaseStream.listen(_onPurchaseUpdate);

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final response = await _iap.queryProductDetails(productIds);
      state = state.copyWith(
        products: response.productDetails,
        error: response.error?.message,
      );
    } catch (e) {
      state = state.copyWith(error: '$e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Purchase Flow
  // ═══════════════════════════════════════════════════════════════

  Future<void> buy(ProductDetails product) async {
    state = state.copyWith(purchasing: true, error: null);
    try {
      final param = PurchaseParam(productDetails: product);
      if (product.id == lifetimeId) {
        await _iap.buyNonConsumable(purchaseParam: param);
      } else {
        await _iap.buyNonConsumable(purchaseParam: param);
      }
    } catch (e) {
      state = state.copyWith(purchasing: false, error: '$e');
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(restoring: true, error: null);
    try {
      await _iap.restorePurchases();
    } catch (e) {
      state = state.copyWith(restoring: false, error: '$e');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _deliverProduct(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        state = state.copyWith(
          purchasing: false,
          error: purchase.error?.message,
        );
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    switch (purchase.productID) {
      case proMonthlyId:
      case proYearlyId:
        // The store callback does not contain a verified subscription expiry.
        // Do not invent one or persist an editable local entitlement.
        state = state.copyWith(
          purchasing: false,
          restoring: false,
          error: 'Subscription requires server-side entitlement verification.',
        );
        return;
      case lifetimeId:
        // Lifetime purchases are accepted only for this session until a
        // production receipt verifier is connected; nothing is persisted.
        state = state.copyWith(
          isPro: true,
          isLifetime: true,
          purchasing: false,
          restoring: false,
        );
        return;
    }
    state = state.copyWith(restoring: false, purchasing: false);
  }

  // ═══════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════

  /// هل المستخدم Pro نشط؟
  bool get isProActive {
    if (state.isLifetime) return true;
    if (!state.isPro) return false;
    if (state.proExpiry == null) return true;
    return state.proExpiry!.isAfter(DateTime.now());
  }

  /// فحص إذا كان بإمكان المستخدم كتابة مذكرة.
  bool canWriteEntry({required int currentMonthEntries}) {
    if (isProActive) return true;
    return currentMonthEntries < 7;
  }

  /// عدد المدخلات المتبقية هذا الشهر.
  int remainingEntries({required int currentMonthEntries}) {
    if (isProActive) return -1; // غير محدود
    return (7 - currentMonthEntries).clamp(0, 7);
  }

  /// نص السعر للعرض.
  String priceFor(String productId) {
    try {
      final product = state.products.firstWhere((p) => p.id == productId);
      return product.price;
    } catch (_) {
      // Fallback
      switch (productId) {
        case proMonthlyId:
          return '\$4.99';
        case proYearlyId:
          return '\$29.99';
        case lifetimeId:
          return '\$79.99';
        default:
          return '';
      }
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}

class MonetizationState {
  final bool storeAvailable;
  final bool isPro;
  final bool isLifetime;
  final DateTime? proExpiry;
  final bool purchasing;
  final bool restoring;
  final List<ProductDetails> products;
  final String? error;

  const MonetizationState({
    this.storeAvailable = false,
    this.isPro = false,
    this.isLifetime = false,
    this.proExpiry,
    this.purchasing = false,
    this.restoring = false,
    this.products = const [],
    this.error,
  });

  MonetizationState copyWith({
    bool? storeAvailable,
    bool? isPro,
    bool? isLifetime,
    DateTime? proExpiry,
    bool? purchasing,
    bool? restoring,
    List<ProductDetails>? products,
    String? error,
  }) =>
      MonetizationState(
        storeAvailable: storeAvailable ?? this.storeAvailable,
        isPro: isPro ?? this.isPro,
        isLifetime: isLifetime ?? this.isLifetime,
        proExpiry: proExpiry ?? this.proExpiry,
        purchasing: purchasing ?? this.purchasing,
        restoring: restoring ?? this.restoring,
        products: products ?? this.products,
        error: error,
      );
}

final monetizationProvider =
    StateNotifierProvider<MonetizationService, MonetizationState>(
  (_) => MonetizationService(),
);

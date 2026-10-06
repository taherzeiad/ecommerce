import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/cart_repository.dart';
import '../../../domain/repositories/coupon_repository.dart';
import '../../../domain/repositories/order_repository.dart';

double _round2(double value) => (value * 100).roundToDouble() / 100;

class CartViewModel extends ChangeNotifier {
  /// Must match place_order() in supabase/migrations.
  static const double deliveryFee = 12;
  static const double taxRate = 0.05;

  final CartRepository _cartRepository;
  final OrderRepository? _orderRepository;
  final CouponRepository? _couponRepository;

  CartViewModel({
    required CartRepository cartRepository,
    OrderRepository? orderRepository,
    CouponRepository? couponRepository,
  }) : _cartRepository = cartRepository,
       _orderRepository = orderRepository,
       _couponRepository = couponRepository;

  List<CartItemEntity> _items = [];
  List<CartItemEntity> get items => List.unmodifiable(_items);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoaded = false;

  /// True only while there is nothing to show yet, so quantity changes
  /// don't replace the whole cart with a spinner.
  bool get isInitialLoading => _isLoading && !_hasLoaded;

  String? _errorMessage;

  /// Translation key of the last failed load, `null` when it worked.
  String? get errorMessage => _errorMessage;

  CouponEntity? _coupon;
  CouponEntity? get coupon => _coupon;

  bool _isPlacingOrder = false;
  bool get isPlacingOrder => _isPlacingOrder;

  String? _orderError;

  /// Translation key explaining why the last [placeOrder] failed.
  String? get orderError => _orderError;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal =>
      _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  double get discount =>
      _coupon == null ? 0 : _round2(subtotal * _coupon!.discountPercent / 100);
  double get deliveryFees => _items.isEmpty ? 0 : deliveryFee;
  double get taxes => _round2((subtotal - discount) * taxRate);
  double get totalPrice => subtotal - discount + deliveryFees + taxes;

  Future<void> fetchCartItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _cartRepository.getCartItems();
      _hasLoaded = true;
      _errorMessage = null;
      if (_coupon != null && subtotal < _coupon!.minOrder) _coupon = null;
    } catch (e) {
      _errorMessage = errorKeyFor(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns `false` when the product could not be added.
  Future<bool> addToCart(ProductEntity product, {int quantity = 1}) async {
    try {
      await _cartRepository.addToCart(product.id, quantity);
    } catch (e) {
      debugPrint('🔴 [Cart Error] Failed to add to cart: $e');
      return false;
    }
    await fetchCartItems();
    return true;
  }

  /// Removes the line from the UI right away (a swiped `Dismissible` must not
  /// be rebuilt), then syncs with the server; a failure restores the list.
  Future<void> removeFromCart(dynamic cartItemId) async {
    _items = _items.where((item) => item.id != cartItemId).toList();
    notifyListeners();
    try {
      await _cartRepository.removeFromCart(cartItemId);
    } catch (e) {
      await fetchCartItems();
    }
  }

  Future<bool> incrementQuantity(CartItemEntity item) =>
      _setQuantity(item, item.quantity + 1);

  Future<bool> decrementQuantity(CartItemEntity item) async {
    if (item.quantity <= 1) return true;
    return _setQuantity(item, item.quantity - 1);
  }

  Future<bool> _setQuantity(CartItemEntity item, int quantity) async {
    try {
      await _cartRepository.updateQuantity(item.id, quantity);
    } catch (e) {
      return false;
    }
    await fetchCartItems();
    return true;
  }

  Future<void> clearCart() async {
    try {
      await _cartRepository.clearCart();
      await fetchCartItems();
    } catch (e) {
      // The list keeps showing what is really in the cart.
    }
  }

  /// Applies a discount code. Returns a translation key describing the
  /// problem, or `null` when the coupon was applied.
  Future<String?> applyCoupon(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty || _couponRepository == null) {
      return 'error_invalid_coupon';
    }
    try {
      final coupon = await _couponRepository.findCoupon(trimmed);
      if (coupon == null || coupon.isExpired) return 'error_invalid_coupon';
      if (subtotal < coupon.minOrder) return 'error_coupon_min_order';
      _coupon = coupon;
      notifyListeners();
      return null;
    } catch (e) {
      return errorKeyFor(e);
    }
  }

  void removeCoupon() {
    _coupon = null;
    notifyListeners();
  }

  /// Places the order on the server, which also empties the cart.
  /// Returns the new order id, or `null` with [orderError] set.
  Future<String?> placeOrder({
    required String? addressId,
    required PaymentMethod paymentMethod,
    String? cardLast4,
  }) async {
    String? fail(String key) {
      _orderError = key;
      notifyListeners();
      return null;
    }

    if (_orderRepository == null) return fail('error_unexpected');
    if (addressId == null) return fail('no_address_msg');
    if (_items.isEmpty) return fail('cart_empty');
    if (paymentMethod == PaymentMethod.card && cardLast4 == null) {
      return fail('error_select_card');
    }

    _isPlacingOrder = true;
    _orderError = null;
    notifyListeners();
    try {
      final orderId = await _orderRepository.placeOrder(
        addressId: addressId,
        paymentMethod: paymentMethod,
        cardLast4: cardLast4,
        couponCode: _coupon?.code,
      );
      _items = [];
      _coupon = null;
      return orderId;
    } catch (e) {
      _orderError = errorKeyFor(e);
      if (_orderError == 'error_invalid_coupon') _coupon = null;
      return null;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }
}

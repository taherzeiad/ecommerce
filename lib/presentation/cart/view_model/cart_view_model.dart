import 'package:flutter/material.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/cart_repository.dart';
import '../../../domain/repositories/order_repository.dart';

class CartViewModel extends ChangeNotifier {
  final CartRepository _cartRepository;
  final OrderRepository? _orderRepository;

  CartViewModel({required CartRepository cartRepository, OrderRepository? orderRepository})
      : _cartRepository = cartRepository,
        _orderRepository = orderRepository;

  List<CartItemEntity> _items = [];
  List<CartItemEntity> get items => List.unmodifiable(_items);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  double get deliveryFees => _items.isEmpty ? 0 : 12.0;
  double get taxes => subtotal * 0.05;
  double get totalPrice => subtotal + deliveryFees + taxes;

  Future<void> fetchCartItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _cartRepository.getCartItems();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(ProductEntity product, {int quantity = 1}) async {
    try {
      await _cartRepository.addToCart(product.id, quantity);
      await fetchCartItems();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeFromCart(dynamic cartItemId) async {
    try {
      await _cartRepository.removeFromCart(cartItemId);
      await fetchCartItems();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> incrementQuantity(CartItemEntity item) async {
    try {
      await _cartRepository.updateQuantity(item.id, item.quantity + 1);
      await fetchCartItems();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> decrementQuantity(CartItemEntity item) async {
    if (item.quantity > 1) {
      try {
        await _cartRepository.updateQuantity(item.id, item.quantity - 1);
        await fetchCartItems();
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartRepository.clearCart();
      await fetchCartItems();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> placeOrder(dynamic addressId) async {
    if (_orderRepository == null) return;
    try {
      await _orderRepository.createOrder(totalPrice, addressId);
      await clearCart();
    } catch (e) {
      // Handle error
    }
  }
}

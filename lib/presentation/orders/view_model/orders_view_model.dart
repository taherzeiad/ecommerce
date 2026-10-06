import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/repositories/order_repository.dart';

class OrdersViewModel extends ChangeNotifier {
  OrdersViewModel({required OrderRepository orderRepository})
    : _orderRepository = orderRepository;

  final OrderRepository _orderRepository;

  List<OrderEntity> _orders = [];
  List<OrderEntity> get orders => List.unmodifiable(_orders);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _orders = await _orderRepository.getOrders();
    } catch (e) {
      _errorMessage = errorKeyFor(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  OrderEntity? orderById(String id) =>
      _orders.where((o) => o.id == id).firstOrNull;

  /// Loads one order fresh from the server (e.g. to see a status change).
  Future<OrderEntity?> loadOrder(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final order = await _orderRepository.getOrder(id);
      if (order != null) {
        _orders = [order, ..._orders.where((o) => o.id != id)]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return order;
      }

      final existing = orderById(id);
      if (existing != null) return existing;

      final fallback = OrderEntity(
        id: id,
        status: OrderStatus.pending,
        subtotal: 0.0,
        deliveryFee: 12.0,
        tax: 0.0,
        totalAmount: 12.0,
        paymentMethod: PaymentMethod.cash,
        createdAt: DateTime.now(),
        items: const [],
      );
      _orders = [fallback, ..._orders];
      return fallback;
    } catch (e) {
      _errorMessage = errorKeyFor(e);
      return orderById(id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

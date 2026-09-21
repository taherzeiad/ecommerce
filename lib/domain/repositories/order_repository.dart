import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders();
  Future<void> createOrder(double totalAmount, dynamic addressId);
}

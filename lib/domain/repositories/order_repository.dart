import '../entities/order_entity.dart';

abstract class OrderRepository {
  /// The signed-in user's orders, newest first, with their items.
  Future<List<OrderEntity>> getOrders();

  Future<OrderEntity?> getOrder(String orderId);

  /// Turns the user's cart into an order on the server (prices, coupon and
  /// totals are computed there) and empties the cart. Returns the order id.
  Future<String> placeOrder({
    required String addressId,
    required PaymentMethod paymentMethod,
    String? cardLast4,
    String? couponCode,
  });
}

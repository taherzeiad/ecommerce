import '../../domain/entities/order_entity.dart';

double _toDouble(Object? value) => (value as num?)?.toDouble() ?? 0;

class OrderModel {
  OrderModel._();

  /// Parses a row of `orders`, optionally with embedded `order_items`.
  static OrderEntity fromJson(Map<String, dynamic> json) {
    final items = (json['order_items'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(
          (item) => OrderItemEntity(
            productId: item['product_id'] as String?,
            productName: item['product_name'] as String? ?? '',
            imageUrl: item['image_url'] as String?,
            unitPrice: _toDouble(item['unit_price']),
            quantity: item['quantity'] as int? ?? 1,
          ),
        )
        .toList();

    return OrderEntity(
      id: json['id'] as String,
      status: OrderStatus.fromName(json['status'] as String?),
      subtotal: _toDouble(json['subtotal']),
      discount: _toDouble(json['discount']),
      deliveryFee: _toDouble(json['delivery_fee']),
      tax: _toDouble(json['tax']),
      totalAmount: _toDouble(json['total_amount']),
      couponCode: json['coupon_code'] as String?,
      paymentMethod: PaymentMethod.fromName(json['payment_method'] as String?),
      cardLast4: json['card_last4'] as String?,
      shippingName: json['shipping_name'] as String?,
      shippingPhone: json['shipping_phone'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      items: items,
    );
  }
}

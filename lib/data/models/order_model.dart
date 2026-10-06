import '../../domain/entities/order_entity.dart';

double _toDouble(Object? value) => (value as num?)?.toDouble() ?? 0.0;

class OrderModel {
  OrderModel._();

  /// Parses a row of `orders`, optionally with embedded `order_items`.
  static OrderEntity fromJson(Map<String, dynamic> json) {
    final itemsList = (json['order_items'] as List<dynamic>? ?? const []);
    final items = itemsList
        .map((itemJson) {
          final item = itemJson as Map<String, dynamic>;
          final product = item['products'] as Map<String, dynamic>?;
          final List<dynamic>? productImages = product?['images'] as List<dynamic>?;

          return OrderItemEntity(
            productId: item['product_id']?.toString(),
            productName:
                (item['product_name'] ?? product?['name'] ?? 'Product')
                    as String,
            imageUrl:
                (item['image_url'] ??
                        productImages?.firstOrNull?.toString())
                    as String?,
            unitPrice: _toDouble(
              item['unit_price'] ?? item['price'] ?? product?['price'],
            ),
            quantity: (item['quantity'] as num?)?.toInt() ?? 1,
          );
        })
        .toList();

    DateTime parsedDate;
    try {
      parsedDate = json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString()).toLocal()
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final double subtotal = _toDouble(json['subtotal'] ?? json['sub_total']);
    final double discount = _toDouble(json['discount']);
    final double deliveryFee = _toDouble(
      json['delivery_fee'] ?? json['delivery_fees'] ?? 12.0,
    );
    final double tax = _toDouble(json['tax'] ?? json['taxes']);
    final double totalAmount = _toDouble(
      json['total_amount'] ??
          json['total'] ??
          (subtotal + deliveryFee + tax - discount),
    );

    return OrderEntity(
      id:
          json['id']?.toString() ??
          'ORD-${DateTime.now().millisecondsSinceEpoch}',
      status: OrderStatus.fromName((json['status'] as String?)?.toLowerCase()),
      subtotal: subtotal,
      discount: discount,
      deliveryFee: deliveryFee,
      tax: tax,
      totalAmount: totalAmount,
      couponCode: json['coupon_code']?.toString(),
      paymentMethod: PaymentMethod.fromName(
        json['payment_method']?.toString(),
      ),
      cardLast4:
          json['card_last4']?.toString() ?? json['card_last_4']?.toString(),
      shippingName:
          (json['shipping_name'] ?? json['full_name'] ?? json['name'])
              ?.toString(),
      shippingPhone:
          (json['shipping_phone'] ?? json['phone_number'] ?? json['phone'])
              ?.toString(),
      shippingAddress:
          (json['shipping_address'] ??
                  json['street_address'] ??
                  json['address'])
              ?.toString(),
      createdAt: parsedDate,
      items: items,
    );
  }
}

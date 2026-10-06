enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromName(String? name) => OrderStatus.values.firstWhere(
    (s) => s.name == name,
    orElse: () => OrderStatus.pending,
  );

  /// Translation key, e.g. `order_status_shipped`.
  String get labelKey => 'order_status_$name';
}

enum PaymentMethod {
  card,
  cash;

  static PaymentMethod fromName(String? name) =>
      name == 'card' ? PaymentMethod.card : PaymentMethod.cash;
}

class OrderItemEntity {
  final String? productId;
  final String productName;
  final String? imageUrl;
  final double unitPrice;
  final int quantity;

  const OrderItemEntity({
    this.productId,
    required this.productName,
    this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;
}

class OrderEntity {
  final String id;
  final OrderStatus status;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double tax;
  final double totalAmount;
  final String? couponCode;
  final PaymentMethod paymentMethod;
  final String? cardLast4;
  final String? shippingName;
  final String? shippingPhone;
  final String? shippingAddress;
  final DateTime createdAt;
  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    required this.status,
    required this.subtotal,
    this.discount = 0,
    required this.deliveryFee,
    required this.tax,
    required this.totalAmount,
    this.couponCode,
    required this.paymentMethod,
    this.cardLast4,
    this.shippingName,
    this.shippingPhone,
    this.shippingAddress,
    required this.createdAt,
    this.items = const [],
  });

  /// Short, readable order number shown to the user.
  String get number => shortOrderNumber(id);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

/// First 8 characters of an order id, upper-cased (`#1A2B3C4D`).
String shortOrderNumber(String id) =>
    (id.length > 8 ? id.substring(0, 8) : id).toUpperCase();

class OrderEntity {
  final String id;
  final String userId;
  final double totalAmount;
  final String status;
  final dynamic addressId;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.addressId,
    required this.createdAt,
  });
}

class NotificationEntity {
  final dynamic id;
  final String titleKey;
  final String descriptionKey;

  /// `orders`, `system` or `promo`.
  final String type;
  final bool isRead;

  /// Set for order updates; the description shows its short number.
  final String? orderId;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.type,
    this.isRead = false,
    this.orderId,
    required this.createdAt,
  });

  NotificationEntity markedRead() => NotificationEntity(
    id: id,
    titleKey: titleKey,
    descriptionKey: descriptionKey,
    type: type,
    isRead: true,
    orderId: orderId,
    createdAt: createdAt,
  );
}

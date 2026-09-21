class NotificationEntity {
  final dynamic id;
  final String titleKey;
  final String descriptionKey;
  final String type;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.type,
    required this.createdAt,
  });
}

import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Stream<List<NotificationEntity>> watchNotifications();
  Future<void> markAsRead(dynamic notificationId);
  Future<void> markAllAsRead();
}

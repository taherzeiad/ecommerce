import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../domain/repositories/notification_repository.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationRepository _notificationRepository;

  NotificationsViewModel({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository;

  List<NotificationEntity> _notifications = [];
  List<NotificationEntity> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _notifications = await _notificationRepository.getNotifications();
    } catch (e) {
      _errorMessage = errorKeyFor(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(NotificationEntity notification) async {
    if (notification.isRead) return;
    _notifications = [
      for (final n in _notifications)
        n.id == notification.id ? n.markedRead() : n,
    ];
    notifyListeners();
    try {
      await _notificationRepository.markAsRead(notification.id);
    } catch (e) {
      // Shown as unread again next time it is loaded.
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;
    _notifications = [for (final n in _notifications) n.markedRead()];
    notifyListeners();
    try {
      await _notificationRepository.markAllAsRead();
    } catch (e) {
      // Shown as unread again next time it is loaded.
    }
  }
}

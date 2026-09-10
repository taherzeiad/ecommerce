import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';

enum NotificationType { unread, orders, system }

class NotificationItem {
  final String titleKey;
  final String descriptionKey;
  final String time;
  final IconData icon;
  final Color color;
  final NotificationType type;

  NotificationItem({
    required this.titleKey,
    required this.descriptionKey,
    required this.time,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  int _selectedIndex = 0;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      titleKey: 'notif_order_way_title',
      descriptionKey: 'notif_order_way_desc',
      time: '2 minutes ago',
      icon: Icons.local_shipping,
      color: AppColors.primary,
      type: NotificationType.orders,
    ),
    NotificationItem(
      titleKey: 'notif_payment_success_title',
      descriptionKey: 'notif_payment_success_desc',
      time: '1 hour ago',
      icon: Icons.payment,
      color: Colors.teal,
      type: NotificationType.unread,
    ),
    NotificationItem(
      titleKey: 'notif_order_confirmed_title',
      descriptionKey: 'notif_order_confirmed_desc',
      time: '2 hours ago',
      icon: Icons.check_circle,
      color: AppColors.primary,
      type: NotificationType.orders,
    ),
    NotificationItem(
      titleKey: 'notif_security_alert_title',
      descriptionKey: 'notif_security_alert_desc',
      time: '5 hours ago',
      icon: Icons.security,
      color: Colors.orange,
      type: NotificationType.system,
    ),
    NotificationItem(
      titleKey: 'notif_welcome_title',
      descriptionKey: 'notif_welcome_desc',
      time: '1 day ago',
      icon: Icons.celebration,
      color: AppColors.primary,
      type: NotificationType.system,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_selectedIndex == 0) return _notifications; // All
    if (_selectedIndex == 1) return _notifications.where((n) => n.type == NotificationType.unread).toList();
    if (_selectedIndex == 2) return _notifications.where((n) => n.type == NotificationType.orders).toList();
    if (_selectedIndex == 3) return _notifications.where((n) => n.type == NotificationType.system).toList();
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredNotifications;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('notifications_title'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildFilterChips(context),
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final notification = filteredList[index];
                      return _buildNotificationCard(context, notification);
                    },
                  ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = [
      context.tr('all'),
      context.tr('unread'),
      context.tr('orders'),
      context.tr('system'),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return InkWell(
            onTap: () => setState(() => _selectedIndex = index),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem notification) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: notification.color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: notification.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(notification.icon, color: notification.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(notification.titleKey),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(notification.descriptionKey),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      notification.time, // Time typically remains as is or formatted
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('no_notifications_found'),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}

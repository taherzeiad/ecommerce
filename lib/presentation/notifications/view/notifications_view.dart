import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';

enum NotificationType { unread, orders, system }

class NotificationItem {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;
  final NotificationType type;

  NotificationItem({
    required this.title,
    required this.description,
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
      title: 'Your Order is On the Way!',
      description: 'Order #SP2024001 has been shipped and will arrive today between 3:00 - 5:00 PM',
      time: '2 minutes ago',
      icon: Icons.local_shipping,
      color: AppColors.primary,
      type: NotificationType.orders,
    ),
    NotificationItem(
      title: 'Payment Successful',
      description: 'Your payment for Order #SP2024001 was successful. Thank you for shopping with us!',
      time: '1 hour ago',
      icon: Icons.payment,
      color: Colors.teal,
      type: NotificationType.unread,
    ),
    NotificationItem(
      title: 'Order Confirmed!',
      description: 'We have received your order #SP2024001. We will notify you when it ships.',
      time: '2 hours ago',
      icon: Icons.check_circle,
      color: AppColors.primary,
      type: NotificationType.orders,
    ),
    NotificationItem(
      title: 'Security Alert',
      description: 'Your account was logged in from a new device. If this wasn\'t you, please reset your password.',
      time: '5 hours ago',
      icon: Icons.security,
      color: Colors.orange,
      type: NotificationType.system,
    ),
    NotificationItem(
      title: 'Welcome to E-Commerce',
      description: 'Welcome to our platform! Start exploring thousands of products and great deals.',
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
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final notification = filteredList[index];
                      return _buildNotificationCard(notification);
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

  Widget _buildNotificationCard(NotificationItem notification) {
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
                  notification.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
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
                      notification.time,
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

  Widget _buildEmptyState() {
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
            'No notifications found', // Should be translated
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

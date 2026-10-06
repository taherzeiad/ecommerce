import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../view_model/notifications_view_model.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsViewModel>().fetchNotifications();
    });
  }

  List<NotificationEntity> _filter(List<NotificationEntity> notifications) {
    return switch (_selectedIndex) {
      1 => notifications.where((n) => !n.isRead).toList(),
      2 => notifications.where((n) => n.type == 'orders').toList(),
      3 => notifications.where((n) => n.type != 'orders').toList(),
      _ => notifications,
    };
  }

  void _open(NotificationEntity notification) {
    context.read<NotificationsViewModel>().markAsRead(notification);
    if (notification.orderId != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.orderTracking,
        arguments: notification.orderId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationsViewModel>();
    final filteredList = _filter(viewModel.notifications);

    Widget list;
    if (viewModel.isLoading && viewModel.notifications.isEmpty) {
      list = const Center(child: CircularProgressIndicator());
    } else if (viewModel.errorMessage != null &&
        viewModel.notifications.isEmpty) {
      list = ErrorStateView(
        messageKey: viewModel.errorMessage!,
        onRetry: viewModel.fetchNotifications,
      );
    } else if (filteredList.isEmpty) {
      list = _buildEmptyState(context);
    } else {
      list = RefreshIndicator(
        onRefresh: viewModel.fetchNotifications,
        child: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: filteredList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) =>
              _buildNotificationCard(context, filteredList[index]),
        ),
      );
    }

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
        actions: [
          if (viewModel.unreadCount > 0)
            IconButton(
              tooltip: context.tr('mark_all_read'),
              onPressed: viewModel.markAllAsRead,
              icon: const Icon(Icons.done_all, color: Colors.white),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildFilterChips(context, viewModel),
          Expanded(child: list),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    NotificationsViewModel viewModel,
  ) {
    final filters = [
      context.tr('all'),
      '${context.tr('unread')}${viewModel.unreadCount > 0 ? ' (${viewModel.unreadCount})' : ''}',
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

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationEntity notification,
  ) {
    final theme = Theme.of(context);
    final isOrder = notification.type == 'orders';
    final color = isOrder
        ? AppColors.primary
        : notification.type == 'promo'
        ? AppColors.warning
        : Colors.teal;
    final icon = isOrder
        ? Icons.local_shipping_outlined
        : notification.type == 'promo'
        ? Icons.local_offer_outlined
        : Icons.notifications_outlined;
    final orderNumber = notification.orderId == null
        ? ''
        : shortOrderNumber(notification.orderId!);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _open(notification),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: BorderDirectional(
              start: BorderSide(color: color, width: 4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(notification.titleKey),
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context
                          .tr(notification.descriptionKey)
                          .replaceAll('{order}', orderNumber),
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: theme.hintColor),
                        const SizedBox(width: 4),
                        Text(
                          '${formatDate(notification.createdAt)}  ${formatTime(notification.createdAt)}',
                          style: TextStyle(color: theme.hintColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
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

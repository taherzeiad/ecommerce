import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../domain/entities/order_entity.dart';

Color orderStatusColor(OrderStatus status) => switch (status) {
  OrderStatus.pending => AppColors.warning,
  OrderStatus.confirmed => AppColors.bannerTeal,
  OrderStatus.shipped => AppColors.primary,
  OrderStatus.delivered => AppColors.success,
  OrderStatus.cancelled => AppColors.error,
};

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        context.tr(status.labelKey),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Pending -> Confirmed -> Shipped -> Delivered, with the reached steps
/// highlighted. A cancelled order shows a single cancelled step.
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.status});

  final OrderStatus status;

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  static const _icons = {
    OrderStatus.pending: Icons.receipt_long_outlined,
    OrderStatus.confirmed: Icons.inventory_2_outlined,
    OrderStatus.shipped: Icons.local_shipping_outlined,
    OrderStatus.delivered: Icons.home_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (status == OrderStatus.cancelled) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.cancel_outlined, color: AppColors.error),
        title: Text(context.tr('order_status_cancelled')),
        subtitle: Text(context.tr('order_cancelled_desc')),
      );
    }
    final reached = _steps.indexOf(status);
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: i <= reached
                          ? AppColors.primary
                          : theme.dividerColor,
                      child: Icon(
                        _icons[_steps[i]],
                        size: 18,
                        color: AppColors.white,
                      ),
                    ),
                    if (i < _steps.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          constraints: const BoxConstraints(minHeight: 20),
                          color: i < reached
                              ? AppColors.primary
                              : theme.dividerColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Text(
                      context.tr(_steps[i].labelKey),
                      style: TextStyle(
                        fontWeight: i == reached
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: i <= reached
                            ? theme.colorScheme.onSurface
                            : theme.hintColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

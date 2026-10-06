import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../domain/entities/order_entity.dart';
import '../../orders/view_model/orders_view_model.dart';
import '../../orders/widgets/order_widgets.dart';

/// Status, items, delivery address and totals of one order.
class OrderTrackingView extends StatefulWidget {
  const OrderTrackingView({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderTrackingView> createState() => _OrderTrackingViewState();
}

class _OrderTrackingViewState extends State<OrderTrackingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() =>
      context.read<OrdersViewModel>().loadOrder(widget.orderId);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrdersViewModel>();
    final order = viewModel.orderById(widget.orderId);

    Widget body;
    if (order == null && viewModel.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (order == null) {
      body = ErrorStateView(
        messageKey: viewModel.errorMessage ?? 'error_order_not_found',
        onRetry: _load,
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: _buildDetails(order),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('order_tracking'),
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: body,
    );
  }

  Widget _buildDetails(OrderEntity order) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${context.tr('order')} #${order.number}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDate(order.createdAt)}  ${formatTime(order.createdAt)}',
                    style: TextStyle(color: theme.hintColor),
                  ),
                ],
              ),
            ),
            OrderStatusChip(status: order.status),
          ],
        ),
        const SizedBox(height: 24),
        _card(child: OrderTimeline(status: order.status)),
        const SizedBox(height: 16),
        _card(
          title: context.tr('order_summary'),
          child: Column(
            children: [
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: item.imageUrl == null
                              ? const Icon(Icons.image, color: AppColors.grey)
                              : Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.image_not_supported,
                                    color: AppColors.grey,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${item.productName} × ${item.quantity}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(formatPrice(item.lineTotal)),
                    ],
                  ),
                ),
              const Divider(height: 24),
              _row(context.tr('sub_total'), formatPrice(order.subtotal)),
              if (order.discount > 0)
                _row(
                  '${context.tr('discount')}${order.couponCode == null ? '' : ' (${order.couponCode})'}',
                  '-${formatPrice(order.discount)}',
                ),
              _row(context.tr('delivery_fees'), formatPrice(order.deliveryFee)),
              _row(context.tr('taxes'), formatPrice(order.tax)),
              _row(
                context.tr('total'),
                formatPrice(order.totalAmount),
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          title: context.tr('delivery_address'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (order.shippingName != null)
                Text(
                  order.shippingName!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (order.shippingAddress != null) Text(order.shippingAddress!),
              if (order.shippingPhone != null) Text(order.shippingPhone!),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          title: context.tr('payment'),
          child: Row(
            children: [
              Icon(
                order.paymentMethod == PaymentMethod.card
                    ? Icons.credit_card
                    : Icons.payments_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                order.paymentMethod == PaymentMethod.card
                    ? '${context.tr('card')} •••• ${order.cardLast4 ?? ''}'
                    : context.tr('cash_on_delivery'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({String? title, required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

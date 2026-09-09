import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../theme/view_model/theme_view_model.dart';
import '../view_model/cart_view_model.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
        ),
        title: const Text(
          AppStrings.shoppingCart,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<ThemeViewModel>().toggleTheme(),
            icon: const VectorGraphic(
              loader: AssetBytesLoader('lib/assets/icons/moon.svg'),
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
            ),
          ),
        ],
      ),
      body: viewModel.items.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.orderSummary,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: viewModel.items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildCartItem(context, viewModel, index);
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildAddMoreItems(context),
                        const SizedBox(height: 32),
                        const Text(
                          AppStrings.discountCoupon,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPromoCodeField(),
                        const SizedBox(height: 32),
                        _buildPriceBreakdown(viewModel),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.checkout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        AppStrings.checkout,
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
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
          const Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppColors.borderLight,
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartViewModel viewModel,
    int index,
  ) {
    final item = viewModel.items[index];
    return Dismissible(
      key: Key(item.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: AppColors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'delete',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        viewModel.removeFromCart(item.product.id);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderExtraLight),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.images.first,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    color: AppColors.dividerExtraLight,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.grey,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.product.category,
                    style: TextStyle(color: AppColors.textLight, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildQtyBtn(Icons.remove, () {
                              viewModel.decrementQuantity(item.product.id);
                            }),
                            const VerticalDivider(width: 1, thickness: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const VerticalDivider(width: 1, thickness: 1),
                            _buildQtyBtn(Icons.add, () {
                              viewModel.incrementQuantity(item.product.id);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildAddMoreItems(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderTeal),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          AppStrings.addMoreItems,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPromoCodeField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: AppStrings.promoCode,
              hintStyle: const TextStyle(color: AppColors.textLight),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            minimumSize: const Size(100, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(AppStrings.apply),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(CartViewModel viewModel) {
    return Column(
      children: [
        _buildPriceRow(
          AppStrings.subTotal,
          '\$${viewModel.subtotal.toStringAsFixed(2)}',
        ),
        _buildPriceRow(
          AppStrings.deliveryFees,
          '\$${viewModel.deliveryFees.toStringAsFixed(2)}',
        ),
        _buildPriceRow(
          AppStrings.taxes,
          '\$${viewModel.taxes.toStringAsFixed(2)}',
          isRed: true,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final boxWidth = constraints.constrainWidth();
            const dashWidth = 5.0;
            const dashHeight = 1.2;
            final dashCount = (boxWidth / (2 * dashWidth)).floor();
            return Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.horizontal,
              children: List.generate(dashCount, (_) {
                return const SizedBox(
                  width: dashWidth,
                  height: dashHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.borderTeal),
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildPriceRow(
          AppStrings.total,
          '\$${viewModel.totalPrice.toStringAsFixed(2)}',
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isRed = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isRed ? AppColors.error : AppColors.textGrey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isRed ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

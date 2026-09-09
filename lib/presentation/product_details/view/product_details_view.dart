import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../domain/entities/product_entity.dart';
import '../../cart/view_model/cart_view_model.dart';
import '../../wishlist/view_model/wishlist_view_model.dart';

class ProductDetailsView extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsView({super.key, required this.product});

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(context),
                _buildProductInfo(context),
              ],
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final wishlistViewModel = context.watch<WishlistViewModel>();
    final isFavorite = wishlistViewModel.isInWishlist(widget.product.id);

    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.cardBackground),
      child: Stack(
        children: [
          Center(
            child: Hero(
              tag: 'product_image_${widget.product.id}',
              child: widget.product.images.isNotEmpty
                  ? Image.network(
                      widget.product.images.first,
                      height: 250,
                      fit: BoxFit.contain,
                    )
                  : const Icon(
                      Icons.laptop_mac,
                      size: 200,
                      color: Colors.black54,
                    ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleIcon(
                    context,
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),
                  _buildCircleIcon(
                    context,
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    () => wishlistViewModel.toggleWishlist(widget.product),
                    iconColor: isFavorite ? Colors.red : AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (widget.product.images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.product.images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index == 0
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(
    BuildContext context,
    IconData icon,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? Colors.black54),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTag(context, Icons.category, widget.product.category),
              const SizedBox(width: 12),
              _buildTag(
                context,
                Icons.star_border,
                '(${widget.product.rating}) Review',
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.reviews),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    AppStrings.addRating,
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                AppStrings.qty,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(width: 16),
              _buildQtyBtn(context, Icons.remove, () {
                if (_quantity > 1) {
                  setState(() => _quantity--);
                }
              }),
              const SizedBox(width: 16),
              Text(
                '$_quantity',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 16),
              _buildQtyBtn(context, Icons.add, () {
                setState(() => _quantity++);
              }),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.fromMonth,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.info_outline, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.product.description,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final cartViewModel = context.read<CartViewModel>();
    final theme = Theme.of(context);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  for (int i = 0; i < _quantity; i++) {
                    cartViewModel.addToCart(widget.product);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added $_quantity to cart')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text(AppStrings.buyNow),
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

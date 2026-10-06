import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_state_view.dart';

import 'package:ecommerce/domain/entities/product_entity.dart';
import 'package:ecommerce/presentation/cart/view_model/cart_view_model.dart';
import 'package:ecommerce/presentation/categories/view_model/categories_view_model.dart';
import 'package:ecommerce/presentation/wishlist/view_model/wishlist_view_model.dart';

import 'package:ecommerce/presentation/theme/view_model/theme_view_model.dart';

/// Products of one category, the flash deals, or everything, with chips to
/// switch between them.
class AllProductsView extends StatelessWidget {
  const AllProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CategoriesViewModel>();
    final title = switch (viewModel.collection) {
      ProductCollection.flashDeals => context.tr('flash_deals'),
      ProductCollection.all => context.tr('all_products'),
      ProductCollection.category => context.tr(
        viewModel.selectedCategory.toLowerCase(),
      ),
    };

    Widget grid;
    if (viewModel.isLoadingProducts && viewModel.categoryProducts.isEmpty) {
      grid = const Center(child: CircularProgressIndicator());
    } else if (viewModel.errorMessage != null &&
        viewModel.categoryProducts.isEmpty) {
      grid = ErrorStateView(
        messageKey: viewModel.errorMessage!,
        onRetry: viewModel.retry,
      );
    } else if (viewModel.categoryProducts.isEmpty) {
      grid = Center(child: Text(context.tr('no_products_here')));
    } else {
      grid = GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: viewModel.categoryProducts.length,
        itemBuilder: (context, index) {
          return _buildProductCard(context, viewModel.categoryProducts[index]);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title.isEmpty ? context.tr('all_products') : title,
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<ThemeViewModel>().toggleTheme(),
            icon: const Icon(Icons.dark_mode_outlined, color: AppColors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildCategoryFilters(context, viewModel),
          const SizedBox(height: 16),
          Expanded(child: grid),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(
    BuildContext context,
    CategoriesViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final chips = <(String, bool, VoidCallback)>[
      (
        context.tr('all'),
        viewModel.collection == ProductCollection.all,
        viewModel.showAllProducts,
      ),
      (
        context.tr('flash_deals_short'),
        viewModel.collection == ProductCollection.flashDeals,
        viewModel.showFlashDeals,
      ),
      for (final category in viewModel.categories)
        (
          context.tr(category.toLowerCase()),
          viewModel.collection == ProductCollection.category &&
              viewModel.selectedCategory == category,
          () => viewModel.fetchProductsByCategory(category),
        ),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final (label, isSelected, onTap) = chips[index];
          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductEntity product) {
    final wishlistViewModel = context.read<WishlistViewModel>();
    final cartViewModel = context.read<CartViewModel>();
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.image, color: AppColors.grey, size: 50),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => wishlistViewModel.toggleWishlist(product),
                    child: Icon(
                      context.watch<WishlistViewModel>().isInWishlist(
                            product.id,
                          )
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          context.watch<WishlistViewModel>().isInWishlist(
                            product.id,
                          )
                          ? AppColors.error
                          : theme.textTheme.bodySmall?.color,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        context.tr(product.category.toLowerCase()),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      formatPrice(product.price),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.productDetails,
                          arguments: product,
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(36),
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(context.tr('view_details')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        final ok = await cartViewModel.addToCart(product);
                        if (context.mounted) {
                          showMessage(
                            context,
                            ok ? 'added_to_cart' : 'error_add_to_cart',
                          );
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.white,
                          size: 20,
                        ),
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
}

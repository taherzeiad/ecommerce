import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../widgets/product_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<CategoryModel> categories = [
      const CategoryModel(id: '1', name: 'Fashion', imagePath: 'assets/icons/fashion.png'),
      const CategoryModel(id: '2', name: 'Electronics', imagePath: 'assets/icons/electronics.png'),
      const CategoryModel(id: '3', name: 'Appliances', imagePath: 'assets/icons/appliances.png'),
      const CategoryModel(id: '4', name: 'Beauty', imagePath: 'assets/icons/beauty.png'),
      const CategoryModel(id: '5', name: 'Furniture', imagePath: 'assets/icons/furniture.png'),
    ];

    final List<ProductModel> products = [
      const ProductModel(
        id: '1',
        name: 'Wireless Headphones',
        category: 'Electronics',
        price: 99.99,
        description: 'High quality wireless headphones',
        images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80'],
        isFlashDeal: true,
      ),
      const ProductModel(
        id: '2',
        name: 'Smart Watch',
        category: 'Electronics',
        price: 149.99,
        description: 'Modern smart watch with health tracking',
        images: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&q=80'],
        isFlashDeal: true,
      ),
      const ProductModel(
        id: '3',
        name: 'Running Shoes',
        category: 'Fashion',
        price: 79.99,
        description: 'Comfortable running shoes',
        images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&q=80'],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildDiscountBanner(),
                const SizedBox(height: 24),
                _buildSectionHeader(AppStrings.categories, () {}),
                const SizedBox(height: 12),
                _buildCategoriesList(categories),
                const SizedBox(height: 24),
                _buildSectionHeader(AppStrings.flashDeals, () {}),
                const SizedBox(height: 12),
                _buildFlashDealsList(products),
                const SizedBox(height: 24),
                _buildSectionHeader(AppStrings.popularProduct, () {}),
                const SizedBox(height: 12),
                _buildPopularProductsGrid(products),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.cardBackground,
          child: Icon(Icons.person, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.helloLetsShop,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.dark_mode_outlined, color: AppColors.textPrimary),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Text(AppStrings.searchHint, style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.tune, color: AppColors.white),
        ),
      ],
    );
  }

  Widget _buildDiscountBanner() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '30% OFF',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'On all electronics',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            AppStrings.seeAll,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesList(List<CategoryModel> categories) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Column(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.category_outlined, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFlashDealsList(List<ProductModel> products) {
    final flashDeals = products.where((p) => p.isFlashDeal).toList();
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: flashDeals.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return ProductCard(product: flashDeals[index]);
        },
      ),
    );
  }

  Widget _buildPopularProductsGrid(List<ProductModel> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}

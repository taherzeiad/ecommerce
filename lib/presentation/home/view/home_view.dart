import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../widgets/product_card.dart';

// Design-system text color used across the home screen (titles, prices).
const Color _kDarkText = Color(0xFF2C3E50);

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> dummyProducts = List.generate(
      4,
      (index) => ProductModel(
        id: index.toString(),
        name: index == 0 ? 'Apple MacBook Air M2' : 'Product $index',
        category: 'Laptop',
        price: 3300.0,
        oldPrice: 3500.0,
        description: 'Description here...',
        images: [],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3FAF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearch(context),
              const SizedBox(height: 24),
              _buildBanner(),
              const SizedBox(height: 24),
              _buildSectionHeader(
                AppStrings.categories,
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.mainWrapper,
                  arguments: 1,
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoryList(context),
              const SizedBox(height: 24),
              _buildSectionHeader(
                AppStrings.flashDeals,
                () => Navigator.pushNamed(context, AppRoutes.allProducts),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: dummyProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: dummyProducts[index],
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.productDetails,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(AppStrings.popularProduct, () {}),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: dummyProducts[index % dummyProducts.length],
                  );
                },
              ),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
                const Text(
                  'Let’s Shop!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _kDarkText,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderIcon(Icons.notifications_none, hasBadge: true),
            const SizedBox(width: 12),
            _buildHeaderIcon(Icons.nightlight_round),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon, {bool hasBadge = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        if (hasBadge)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.search),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Text('Search', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.filterSort),
            child: Icon(Icons.tune, color: AppColors.primary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.95),
            AppColors.primary.withOpacity(0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Get Discount on Shop\nday',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'UP to 50%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: _kDarkText,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Get Now',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(child: _buildWatchGraphic()),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 14,
            child: Center(child: _buildBannerDots()),
          ),
        ],
      ),
    );
  }

  // Decorative fitness-watch graphic (placeholder until a real product image
  // is supplied) built to resemble the banner artwork.
  Widget _buildWatchGraphic() {
    return SizedBox(
      width: 90,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 44,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          Container(
            width: 72,
            height: 92,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '08:30',
                  style: TextStyle(color: Colors.white, fontSize: 8),
                ),
                const SizedBox(height: 2),
                const Icon(
                  Icons.timer_outlined,
                  color: Colors.cyanAccent,
                  size: 10,
                ),
                const Text(
                  '5.2',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'KM',
                  style: TextStyle(color: Colors.cyanAccent, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerDots() {
    Widget dot({bool active = false}) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF00695C) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [dot(), dot(active: true), dot()],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _kDarkText,
          ),
        ),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Text(
                AppStrings.seeAll,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    final categories = ['Phone', 'Fashion', 'Audio', 'Laptop', 'Games'];
    final icons = [
      Icons.phone_android,
      Icons.checkroom,
      Icons.headphones,
      Icons.laptop,
      Icons.videogame_asset,
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.allProducts),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.4),
                  ),
                  child: Icon(icons[index], color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Text(
                  categories[index],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _kDarkText,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

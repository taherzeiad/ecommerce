import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../view_model/home_view_model.dart';
import '../widgets/product_card.dart';
import '../../theme/view_model/theme_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    CustomSearchBar(
                      hintText: 'Search',
                      height: 40,
                      hasShadow: true,
                      hasBorder: false,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.search),
                      onFilterTap: () =>
                          Navigator.pushNamed(context, AppRoutes.filterSort),
                    ),
                    const SizedBox(height: 16),
                    _buildBanner(),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    _buildSectionHeader(
                      AppStrings.flashDeals,
                      () => Navigator.pushNamed(context, AppRoutes.allProducts),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 167,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: viewModel.flashDeals.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final product = viewModel.flashDeals[index];
                          return ProductCard(
                            product: product,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.productDetails,
                              arguments: product,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader(AppStrings.popularProduct, () {}),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: viewModel.popularProducts.length,
                      itemBuilder: (context, index) {
                        final product = viewModel.popularProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.productDetails,
                            arguments: product,
                          ),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.grey,
              child: Icon(Icons.person, color: AppColors.white),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Let’s Shop!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            InkWell(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
              borderRadius: BorderRadius.circular(30),
              child: _buildHeaderIcon(
                'lib/assets/icons/notification.svg',
                hasBadge: true,
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => context.read<ThemeViewModel>().toggleTheme(),
              borderRadius: BorderRadius.circular(30),
              child: _buildHeaderIcon('lib/assets/icons/moon.svg'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(String assetPath, {bool hasBadge = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: _buildAssetIcon(
            assetPath,
            width: 22,
            height: 22,
            color: AppColors.primary,
          ),
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
                border: Border.all(color: AppColors.white, width: 1),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.bannerTeal, AppColors.illustrationBackground],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Discount on Shop\nday',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.white,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'UP to 50%',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 30,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: null, // Placeholder action
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(AppColors.white),
                      foregroundColor: WidgetStatePropertyAll(
                        AppColors.bannerTeal,
                      ),
                      elevation: WidgetStatePropertyAll(0),
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 24),
                      ),
                    ),
                    child: Text(
                      'Get Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            bottom: 10,
            child: _buildWatchGraphic(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Center(child: _buildBannerDots()),
          ),
        ],
      ),
    );
  }

  // Decorative fitness-watch graphic (placeholder until a real product image
  // is supplied) built to resemble the banner artwork.
  Widget _buildWatchGraphic() {
    return Image.asset(AppAssets.bannerImage, width: 110, fit: BoxFit.contain);
  }

  Widget _buildBannerDots() {
    Widget dot({bool active = false}) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 35 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? AppColors.primaryDark : AppColors.white,
        borderRadius: BorderRadius.circular(5),
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
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              const Text(
                AppStrings.seeAll,
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.chevron_right,
                  size: 16.67,
                  color: AppColors.white,
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
    final categoryIcons = [
      'lib/assets/icons/phone.png',
      'lib/assets/icons/clothes.png',
      'lib/assets/icons/sound.png',
      'lib/assets/icons/laptop.png',
      'lib/assets/icons/play.png',
    ];

    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.allProducts),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: _buildAssetIcon(
                    categoryIcons[index],
                    width: 25,
                    height: 35,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  categories[index],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget to display icons from Assets
  Widget _buildAssetIcon(
    String path, {
    double width = 24,
    double height = 24,
    Color? color,
  }) {
    if (path.endsWith('.svg')) {
      return VectorGraphic(
        loader: AssetBytesLoader(path),
        width: width,
        height: height,
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      );
    }
    return Image.asset(
      path,
      width: width,
      height: height,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.image_not_supported_outlined,
          size: width,
          color: color ?? Colors.grey,
        );
      },
    );
  }
}

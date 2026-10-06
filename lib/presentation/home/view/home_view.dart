import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/error_state_view.dart';
import '../view_model/home_view_model.dart';
import '../widgets/product_card.dart';
import '../../categories/view_model/categories_view_model.dart';
import '../../main_wrapper/main_wrapper.dart';
import '../../notifications/view_model/notifications_view_model.dart';
import '../../search/view/filter_sort_view.dart';
import '../../settings/view_model/settings_view_model.dart';
import '../../theme/view_model/theme_view_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../../core/extensions/context_extension.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final theme = Theme.of(context);

    final hasData =
        viewModel.popularProducts.isNotEmpty || viewModel.categories.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: viewModel.isLoading && !hasData
            ? const Center(child: CircularProgressIndicator())
            : viewModel.errorMessage != null && !hasData
            ? ErrorStateView(
                messageKey: viewModel.errorMessage!,
                onRetry: viewModel.fetchHomeData,
              )
            : RefreshIndicator(
                onRefresh: viewModel.fetchHomeData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, viewModel),
                      const SizedBox(height: 16),
                      CustomSearchBar(
                        hintText: context.tr('search'),
                        height: 40,
                        hasShadow: true,
                        hasBorder: false,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.search),
                        onFilterTap: () => openFilterThenSearch(context),
                      ),
                      const SizedBox(height: 16),
                      _buildBanner(context),
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                        context,
                        context.tr('categories'),
                        () {
                          if (!MainWrapper.switchTab(
                            context,
                            MainWrapper.categoriesTab,
                          )) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.mainWrapper,
                              arguments: MainWrapper.categoriesTab,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryList(context),
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                        context,
                        context.tr('flash_deals'),
                        () => Navigator.pushNamed(
                          context,
                          AppRoutes.allProducts,
                          arguments: ProductCollection.flashDeals,
                        ),
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
                            return TweenAnimationBuilder<double>(
                              duration: Duration(
                                milliseconds: 300 + (index * 50),
                              ),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(20 * (1 - value), 0),
                                    child: child,
                                  ),
                                );
                              },
                              child: ProductCard(
                                product: product,
                                // Flash deals also appear in the popular grid;
                                // two Heroes with the same tag break navigation.
                                useHero: false,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.productDetails,
                                  arguments: product,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionHeader(
                        context,
                        context.tr('popular_product'),
                        () => Navigator.pushNamed(
                          context,
                          AppRoutes.allProducts,
                          arguments: ProductCollection.all,
                        ),
                      ),
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
                          return TweenAnimationBuilder<double>(
                            duration: Duration(
                              milliseconds: 350 + (index * 50),
                            ),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.scale(
                                  scale: 0.9 + (0.1 * value),
                                  child: child,
                                ),
                              );
                            },
                            child: ProductCard(
                              product: product,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.productDetails,
                                arguments: product,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeViewModel viewModel) {
    final theme = Theme.of(context);
    final profileViewModel = context.watch<ProfileViewModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              borderRadius: BorderRadius.circular(30),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                foregroundImage: profileViewModel.avatarUrl == null
                    ? null
                    : NetworkImage(profileViewModel.avatarUrl!),
                onForegroundImageError: profileViewModel.avatarUrl == null
                    ? null
                    : (_, _) {},
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.tr('hello')} ${profileViewModel.userName.split(' ').first}',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 16,
                  ),
                ),
                Text(
                  context.tr('lets_shop'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
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
                context,
                'lib/assets/icons/notification.svg',
                // Unread notifications, unless turned off in Settings.
                hasBadge:
                    context.watch<SettingsViewModel>().notificationsEnabled &&
                    context.watch<NotificationsViewModel>().unreadCount > 0,
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => context.read<ThemeViewModel>().toggleTheme(),
              borderRadius: BorderRadius.circular(30),
              child: _buildHeaderIcon(
                context,
                context.watch<ThemeViewModel>().isDarkMode
                    ? 'lib/assets/icons/moon-enable.svg'
                    : 'lib/assets/icons/moon.svg',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(
    BuildContext context,
    String assetPath, {
    bool hasBadge = false,
  }) {
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
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [AppColors.bannerTeal, AppColors.illustrationBackground],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 130, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.tr('banner_title'),
                  maxLines: 2,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('banner_discount'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.allProducts,
                      arguments: ProductCollection.flashDeals,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.bannerTeal,
                      elevation: 0,
                      minimumSize: const Size(100, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Text(
                      context.tr('get_now'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            end: 10,
            top: 10,
            bottom: 10,
            child: _buildWatchGraphic(),
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAll,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Text(
                context.tr('see_all'),
                style: const TextStyle(fontSize: 12, color: AppColors.primary),
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
                child: Icon(
                  Icons.chevron_right,
                  size: 16.67,
                  color: theme.colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<HomeViewModel>();
    final categories = viewModel.categories;

    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.allProducts,
              arguments: categories[index],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: CategoryIcon(
                    category: categories[index],
                    size: 28,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.tr(categories[index].toLowerCase()),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
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

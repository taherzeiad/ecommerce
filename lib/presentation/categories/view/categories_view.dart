import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/extensions/context_extension.dart';
import '../../theme/view_model/theme_view_model.dart';
import '../view_model/categories_view_model.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesViewModel>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<CategoriesViewModel>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('categories'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: VectorGraphic(
              loader: AssetBytesLoader(
                context.watch<ThemeViewModel>().isDarkMode
                    ? 'lib/assets/icons/moon-enable.svg'
                    : 'lib/assets/icons/moon.svg',
              ),
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => context.read<ThemeViewModel>().toggleTheme(),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSearchBar(
                      hintText: context.tr('search'),
                      height: 48,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                      onFilterTap: () =>
                          Navigator.pushNamed(context, AppRoutes.filterSort),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('featured_categories'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeaturedCard(
                      context.tr('latest_smartphones'),
                      context.tr('discover_tech'),
                      'lib/assets/images/phonecolor.png',
                      const Color(0xFF81C784),
                    ),
                    const SizedBox(height: 16),
                    _buildFeaturedCard(
                      context.tr('gaming_laptops'),
                      context.tr('high_performance'),
                      'lib/assets/images/lap.png',
                      const Color(0xFF4DB6AC),
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: viewModel.categories.length,
                      itemBuilder: (context, index) {
                        final category = viewModel.categories[index];
                        final count = viewModel.categoryCounts[category] ?? 0;
                        
                        // Icon mapping
                        String iconPath = 'lib/assets/icons/phone.png';
                        if (category.toLowerCase().contains('phone') || category.contains('هواتف')) {
                          iconPath = 'lib/assets/icons/phone.png';
                        } else if (category.toLowerCase().contains('audio') || category.contains('صوت')) {
                          iconPath = 'lib/assets/icons/sound.png';
                        } else if (category.toLowerCase().contains('game') || category.contains('ألعاب')) {
                          iconPath = 'lib/assets/icons/play.png';
                        } else if (category.toLowerCase().contains('laptop') || category.contains('لابتوب')) {
                          iconPath = 'lib/assets/icons/laptop.png';
                        }

                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: _buildCategoryGridItem(
                            context,
                            category,
                            '+$count Product',
                            iconPath,
                            index == 0,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFeaturedCard(String title, String subtitle, String imagePath, Color bgColor) {
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.contain),
        ],
      ),
    );
  }

  Widget _buildCategoryGridItem(
    BuildContext context,
    String title,
    String count,
    String iconPath,
    bool isNew,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          if (isNew)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF129883),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.tr('new'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Center(
            child: InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.allProducts,
                arguments: title,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    iconPath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count,
                    style: const TextStyle(
                      color: Color(0xFF129883),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

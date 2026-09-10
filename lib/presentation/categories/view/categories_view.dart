import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/extensions/context_extension.dart';
import '../../theme/view_model/theme_view_model.dart';

import 'package:provider/provider.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
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
                    ? 'lib/assets/icons/moonenable.svg'
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSearchBar(
                hintText: context.tr('search'),
                height: 40,
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
              ),
              const SizedBox(height: 16),
              _buildFeaturedCard(
                context.tr('gaming_laptops'),
                context.tr('high_performance'),
                'lib/assets/images/lap.png',
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
                itemCount: 4,
                itemBuilder: (context, index) {
                  final titles = ['smartphones', 'audio', 'gaming', 'laptop'];
                  final counts = [
                    '+250 Product',
                    '+50 Product',
                    '+250 Product',
                    '+550 Product',
                  ];
                  final icons = [
                    'lib/assets/icons/phone.png',
                    'lib/assets/icons/sound.png',
                    'lib/assets/icons/play.png',
                    'lib/assets/icons/laptop.png',
                  ];

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
                      context.tr(titles[index]),
                      counts[index],
                      icons[index],
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

  Widget _buildFeaturedCard(String title, String subtitle, String imagePath) {
    return Container(
      width: 361,
      height: 91,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 0,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(imagePath, width: 47, height: 59),
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
    final theme = Theme.of(context);
    return Container(
      width: 151,
      height: 157,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          if (isNew)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  context.tr('new'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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
                    width: 51,
                    height: 71,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

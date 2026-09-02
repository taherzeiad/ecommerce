import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../widgets/product_card.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearch(),
              const SizedBox(height: 24),
              _buildBanner(),
              const SizedBox(height: 24),
              _buildSectionHeader(AppStrings.categories, () {}),
              const SizedBox(height: 16),
              _buildCategoryList(),
              const SizedBox(height: 24),
              _buildSectionHeader(AppStrings.flashDeals, () {}),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: dummyProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: dummyProducts[index],
                      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetails),
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
                  childAspectRatio: 0.75,
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const Text(
                  'Let’s Shop!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderIcon(Icons.notifications_none),
            const SizedBox(width: 12),
            _buildHeaderIcon(Icons.nights_stay_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(icon, color: Colors.black54, size: 22),
    );
  }

  Widget _buildSearch() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 12),
                Text('Search', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Icon(Icons.tune, color: AppColors.primary, size: 22),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
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
                  'Get Discount on Shop\nday UP to 50%',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(80, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Get Now'),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: Container(
              width: 140,
              decoration: const BoxDecoration(
                // Placeholder for watch image
                color: Colors.transparent,
              ),
              child: const Icon(Icons.watch, size: 100, color: AppColors.primary),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Row(
            children: [
              Text(AppStrings.seeAll, style: TextStyle(fontSize: 14)),
              Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    final categories = ['Phone', 'Fashion', 'Audio', 'Laptop', 'Games'];
    final icons = [Icons.phone_android, Icons.checkroom, Icons.headphones, Icons.laptop, Icons.videogame_asset];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Icon(icons[index], color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(categories[index], style: const TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );
  }
}

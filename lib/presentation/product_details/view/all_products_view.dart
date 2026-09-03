import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';

class AllProductsView extends StatelessWidget {
  const AllProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Products',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.dark_mode_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildCategoryFilters(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Viwe All', style: TextStyle(decoration: TextDecoration.underline)),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildProductCard(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final filters = ['ALL', 'Refrigerator', 'Laptops', 'Mobiles'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isFirst = index == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFirst ? AppColors.primary : const Color(0xFFE7F5F3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              filters[index],
              style: TextStyle(
                color: isFirst ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    final names = ['LG Refrigerator', 'Canon LaserJet Pro', 'LG TwinWash', 'SamsungS23', 'Dell XPS 13', 'LG Refrigerator'];
    final cats = ['Refrigerator', 'Laser Printers', 'Washing LG', 'Mobiles', 'Laptops', 'Refrigerator'];
    final prices = ['550', '200', '600', '100', '300', '550'];
    final images = [
      'https://m.media-amazon.com/images/I/61iVusLwA4L._AC_SL1500_.jpg',
      'https://m.media-amazon.com/images/I/61vYpX1S9XL._AC_SL1500_.jpg',
      'https://m.media-amazon.com/images/I/71TPda7cwUL._AC_SL1500_.jpg', // Placeholder
      'https://m.media-amazon.com/images/I/817WWpa7xIL._AC_SL1500_.jpg',
      'https://m.media-amazon.com/images/I/71TPda7cwUL._AC_SL1500_.jpg',
      'https://m.media-amazon.com/images/I/61iVusLwA4L._AC_SL1500_.jpg',
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F1F1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(child: Padding(padding: const EdgeInsets.all(12), child: Image.network(images[index], fit: BoxFit.contain))),
                const Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border, color: Color(0xFFBDBDBD), size: 20)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(names[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cats[index], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('\$${prices[index]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.productDetails),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(36),
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
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

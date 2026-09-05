import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';

// Design-system text color used across product cards (name + price).
const Color _kDarkText = Color(0xFF2C3E50);

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image, color: Colors.grey, size: 40),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _kDarkText,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: _kDarkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (product.oldPrice != null &&
                    product.oldPrice! > product.price) ...[
                  const SizedBox(width: 8),
                  Text(
                    '\$${product.oldPrice!.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

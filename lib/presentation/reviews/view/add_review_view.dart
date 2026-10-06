import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../domain/entities/product_entity.dart';
import '../view_model/reviews_view_model.dart';

/// Star rating + comment for one product. Pops `true` once it is saved.
class AddReviewView extends StatelessWidget {
  const AddReviewView({super.key, required this.product});

  final ProductEntity product;

  Future<void> _submit(BuildContext context) async {
    final ok = await context.read<AddReviewViewModel>().submit(product.id);
    if (ok && context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddReviewViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('reviews_rating'),
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: product.images.isEmpty
                        ? const Icon(Icons.image, size: 48, color: AppColors.grey)
                        : Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr(product.category.toLowerCase()),
                        style: TextStyle(color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                context.tr('overall_rating'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(
                  tooltip: '$star',
                  iconSize: 40,
                  onPressed: () => viewModel.setRating(star),
                  icon: Icon(
                    star <= viewModel.rating ? Icons.star : Icons.star_border,
                    color: star <= viewModel.rating
                        ? Colors.amber
                        : AppColors.borderTeal,
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            Text(
              context.tr('your_feedback'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: viewModel.commentController,
              maxLines: 6,
              maxLength: AddReviewViewModel.maxLength,
              decoration: InputDecoration(
                hintText: context.tr('share_thoughts'),
                hintStyle: TextStyle(color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            if (viewModel.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                context.tr(viewModel.errorMessage!),
                style: const TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: viewModel.isSubmitting ? null : () => _submit(context),
              child: viewModel.isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(context.tr('submit')),
            ),
          ],
        ),
      ),
    );
  }
}

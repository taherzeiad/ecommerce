import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/review_entity.dart';
import '../view_model/reviews_view_model.dart';

class ReviewsView extends StatelessWidget {
  const ReviewsView({super.key, required this.product});

  final ProductEntity product;

  Future<void> _addReview(BuildContext context) async {
    final added = await Navigator.pushNamed(
      context,
      AppRoutes.addReview,
      arguments: product,
    );
    if (added == true && context.mounted) {
      context.read<ReviewsViewModel>().fetchReviews(product.id);
      showMessage(context, 'review_thanks');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReviewsViewModel>();

    Widget body;
    if (viewModel.isLoading && viewModel.reviews.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (viewModel.errorMessage != null && viewModel.reviews.isEmpty) {
      body = ErrorStateView(
        messageKey: viewModel.errorMessage!,
        onRetry: () => viewModel.fetchReviews(product.id),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: () => viewModel.fetchReviews(product.id),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildRatingSummary(context, viewModel),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _addReview(context),
              icon: const Icon(Icons.rate_review_outlined),
              label: Text(context.tr('add_rating')),
            ),
            const SizedBox(height: 32),
            Text(
              context.tr('user_review'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (viewModel.reviews.isEmpty)
              Text(context.tr('no_reviews_yet'))
            else
              for (final review in viewModel.reviews) ...[
                _buildUserReviewItem(context, review),
                const SizedBox(height: 16),
              ],
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('reviews_rating'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: body,
    );
  }

  Widget _buildRatingSummary(BuildContext context, ReviewsViewModel viewModel) {
    final theme = Theme.of(context);
    final breakdown = viewModel.ratingBreakdown;
    final total = viewModel.reviews.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    viewModel.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                  StarRow(rating: viewModel.averageRating, size: 16),
                  const SizedBox(height: 4),
                  Text(
                    '$total ${context.tr('reviews')}',
                    style: TextStyle(color: theme.hintColor, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    for (final entry in breakdown.entries)
                      Row(
                        children: [
                          Text('${entry.key}'),
                          const SizedBox(width: 6),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: total == 0 ? 0 : entry.value / total,
                                minHeight: 6,
                                color: AppColors.primary,
                                backgroundColor: theme.dividerColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserReviewItem(BuildContext context, ReviewEntity review) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  review.userName.isEmpty ? '?' : review.userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatDate(review.createdAt),
                      style: TextStyle(color: theme.hintColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              StarRow(rating: review.rating, size: 16),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Five stars filled up to [rating] (rounded to the nearest half).
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.rating, this.size = 20});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final halves = (rating * 2).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final icon = halves >= (i + 1) * 2
            ? Icons.star
            : halves == i * 2 + 1
            ? Icons.star_half
            : Icons.star_border;
        return Icon(icon, size: size, color: Colors.amber);
      }),
    );
  }
}

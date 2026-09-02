import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/onboarding_item_model.dart';

/// Renders a single onboarding page: illustration card + title + description.
/// Pure presentational widget — takes data in, draws it, nothing else.
class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({super.key, required this.item});

  final OnboardingItemModel item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(item.imagePath, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

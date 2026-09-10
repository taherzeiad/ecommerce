import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';

class NoResultsWidget extends StatelessWidget {
  final String query;
  final VoidCallback onTryAgain;

  const NoResultsWidget({
    super.key,
    required this.query,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_outlined,
            size: 120,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('no_results_found'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${context.tr('no_results_desc')} "$query"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(onPressed: onTryAgain, child: Text(context.tr('try_again'))),
        ],
      ),
    );
  }
}

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.wifi_off_outlined,
                size: 140,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
              Positioned(
                right: 30,
                top: 30,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('no_internet_connection'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('check_connection_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 48),
          // We'll use a transparent box if it's just the text in design,
          // but the design shows a button in similar screens.
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

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
            color: Color(0xFF8A8FA3),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1B29),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sorry, there are not results for "$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF8A8FA3),
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: onTryAgain,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetWidget({
    super.key,
    required this.onRetry,
  });

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
                color: AppColors.primary.withOpacity(0.8),
              ),
              Positioned(
                right: 30,
                top: 30,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
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
          const Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1B29),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Please check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF8A8FA3),
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

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Placeholder landing screen — replace with the real Home/shop screen.
/// Kept here so the Splash -> Onboarding -> Home flow is runnable end to end.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 56),
            const SizedBox(height: 16),
            Text(
              'Onboarding complete!\nBuild your Home screen here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

class VerifyIllustration extends StatelessWidget {
  const VerifyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VectorGraphic(
          loader: const AssetBytesLoader(AppAssets.verify),
          width: 80,
          height: 80,
          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'XXXX',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
        ),
      ],
    );
  }
}

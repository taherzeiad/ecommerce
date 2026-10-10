import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

class LockIllustration extends StatelessWidget {
  const LockIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return VectorGraphic(
      loader: const AssetBytesLoader(AppAssets.lock),
      width: 120,
      height: 120,
      colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
    );
  }
}

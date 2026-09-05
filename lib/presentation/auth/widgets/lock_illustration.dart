import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_assets.dart';

class LockIllustration extends StatelessWidget {
  const LockIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const VectorGraphic(
      loader: AssetBytesLoader(AppAssets.lock),
      width: 120,
      height: 120,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';

class SocialLoginBar extends StatelessWidget {
  const SocialLoginBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.authHint, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.tr('or_sign_in_with'),
                style: const TextStyle(
                  color: AppColors.authTextBody,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.authHint, thickness: 1)),
          ],
        ),
        const SizedBox(height: 32),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(iconPath: AppAssets.facebook),
            SizedBox(width: 20),
            _SocialButton(iconPath: AppAssets.pinterest),
            SizedBox(width: 20),
            _SocialButton(iconPath: AppAssets.linkedin),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String iconPath;

  const _SocialButton({required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: VectorGraphic(
          loader: AssetBytesLoader(iconPath),
          width: 39,
          height: 39,
        ),
      ),
    );
  }
}

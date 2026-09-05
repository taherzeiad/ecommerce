import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';

class SocialLoginBar extends StatelessWidget {
  const SocialLoginBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: Color(0xFFCBD5E0),
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.orSignInWith,
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Expanded(
              child: Divider(
                color: Color(0xFFCBD5E0),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(iconPath: AppAssets.facebook, onPressed: () {}),
            const SizedBox(width: 20),
            _SocialButton(iconPath: AppAssets.pinterest, onPressed: () {}),
            const SizedBox(width: 20),
            _SocialButton(iconPath: AppAssets.linkedin, onPressed: () {}),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;

  const _SocialButton({required this.iconPath, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
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

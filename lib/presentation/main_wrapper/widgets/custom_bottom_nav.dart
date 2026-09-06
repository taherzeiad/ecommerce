import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            assetPath: 'lib/assets/icons/home.svg',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            assetPath: 'lib/assets/icons/cat.svg',
            activeAssetPath: 'lib/assets/icons/fillcat.svg',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            assetPath: 'lib/assets/icons/basket.svg',
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            assetPath: 'lib/assets/icons/like.svg',
            activeAssetPath: 'lib/assets/icons/filllove.svg',
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavItem(
            // Keeping profile icon as it is or using a default if no SVG provided
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            isActive: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String? assetPath;
  final String? activeAssetPath; // مسار الأيقونة الممتلئة (Solid)
  final IconData? icon;
  final IconData? activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    this.assetPath,
    this.activeAssetPath,
    this.icon,
    this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // اختيار المسار الصحيح بناءً على حالة التحديد
    final String? currentAsset = isActive
        ? (activeAssetPath ?? assetPath)
        : assetPath;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentAsset != null)
            VectorGraphic(
              loader: AssetBytesLoader(currentAsset),
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(
                isActive ? AppColors.primary : Colors.grey.shade400,
                BlendMode.srcIn,
              ),
            )
          else
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : Colors.grey.shade400,
              size: 28,
            ),
          if (isActive) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';
import '../constants/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final bool showFilter;
  final double height;
  final bool hasShadow;
  final bool hasBorder;
  final bool readOnly;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    this.onTap,
    this.onFilterTap,
    this.showFilter = true,
    this.height = 52,
    this.hasShadow = false,
    this.hasBorder = true,
    this.readOnly = true,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(height / 2),
        border: hasBorder ? Border.all(color: AppColors.dividerExtraLight) : null,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(4, 0),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: readOnly
                ? InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(height / 2),
                      bottomLeft: Radius.circular(height / 2),
                      topRight: showFilter ? Radius.zero : Radius.circular(height / 2),
                      bottomRight: showFilter ? Radius.zero : Radius.circular(height / 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const VectorGraphic(
                            loader: AssetBytesLoader('lib/assets/icons/search.svg'),
                            colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            hintText,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : TextField(
                    controller: controller,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12),
                        child: VectorGraphic(
                          loader: AssetBytesLoader('lib/assets/icons/search.svg'),
                          colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                          width: 24,
                          height: 24,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
          ),
          if (showFilter) ...[
            const VerticalDivider(
              width: 1,
              indent: 12,
              endIndent: 12,
              color: AppColors.dividerExtraLight,
            ),
            InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(height / 2),
                bottomRight: Radius.circular(height / 2),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: VectorGraphic(
                  loader: AssetBytesLoader('lib/assets/icons/filter.svg'),
                  colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                  width: 22,
                  height: 22,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

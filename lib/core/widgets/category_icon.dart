import 'package:flutter/material.dart';

/// Picks an icon from the category *name*, in English or Arabic, so it stays
/// right whatever order or language the categories come back in.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 28,
    this.color,
  });

  final String category;
  final double size;
  final Color? color;

  static const _assets = <String, List<String>>{
    'lib/assets/icons/phone.png': ['phone', 'mobile', 'هاتف', 'هواتف', 'جوال'],
    'lib/assets/icons/laptop.png': [
      'laptop',
      'computer',
      'pc',
      'لابتوب',
      'كمبيوتر',
      'حاسوب',
      'حواسيب',
    ],
    'lib/assets/icons/sound.png': [
      'audio',
      'sound',
      'headphone',
      'speaker',
      'electronic',
      'سماع',
      'صوت',
      'إلكترونيات',
      'الكترونيات',
    ],
    'lib/assets/icons/play.png': ['game', 'gaming', 'play', 'ألعاب', 'العاب'],
    'lib/assets/icons/clothes.png': [
      'cloth',
      'fashion',
      'wear',
      'ملابس',
      'أزياء',
      'ازياء',
    ],
  };

  /// Asset path for [category], or `null` when no picture fits.
  static String? assetFor(String category) {
    final name = category.toLowerCase();
    for (final entry in _assets.entries) {
      if (entry.value.any(name.contains)) return entry.key;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final asset = assetFor(category);
    if (asset != null) {
      return Image.asset(asset, width: size, height: size, color: color);
    }
    final name = category.toLowerCase();
    final icon = name.contains('watch') || name.contains('ساع')
        ? Icons.watch_outlined
        : Icons.category_outlined;
    return Icon(icon, size: size, color: color);
  }
}

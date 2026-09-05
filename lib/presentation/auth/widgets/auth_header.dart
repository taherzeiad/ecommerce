import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool titleOnTop;
  final bool centerTitle;
  final Widget? bottomWidget;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleOnTop = false,
    this.centerTitle = false,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      title,
      textAlign: centerTitle ? TextAlign.center : TextAlign.start,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
    );

    final subtitleWidget = Text(
      subtitle,
      textAlign: centerTitle ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background circles
        Positioned(
          top: -40,
          left: -30,
          child: _Circle(size: 150, opacity: 0.15),
        ),
        Positioned(
          top: 60,
          right: 20,
          child: _Circle(size: 40, opacity: 0.1),
        ),
        Positioned(
          bottom: -20,
          left: 100,
          child: _Circle(size: 100, opacity: 0.1),
        ),
        Positioned(
          top: 150,
          right: -50,
          child: _Circle(size: 180, opacity: 0.05),
        ),

        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 40, 24, bottomWidget != null ? 60 : 40),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: centerTitle
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  if (titleOnTop) ...[
                    titleWidget,
                    const SizedBox(height: 8),
                    subtitleWidget,
                  ] else ...[
                    subtitleWidget,
                    const SizedBox(height: 16),
                    titleWidget,
                  ],
                ],
              ),
            ),
          ),
        ),
        if (bottomWidget != null)
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
            child: Center(child: bottomWidget!),
          ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;

  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';

class SocialLoginBar extends StatelessWidget {
  const SocialLoginBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.orSignInWith,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              icon: Icons.facebook,
              color: const Color(0xFF3B5998),
              onPressed: () {},
            ),
            const SizedBox(width: 20),
            _SocialButton(
              icon: Icons.pin_drop, // Using pin_drop as a placeholder for Pinterest
              color: const Color(0xFFBD081C),
              onPressed: () {},
            ),
            const SizedBox(width: 20),
            _SocialButton(
              icon: Icons.link, // Placeholder for LinkedIn
              color: const Color(0xFF0077B5),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

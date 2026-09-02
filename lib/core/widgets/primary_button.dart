import 'package:flutter/material.dart';

/// Shared CTA button used by every screen ("Next" / "Start" / etc.)
/// so button styling only lives in one place.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}

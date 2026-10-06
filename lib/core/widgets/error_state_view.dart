import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../extensions/context_extension.dart';

/// Full-screen message shown when data could not be loaded, with a retry
/// button. [messageKey] is a translation key such as `error_network`.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.messageKey,
    required this.onRetry,
  });

  final String messageKey;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNetwork = messageKey == 'error_network';
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNetwork ? Icons.wifi_off_outlined : Icons.error_outline,
              size: 96,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 24),
            Text(
              context.tr(
                isNetwork ? 'no_internet_connection' : 'something_went_wrong',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr(messageKey),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.tr('try_again')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a translated message in a SnackBar.
void showMessage(BuildContext context, String key) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(context.tr(key))));
}

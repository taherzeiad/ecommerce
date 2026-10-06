import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../theme/view_model/theme_view_model.dart';
import '../view_model/profile_view_model.dart';
import '../widgets/profile_widgets.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileViewModel = context.watch<ProfileViewModel>();
    final userName = profileViewModel.userName.isNotEmpty
        ? profileViewModel.userName
        : context.tr('guest_user');
    final userEmail = profileViewModel.userEmail;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('profile'),
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<ThemeViewModel>().toggleTheme(),
            icon: const Icon(Icons.dark_mode_outlined, color: AppColors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            ProfileAvatar(
              imageUrl: profileViewModel.avatarUrl,
              name: profileViewModel.userName,
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (userEmail.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                userEmail,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 32),
            ProfileListItem(
              icon: Icons.person_outline,
              title: context.tr('edit_profile'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            ),
            ProfileListItem(
              icon: Icons.favorite_border,
              title: context.tr('wishlist'),
              // Back to the main screen (not a second copy of it), on the
              // wishlist tab.
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.mainWrapper,
                (route) => false,
                arguments: 3,
              ),
            ),
            ProfileListItem(
              icon: Icons.assignment_outlined,
              title: context.tr('my_orders'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
            ),
            ProfileListItem(
              icon: Icons.location_on_outlined,
              title: context.tr('shipping_address'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.addresses),
            ),
            ProfileListItem(
              icon: Icons.notifications_none,
              title: context.tr('notification'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
            ),
            ProfileListItem(
              icon: Icons.payment_outlined,
              title: context.tr('payment_methods'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.paymentMethods),
            ),
            ProfileListItem(
              icon: Icons.settings_outlined,
              title: context.tr('settings'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
            const SizedBox(height: 16),
            ProfileListItem(
              icon: Icons.logout_outlined,
              title: context.tr('logout'),
              iconColor: AppColors.error,
              onTap: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.power_settings_new,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('are_you_sure_logout'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      side: BorderSide(color: theme.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(context.tr('cancel')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // This is the dialog's context, which is gone once the
                      // dialog closes, so keep the navigator itself.
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      await sl<AuthRepository>().logout();
                      navigator.pushNamedAndRemoveUntil(
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(context.tr('logout')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

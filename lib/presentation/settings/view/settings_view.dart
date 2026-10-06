import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecommerce/core/constants/app_colors.dart';
import 'package:ecommerce/core/di/service_locator.dart';
import 'package:ecommerce/core/routes/app_routes.dart';
import 'package:ecommerce/data/repositories/auth_repository.dart';
import 'package:ecommerce/core/extensions/context_extension.dart';
import 'package:ecommerce/presentation/theme/view_model/theme_view_model.dart';
import 'package:ecommerce/presentation/theme/view_model/locale_view_model.dart';
import 'package:ecommerce/presentation/settings/view_model/settings_view_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeViewModel = context.watch<ThemeViewModel>();
    final settings = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('settings'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(theme, context.tr('account_setting')),
            const SizedBox(height: 16),
            _buildSettingsItem(
              theme,
              icon: Icons.person_outlined,
              title: context.tr('edit_profile'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            ),
            _buildSettingsItem(
              theme,
              icon: Icons.lock_outlined,
              title: context.tr('change_password'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
            ),
            _buildSettingsItem(
              theme,
              icon: Icons.location_on_outlined,
              title: context.tr('shipping_address'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.addresses),
            ),
            _buildSettingsItem(
              theme,
              icon: Icons.payment_outlined,
              title: context.tr('payment_methods'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.paymentMethods),
            ),
            _buildSettingsItem(
              theme,
              icon: Icons.language,
              title: context.tr('language'),
              subtitle: context.watch<LocaleViewModel>().locale.languageCode == 'en' ? 'English' : 'العربية',
              onTap: () => _showLanguagePicker(context),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(theme, context.tr('preferences')),
            const SizedBox(height: 16),
            _buildSettingsToggle(
              theme,
              icon: Icons.dark_mode_outlined,
              title: context.tr('dark_mode'),
              value: themeViewModel.isDarkMode,
              onChanged: (val) => themeViewModel.toggleTheme(),
            ),
            _buildSettingsToggle(
              theme,
              icon: Icons.notifications_none,
              title: context.tr('notification'),
              value: settings.notificationsEnabled,
              onChanged: settings.setNotificationsEnabled,
            ),
            if (settings.notificationsEnabled) ...[
              _buildSettingsToggle(
                theme,
                icon: Icons.volume_up_outlined,
                title: context.tr('notification_sound'),
                value: settings.soundEnabled,
                onChanged: settings.setSoundEnabled,
              ),
              _buildSettingsToggle(
                theme,
                icon: Icons.vibration,
                title: context.tr('vibration'),
                value: settings.vibrationEnabled,
                onChanged: settings.setVibrationEnabled,
              ),
            ],
            const SizedBox(height: 32),
            _buildSectionHeader(theme, context.tr('support_other')),
            const SizedBox(height: 16),
            _buildSettingsItem(
              theme,
              icon: Icons.privacy_tip_outlined,
              title: context.tr('privacy'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
            ),
            _buildSettingsItem(
              theme,
              icon: Icons.help_outlined,
              title: context.tr('help_center'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
            ),
            _buildSettingsItem(
              theme,
              icon: Icons.description_outlined,
              title: context.tr('terms_condition'),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.termsConditions),
            ),
            _buildSettingsItem(
              theme,
              icon: Icons.info_outlined,
              title: context.tr('about_us'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.aboutUs),
            ),
            const SizedBox(height: 32),
            _buildSettingsItem(
              theme,
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

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSettingsItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      // ListTile draws its ripple on the nearest Material; without this one
      // the coloured Container above would hide it.
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: subtitle != null
              ? Text(subtitle, style: const TextStyle(color: AppColors.primary))
              : null,
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsToggle(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final localeViewModel = context.read<LocaleViewModel>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr('select_language'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildLanguageItem(
                'English',
                localeViewModel.locale.languageCode == 'en',
                () => localeViewModel.setLocale(const Locale('en')),
              ),
              _buildLanguageItem(
                'العربية',
                localeViewModel.locale.languageCode == 'ar',
                () => localeViewModel.setLocale(const Locale('ar')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageItem(
      String language, bool isSelected, VoidCallback onTap) {
    return ListTile(
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
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

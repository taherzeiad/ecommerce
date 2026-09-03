import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/profile_widgets.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.dark_mode_outlined, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            const ProfileAvatar(),
            const SizedBox(height: 16),
            const Text(
              'Ramiz Man',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B1B29),
              ),
            ),
            const SizedBox(height: 32),
            ProfileListItem(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
            ),
            ProfileListItem(
              icon: Icons.favorite_border,
              title: 'Wishlist',
              onTap: () => Navigator.pushNamed(context, AppRoutes.mainWrapper), // Or direct if handled
            ),
            ProfileListItem(
              icon: Icons.assignment_outlined,
              title: 'My Order',
              onTap: () {},
            ),
            ProfileListItem(
              icon: Icons.notifications_none,
              title: 'Notification',
              onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
            ),
            ProfileListItem(
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              onTap: () {},
            ),
            ProfileListItem(
              icon: Icons.settings_outlined,
              title: 'Setting',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
            const SizedBox(height: 16),
            ProfileListItem(
              icon: Icons.logout_outlined,
              title: 'Log Out',
              iconColor: const Color(0xFFE57373),
              onTap: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.power_settings_new,
              color: Color(0xFFE57373),
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'Are You Sure to wont to Log out ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Log out'),
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

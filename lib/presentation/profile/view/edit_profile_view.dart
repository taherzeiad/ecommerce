import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/auth_repository.dart';
import '../widgets/profile_widgets.dart';

import '../view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final profileViewModel = context.read<ProfileViewModel>();
    _nameController = TextEditingController(text: profileViewModel.userName);
    _emailController = TextEditingController(text: profileViewModel.userEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('edit_profile'),
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (profileViewModel.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Colors.white)))
          else
            TextButton(
              onPressed: () async {
                await profileViewModel.updateName(_nameController.text);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(
                context.tr('save'),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: ProfileAvatar()),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: Text(context.tr('change_photo')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.borderTeal),
                  backgroundColor: AppColors.primaryLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildFieldLabel(context.tr('full_name')),
            _buildTextField(controller: _nameController),
            const SizedBox(height: 16),
            _buildFieldLabel(context.tr('email')),
            _buildTextField(controller: _emailController, enabled: false),
            const SizedBox(height: 16),
            _buildFieldLabel(context.tr('phone_number')),
            _buildTextField(initialValue: '0593476532'),
            const SizedBox(height: 24),
            _buildLinkCard(
              icon: Icons.person_outline,
              title: context.tr('change_password'),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.changePassword),
            ),
            const SizedBox(height: 16),
            _buildLinkCard(
              icon: Icons.person_outline,
              title: context.tr('saved_address'),
              onTap: () {},
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: profileViewModel.isLoading
                    ? null
                    : () async {
                        await profileViewModel.updateName(_nameController.text);
                        if (context.mounted) Navigator.pop(context);
                      },
                child: profileViewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(context.tr('save_changes')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({TextEditingController? controller, String? initialValue, String? hintText, bool enabled = true}) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textLight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildLinkCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderExtraLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

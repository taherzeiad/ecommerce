import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/widgets/error_state_view.dart';
import '../view_model/profile_view_model.dart';
import '../widgets/profile_widgets.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key, this.imagePicker});

  /// Injectable for tests.
  final ImagePicker? imagePicker;

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profileViewModel = context.read<ProfileViewModel>();
    _nameController = TextEditingController(text: profileViewModel.userName);
    _emailController = TextEditingController(text: profileViewModel.userEmail);
    _phoneController = TextEditingController(text: profileViewModel.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final viewModel = context.read<ProfileViewModel>();
    final ok = await viewModel.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
    );
    if (!mounted) return;
    if (ok) {
      showMessage(context, 'profile_saved');
      Navigator.pop(context);
    } else {
      showMessage(context, viewModel.errorMessage ?? 'error_unexpected');
    }
  }

  Future<void> _changePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.tr('gallery')),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.tr('camera')),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final picker = widget.imagePicker ?? ImagePicker();
    final XFile? file;
    try {
      file = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
    } catch (e) {
      if (mounted) showMessage(context, 'error_photo_access');
      return;
    }
    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    final name = file.name;
    final ext = name.contains('.')
        ? name.split('.').last
        : (file.mimeType?.split('/').last ?? 'jpg');
    if (!mounted) return;
    final viewModel = context.read<ProfileViewModel>();
    final ok = await viewModel.uploadAvatar(bytes, ext);
    if (mounted && !ok) {
      showMessage(context, viewModel.errorMessage ?? 'error_unexpected');
    }
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ProfileAvatar(
                imageUrl: profileViewModel.avatarUrl,
                name: profileViewModel.userName,
                isLoading: profileViewModel.isUploadingAvatar,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: profileViewModel.isUploadingAvatar ? null : _changePhoto,
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: Text(context.tr('change_photo')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.borderTeal),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
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
            _buildTextField(
              controller: _phoneController,
              hintText: '+970 59 000 0000',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            _buildLinkCard(
              icon: Icons.lock_outline,
              title: context.tr('change_password'),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.changePassword),
            ),
            const SizedBox(height: 16),
            _buildLinkCard(
              icon: Icons.location_on_outlined,
              title: context.tr('saved_address'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.addresses),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: profileViewModel.isLoading ? null : _save,
                child: profileViewModel.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: theme.dividerColor),
    );
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: theme.hintColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border,
        enabledBorder: border,
        disabledBorder: border,
      ),
    );
  }

  Widget _buildLinkCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: theme.hintColor),
            ],
          ),
        ),
      ),
    );
  }
}

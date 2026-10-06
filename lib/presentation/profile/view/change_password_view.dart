import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/widgets/error_state_view.dart';
import '../view_model/change_password_view_model.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  Future<void> _submit(BuildContext context) async {
    final ok = await context.read<ChangePasswordViewModel>().submit();
    if (ok && context.mounted) {
      showMessage(context, 'password_changed');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChangePasswordViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('change_password'),
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: VectorGraphic(
                loader: AssetBytesLoader(AppAssets.changePassword),
                height: 150,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                context.tr('change_password_desc'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildFieldLabel(context, context.tr('current_password')),
            _buildPasswordField(
              context,
              viewModel.currentController,
              context.tr('enter_password'),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel(context, context.tr('new_password')),
            _buildPasswordField(
              context,
              viewModel.newController,
              context.tr('password'),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel(context, context.tr('confirm_password')),
            _buildPasswordField(
              context,
              viewModel.confirmController,
              context.tr('confirm_password'),
            ),
            if (viewModel.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                context.tr(viewModel.errorMessage!),
                style: const TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : () => _submit(context),
              child: viewModel.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(context.tr('save_changes')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
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

  Widget _buildPasswordField(
    BuildContext context,
    TextEditingController controller,
    String hintText,
  ) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: theme.dividerColor),
    );
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: theme.hintColor),
        prefixIcon: Icon(Icons.lock_outline, color: theme.hintColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border,
        enabledBorder: border,
      ),
    );
  }
}

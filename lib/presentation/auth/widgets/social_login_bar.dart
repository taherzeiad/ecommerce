import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../data/repositories/auth_repository.dart';
import '../social/social_login_view_model.dart';

/// "Or sign in with" + Google / Facebook buttons. Opens the main screen
/// once the provider sends the user back signed in.
class SocialLoginBar extends StatelessWidget {
  const SocialLoginBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SocialLoginViewModel(sl<AuthRepository>()),
      child: const _SocialLoginContent(),
    );
  }
}

class _SocialLoginContent extends StatefulWidget {
  const _SocialLoginContent();

  @override
  State<_SocialLoginContent> createState() => _SocialLoginContentState();
}

class _SocialLoginContentState extends State<_SocialLoginContent> {
  late final SocialLoginViewModel _viewModel;
  String? _shownError;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<SocialLoginViewModel>();
    _viewModel.addListener(_onChange);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (!mounted) return;
    if (_viewModel.signedIn) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.mainWrapper,
        (route) => false,
      );
    } else if (_viewModel.errorMessage != null &&
        _viewModel.errorMessage != _shownError) {
      _shownError = _viewModel.errorMessage;
      showMessage(context, _viewModel.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SocialLoginViewModel>();
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.authHint, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.tr('or_sign_in_with'),
                style: const TextStyle(
                  color: AppColors.authTextBody,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.authHint, thickness: 1)),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              tooltip: 'Google',
              isBusy: viewModel.busyProvider == SocialProvider.google,
              onTap: () => viewModel.signIn(SocialProvider.google),
              child: Image.asset(
                'lib/assets/icons/google.png',
                width: 39,
                height: 39,
              ),
            ),
            const SizedBox(width: 20),
            _SocialButton(
              tooltip: 'Facebook',
              isBusy: viewModel.busyProvider == SocialProvider.facebook,
              onTap: () => viewModel.signIn(SocialProvider.facebook),
              child: const VectorGraphic(
                loader: AssetBytesLoader(AppAssets.facebook),
                width: 39,
                height: 39,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.tooltip,
    required this.isBusy,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final bool isBusy;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: isBusy
              ? const SizedBox(
                  width: 39,
                  height: 39,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : child,
        ),
      ),
    );
  }
}

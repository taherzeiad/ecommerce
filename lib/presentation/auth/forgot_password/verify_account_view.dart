import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/widgets/error_state_view.dart';
import '../widgets/auth_header.dart';
import '../widgets/verify_illustration.dart';
import 'auth_viewmodel.dart';

class VerifyAccountView extends StatelessWidget {
  const VerifyAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel =
        ModalRoute.of(context)!.settings.arguments as ForgotPasswordViewModel;

    return ChangeNotifierProvider.value(
      value: viewModel,
      child: const _VerifyAccountContent(),
    );
  }
}

class _VerifyAccountContent extends StatelessWidget {
  const _VerifyAccountContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForgotPasswordViewModel>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          AuthHeader(
            title: context.tr('verify_account_title'),
            subtitle: '',
            centerTitle: true,
            bottomWidget: const VerifyIllustration(),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  // Scrolls on short screens so the keypad always fits.
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          Text(
                            context.tr('verify_account_desc'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            viewModel.emailController.text,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              textDirection: TextDirection.ltr,
                              children: List.generate(
                                  ForgotPasswordViewModel.otpLength, (index) {
                                String char = "";
                                if (viewModel.otp.length > index) {
                                  char = viewModel.otp[index];
                                }
                                return Expanded(
                                  child: Container(
                                  height: 60,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    border: Border.all(
                                      color: char.isEmpty
                                          ? AppColors.authBorder
                                          : AppColors.primary,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    char.isEmpty ? '—' : char,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: char.isEmpty
                                          ? AppColors.authHint
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          if (viewModel.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                              child: Text(
                                context.tr(viewModel.errorMessage!),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.tr('resend_code'),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: viewModel.canResend
                                    ? () async {
                                        final sent = await viewModel.resendCode();
                                        if (sent && context.mounted) {
                                          showMessage(context, 'code_resent');
                                        }
                                      }
                                    : null,
                                child: Text(
                                  context.tr('resend'),
                                  style: TextStyle(
                                    color: viewModel.canResend
                                        ? AppColors.authLink
                                        : AppColors.authHint,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (viewModel.resendSecondsLeft > 0)
                            Text(
                              context.tr('resend_in').replaceAll(
                                '{time}',
                                '0:${viewModel.resendSecondsLeft.toString().padLeft(2, '0')}',
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  _NumericKeypad(
                    onTap: (val) async {
                      const length = ForgotPasswordViewModel.otpLength;
                      if (viewModel.otp.length < length && !viewModel.isLoading) {
                        viewModel.appendOtp(val);
                        if (viewModel.otp.length == length) {
                          final success = await viewModel.verifyOtp();
                          if (success && context.mounted) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.resetPassword,
                              arguments: viewModel,
                            );
                          }
                        }
                      }
                    },
                    onDelete: () => viewModel.removeLastOtp(),
                    onReset: () => viewModel.clearOtp(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  final Function(String) onTap;
  final VoidCallback onDelete;
  final VoidCallback onReset;

  const _NumericKeypad({
    required this.onTap,
    required this.onDelete,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          _buildRow(context, ['1', '2', '3']),
          _buildRow(context, ['4', '5', '6']),
          _buildRow(context, ['7', '8', '9']),
          _buildBottomRow(context),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<String> keys) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.dividerExtraLight)),
      ),
      child: Row(
        children:
            keys.map((key) => Expanded(child: _buildKey(context, key))).toList(),
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.dividerExtraLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onReset,
              child: Container(
                height: 70,
                alignment: Alignment.center,
                child: Text(
                  context.tr('reset_pin'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _buildKey(context, '0')),
          Expanded(
            child: InkWell(
              onTap: onDelete,
              child: Container(
                height: 70,
                alignment: Alignment.center,
                child: Icon(
                  Icons.backspace,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(BuildContext context, String key) {
    return InkWell(
      onTap: () => onTap(key),
      child: Container(
        height: 70,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.dividerExtraLight)),
        ),
        child: Text(
          key,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

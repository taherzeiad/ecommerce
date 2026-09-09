import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
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
          const AuthHeader(
            title: AppStrings.verifyAccountTitle,
            subtitle: '',
            centerTitle: true,
            bottomWidget: VerifyIllustration(),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    AppStrings.verifyAccountDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.authTextHeader,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.emailController.text,
                    style: const TextStyle(
                      color: AppColors.authTextHeader,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        String char = "";
                        if (viewModel.otp.length > index) {
                          char = viewModel.otp[index];
                        }
                        return Container(
                          width: 65,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.white,
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
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: char.isEmpty
                                  ? AppColors.authHint
                                  : AppColors.textDark,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 80),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Didn’t receive the code ? ',
                        style: TextStyle(
                          color: AppColors.authTextHeader,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Resend',
                          style: TextStyle(
                            color: AppColors.authLink,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(text: 'The code will expire in '),
                        TextSpan(
                          text: '2:00',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' seconds'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _NumericKeypad(
                    onTap: (val) async {
                      if (viewModel.otp.length < 4) {
                        viewModel.appendOtp(val);
                        if (viewModel.otp.length == 4) {
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
      color: AppColors.white,
      child: Column(
        children: [
          _buildRow(['1', '2', '3']),
          _buildRow(['4', '5', '6']),
          _buildRow(['7', '8', '9']),
          _buildBottomRow(),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.dividerExtraLight)),
      ),
      child: Row(
        children: keys.map((key) => Expanded(child: _buildKey(key))).toList(),
      ),
    );
  }

  Widget _buildBottomRow() {
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
                child: const Text(
                  'Reset PIN?',
                  style: TextStyle(color: AppColors.authTextHeader, fontSize: 16),
                ),
              ),
            ),
          ),
          Expanded(child: _buildKey('0')),
          Expanded(
            child: InkWell(
              onTap: onDelete,
              child: Container(
                height: 70,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.backspace,
                  color: AppColors.black,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
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
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

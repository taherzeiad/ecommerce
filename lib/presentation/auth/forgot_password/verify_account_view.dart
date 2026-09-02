import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/auth_header.dart';
import 'auth_viewmodel.dart';

class VerifyAccountView extends StatelessWidget {
  const VerifyAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = ModalRoute.of(context)!.settings.arguments as ForgotPasswordViewModel;

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
      body: Column(
        children: [
          const AuthHeader(
            title: AppStrings.verifyAccountTitle,
            subtitle: AppStrings.verifyAccountDesc,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      String char = "";
                      if (viewModel.otp.length > index) {
                        char = viewModel.otp[index];
                      }
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: char.isEmpty ? Colors.grey.shade300 : AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          char.isEmpty ? 'X' : char,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: char.isEmpty ? Colors.grey.shade300 : Colors.black,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(AppStrings.resendCode),
                      TextButton(
                        onPressed: () {
                          // Resend logic could be implemented here
                        },
                        child: const Text(
                          AppStrings.resend,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "${AppStrings.codeExpire} 00:30",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  _NumericKeypad(
                    onTap: (val) => viewModel.appendOtp(val),
                    onDelete: () => viewModel.removeLastOtp(),
                    onReset: () => viewModel.clearOtp(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              final success = await viewModel.verifyOtp();
                              if (success && context.mounted) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.resetPassword,
                                  arguments: viewModel,
                                );
                              }
                            },
                      child: viewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(AppStrings.next),
                    ),
                  ),
                  const SizedBox(height: 24),
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
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 2.0,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((digit) {
          return _KeyButton(text: digit, onTap: () => onTap(digit));
        }),
        TextButton(
          onPressed: onReset,
          child: const Text(
            AppStrings.resetPin,
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ),
        _KeyButton(text: '0', onTap: () => onTap('0')),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.backspace_outlined),
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _KeyButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../viewmodel/splash_viewmodel.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashViewModel()..init(),
      child: const _SplashBody(),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashViewModel>(
      builder: (context, viewModel, _) {
        // React to navigation decisions coming from the ViewModel.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.destination == SplashDestination.onboarding) {
            Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
          } else if (viewModel.destination == SplashDestination.login) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          } else if (viewModel.destination == SplashDestination.home) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        });

        return Scaffold(
          backgroundColor: AppColors.primaryDark,
          body: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'E',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

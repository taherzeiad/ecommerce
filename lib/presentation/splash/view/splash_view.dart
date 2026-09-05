import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
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
            Navigator.pushReplacementNamed(context, AppRoutes.mainWrapper);
          }
        });

        return Scaffold(
          backgroundColor: AppColors.primaryDark,
          body: const Center(
            child: VectorGraphic(
              loader: AssetBytesLoader(AppAssets.splash),
              width: 200, // Adjust size as needed based on the design
            ),
          ),
        );
      },
    );
  }
}

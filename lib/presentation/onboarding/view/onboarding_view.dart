import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/primary_button.dart';
import '../viewmodel/onboarding_viewmodel.dart';
import 'widgets/onboarding_page_widget.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: const _OnboardingBody(),
    );
  }
}

class _OnboardingBody extends StatelessWidget {
  const _OnboardingBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (context, viewModel, _) {
        // Navigate once the flow is marked completed (Skip or final Start).
        if (viewModel.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          });
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextButton(
                      onPressed: viewModel.isLastPage ? null : viewModel.skip,
                      child: Opacity(
                        opacity: viewModel.isLastPage ? 0 : 1,
                        child: const Text(AppStrings.skip),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: viewModel.pageController,
                    onPageChanged: viewModel.onPageChanged,
                    itemCount: viewModel.pages.length,
                    itemBuilder: (context, index) {
                      return OnboardingPageWidget(item: viewModel.pages[index]);
                    },
                  ),
                ),
                SmoothPageIndicator(
                  controller: viewModel.pageController,
                  count: viewModel.pages.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: AppColors.indicatorActive,
                    dotColor: AppColors.indicatorInactive,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: PrimaryButton(
                    label: viewModel.pages[viewModel.currentIndex].buttonLabel,
                    onPressed: viewModel.nextPage,
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

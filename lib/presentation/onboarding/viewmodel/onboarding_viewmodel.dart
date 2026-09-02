import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/onboarding_item_model.dart';
import '../../../data/repositories/onboarding_repository.dart';

/// Holds all onboarding UI state: the pages, the current index, and
/// whether we're on the last page. The View is purely declarative —
/// it reads these fields and calls [nextPage] / [skip], nothing else.
class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel({OnboardingRepository? repository})
    : _repository = repository ?? OnboardingRepositoryImpl();

  final OnboardingRepository _repository;

  final PageController pageController = PageController();

  final List<OnboardingItemModel> pages = const [
    OnboardingItemModel(
      imagePath: AppAssets.onboarding1,
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      buttonLabel: AppStrings.next,
    ),
    OnboardingItemModel(
      imagePath: AppAssets.onboarding2,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      buttonLabel: AppStrings.next,
    ),
    OnboardingItemModel(
      imagePath: AppAssets.onboarding3,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      buttonLabel: AppStrings.start,
    ),
  ];

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  bool get isLastPage => _currentIndex == pages.length - 1;

  /// Called by the PageView's onPageChanged.
  void onPageChanged(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  /// "Next" button — animates to the next page, or completes on the last one.
  Future<void> nextPage() async {
    if (isLastPage) {
      await _finishOnboarding();
      return;
    }
    await pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  /// "Skip" button — jumps straight to completion.
  Future<void> skip() => _finishOnboarding();

  bool _completed = false;

  bool get completed => _completed;

  Future<void> _finishOnboarding() async {
    await _repository.setOnboardingCompleted();
    _completed = true;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

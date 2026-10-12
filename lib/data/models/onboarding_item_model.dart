/// Plain data model for a single onboarding page.
/// Keeping this as a model (instead of hardcoding widgets per page)
/// means the ViewModel can expose a `List<OnboardingItemModel>` and
/// the View just maps over it — adding a 4th page later is a one-line change.
class OnboardingItemModel {
  final String imagePath;
  final String title;
  final String description;
  final String buttonLabel;

  const OnboardingItemModel({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonLabel,
  });
}

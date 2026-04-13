class OnboardingItem {
  final String image;
  final String title;
  final String description;
  final bool isGetStarted;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
    this.isGetStarted = false,
  });
}

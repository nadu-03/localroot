import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../common/models/onboarding_model.dart';

class OnboardingController extends GetxController {
  final currentPage = 0.obs;
  late PageController pageController;

  final List<OnboardingItem> slides = [
    OnboardingItem(
      image: 'assets/images/onboading_slide_1.png',
      title: 'Thrifting',
      description: 'Find preloved items for a better price',
    ),
    OnboardingItem(
      image: 'assets/images/onboading_slide_2.png',
      title: 'Donation',
      description: 'Gift preloved items for a better world',
    ),
    OnboardingItem(
      image: 'assets/images/start_screen_image.png',
      title: 'LocalRoot',
      description: 'Turn clutter into care',
      isGetStarted: true,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void nextPage() {
    if (currentPage.value < slides.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToGetStarted() {
    Get.toNamed('/login');
  }
}

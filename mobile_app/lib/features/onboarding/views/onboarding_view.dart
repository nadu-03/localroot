import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/color_resources.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Page View
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: (index) {
                controller.currentPage.value = index;
              },
              itemCount: controller.slides.length,
              itemBuilder: (context, index) {
                final slide = controller.slides[index];
                if (slide.isGetStarted) {
                  return Container(
                    color: ColorResources.primaryGreen,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 10,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                            child: Image.asset(
                              slide.image,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: ColorResources.lightGrey,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: ColorResources.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(22),
                                topRight: Radius.circular(22),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 90,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.eco,
                                        size: 32,
                                        color: ColorResources.primaryGreenDark,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  RichText(
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 64,
                                          ),
                                      children: const [
                                        TextSpan(
                                          text: 'Local',
                                          style: TextStyle(
                                            color: ColorResources.primaryGreen,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Root',
                                          style: TextStyle(
                                            color: ColorResources.accentBrown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Turn clutter into care',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: ColorResources.accentBrown,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: ColorResources.textDark,
                                          ),
                                      children: const [
                                        TextSpan(text: 'Buy, Sell, Donate '),
                                        TextSpan(
                                          text:
                                              'Gently used items in one place',
                                          style: TextStyle(
                                            color: ColorResources.accentBrown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 170,
                                    child: ElevatedButton(
                                      onPressed: controller.goToGetStarted,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ColorResources.accentBrown,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('Get started'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  color: ColorResources.primaryGreen,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.eco,
                            size: 40,
                            color: ColorResources.accentBrown,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned(
                              top: 95,
                              child: Image.asset(
                                slide.image,
                                width: 410,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 220,
                                    height: 220,
                                    color: ColorResources.lightGrey,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: ColorResources.accentBrown,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 40,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              slide.description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: ColorResources.accentBrown,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 74),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Dots Indicator and Buttons at bottom
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Dots Indicator
                  Obx(
                    () =>
                        controller.currentPage.value ==
                            controller.slides.length - 1
                        ? const SizedBox.shrink()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              controller.slides.length,
                              (index) => Container(
                                width: controller.currentPage.value == index
                                    ? 32
                                    : 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: controller.currentPage.value == index
                                      ? ColorResources.primaryGreen
                                      : ColorResources.borderGrey,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

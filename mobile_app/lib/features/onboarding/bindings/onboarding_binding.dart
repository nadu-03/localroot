import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/signup_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(OnboardingController.new);
    Get.lazyPut<LoginController>(LoginController.new);
    Get.lazyPut<SignUpController>(SignUpController.new);
  }
}

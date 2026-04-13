import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/app_routes.dart';

class LoginController extends GetxController {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final rememberMe = false.obs;
  final showPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  void login() {
    // Login logic here
    Get.offAllNamed(AppRoutes.home);
  }

  void forgotPassword() {
    // Forgot password logic
  }

  void loginWithGoogle() {
    // Google login logic
  }

  void goToSignUp() {
    Get.toNamed(AppRoutes.signup);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

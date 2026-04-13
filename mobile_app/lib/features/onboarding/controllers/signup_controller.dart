import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/app_routes.dart';

class SignUpController extends GetxController {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  final rememberMe = false.obs;
  final showPassword = false.obs;
  final showConfirmPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  void toggleShowConfirmPassword() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  void signUp() {
    // Sign up logic here
    Get.offAllNamed(AppRoutes.home);
  }

  void goToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

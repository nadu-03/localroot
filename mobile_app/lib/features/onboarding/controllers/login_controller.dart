import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/app_routes.dart';
import '../../../util/app_constant.dart';
import '../../../data/api/api_manager.dart';
import '../../../data/storage/storage_service.dart';
import '../../../common/models/user_model.dart';
import '../../../common/controllers/user_controller.dart';

class LoginController extends GetxController {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final formKey = GlobalKey<FormState>();
  final rememberMe = false.obs;
  final showPassword = false.obs;
  final storageService = StorageService();

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

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text;
    try {
      final resp = await ApiManager.instance.post(
        AppConstant.authSignIn,
        data: {'email': email, 'password': password},
      );
      if (resp.statusCode == 200) {
        final data = resp.data['data'];
        final token = data['token']?.toString();

        if (token != null && token.isNotEmpty) {
          await storageService.saveToken(token);

          if (data['user'] != null) {
            final user = UserModel.fromJson(data['user']);
            await storageService.saveUserData(user);
            try {
              final userController = Get.find<UserController>();
              await userController.updateUserData(user);
            } catch (_) {}
          }

          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.snackbar(
            'Login failed',
            'Missing authentication token',
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        Get.snackbar(
          'Login failed',
          resp.data?['message']?.toString() ?? 'Unknown error',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    }
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

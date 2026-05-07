import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/app_routes.dart';
import '../../../util/app_constant.dart';
import '../../../data/api/api_manager.dart';
import '../../../data/storage/storage_service.dart';
import '../../../common/models/user_model.dart';
import '../../../common/controllers/user_controller.dart';

class SignUpController extends GetxController {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  final formKey = GlobalKey<FormState>();
  final rememberMe = false.obs;
  final showPassword = false.obs;
  final showConfirmPassword = false.obs;
  final storageService = StorageService();

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

  String? validateName(String? value, String fieldLabel) {
    if ((value ?? '').trim().isEmpty) {
      return '$fieldLabel is required';
    }
    return null;
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

  String? validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> signUp() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    final username = (firstName.isNotEmpty && lastName.isNotEmpty)
        ? '${firstName} $lastName'
        : firstName.isNotEmpty
        ? firstName
        : email.split('@').first;

    final payload = {
      'username': username,
      'email': email,
      'password': password,
      'phone': '',
      'location': '',
    };

    try {
      final resp = await ApiManager.instance.post(
        AppConstant.authSignUp,
        data: payload,
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
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
            'Sign up failed',
            'Missing authentication token',
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        Get.snackbar(
          'Sign up failed',
          resp.data?['message']?.toString() ?? 'Unknown error',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    }
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

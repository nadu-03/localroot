import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/controllers/user_controller.dart';
import '../../../common/models/user_model.dart';
import '../../../data/api/api_exceptions.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final _profileService = ProfileService();
  late final Worker _userWorker;

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  final profileImagePath = 'assets/images/profile_pic.png'.obs;
  final isSaving = false.obs;
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  final profileOptions = const <String>[
    'assets/images/logo.png',
    'assets/images/clothe_1.png',
    'assets/images/clothe_2.png',
    'assets/images/clothes.png',
  ];

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    loadProfile();
    _userWorker = ever<UserModel?>(Get.find<UserController>().user, _fillForm);
  }

  void loadProfile() {
    isLoading.value = true;
    try {
      final user = Get.find<UserController>().user.value;
      _fillForm(user);
    } finally {
      isLoading.value = false;
    }
  }

  String? validateName(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Full name is required';
    if ((value ?? '').trim().length < 3) {
      return 'Full name must be at least 3 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(email)) return 'Enter a valid email';
    return null;
  }

  String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;
    if (phone.length < 7) return 'Enter a valid phone number';
    return null;
  }

  void updateProfileImage(String path) {
    profileImagePath.value = path;
  }

  Future<void> saveProfile() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isSaving.value = true;

      final userController = Get.find<UserController>();
      final currentUser = userController.user.value;
      final userId = currentUser?.userId;

      if (userId == null) {
        Get.snackbar(
          'Profile update failed',
          'User account not found. Please log in again.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final updatedUser = await _profileService.updateProfile(
        userId: userId,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        imagePath: profileImagePath.value,
      );

      await userController.updateUserData(updatedUser);
      _fillForm(updatedUser);

      Get.snackbar(
        'Profile updated',
        'Your profile details were saved successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Profile update failed',
        _errorMessage(e),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void _fillForm(UserModel? user) {
    nameController.text = user?.username ?? '';
    emailController.text = user?.email ?? '';
    phoneController.text = user?.phone ?? '';
    addressController.text = user?.location ?? '';
    final image = user?.image;
    profileImagePath.value = image == null || image.isEmpty
        ? 'assets/images/profile_pic.png'
        : image;
  }

  String _errorMessage(Object error) {
    if (error is ApiException) return error.message;
    return 'Something went wrong. Please try again.';
  }

  @override
  void onClose() {
    _userWorker.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}

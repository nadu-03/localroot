import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../util/app_constant.dart';
import '../../../util/color_resources.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'profile'.tr,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Stack(
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImageProvider(
                            controller.profileImagePath.value,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: () => _showPhotoOptions(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: ColorResources.primaryGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.add_a_photo_outlined,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _fieldLabel('Full Name'),
                _textField(
                  controller: controller.nameController,
                  validator: controller.validateName,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                _fieldLabel('Email'),
                _textField(
                  controller: controller.emailController,
                  validator: controller.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                _fieldLabel('Phone'),
                _textField(
                  controller: controller.phoneController,
                  validator: controller.validatePhone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                _fieldLabel('Address'),
                _textField(
                  controller: controller.addressController,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorResources.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        controller.isSaving.value
                            ? 'saving'.tr
                            : 'save_changes'.tr,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: ColorResources.accentBrown,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFD7D7D7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text('camera'.tr),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text('gallery'.tr),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                Text(
                  'select_profile_picture'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: controller.profileOptions.map((path) {
                    return GestureDetector(
                      onTap: () {
                        controller.updateProfileImage(path);
                        Navigator.of(bottomSheetContext).pop();
                      },
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: _profileImageProvider(path),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image != null) {
      controller.updateProfileImage(image.path);
    }
  }

  ImageProvider _profileImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    if (path.startsWith('/uploads')) {
      return NetworkImage('${AppConstant.baseUrl}$path');
    }
    if (path.startsWith('data:')) {
      try {
        return MemoryImage(base64Decode(path.split(',').last));
      } catch (_) {
        return const AssetImage('assets/images/profile_pic.png');
      }
    }
    if (!path.startsWith('assets/')) {
      return FileImage(File(path));
    }
    return AssetImage(path);
  }
}

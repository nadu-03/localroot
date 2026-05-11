import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../util/app_constant.dart';
import '../controllers/user_controller.dart';

class UserProfileAvatar extends StatelessWidget {
  const UserProfileAvatar({
    super.key,
    this.radius = 17,
    this.onTap,
  });

  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Obx(() {
        final imagePath = Get.find<UserController>().user.value?.image;
        final image = _imageProvider(imagePath);
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          backgroundImage: image,
          child: image == null
              ? Icon(Icons.person, color: Colors.black, size: radius + 7)
              : null,
        );
      }),
    );
  }

  ImageProvider? _imageProvider(String? path) {
    if (path == null || path.isEmpty) return null;

    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    if (path.startsWith('/uploads') || path.startsWith('/media')) {
      return NetworkImage('${AppConstant.baseUrl}$path');
    }
    if (path.startsWith('data:')) {
      try {
        return MemoryImage(base64Decode(path.split(',').last));
      } catch (_) {
        return null;
      }
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    return FileImage(File(path));
  }
}

import 'package:dio/dio.dart' as dio;

import '../../../common/models/user_model.dart';
import '../../../data/api/api_exceptions.dart';
import '../../../data/api/api_manager.dart';
import '../../../util/app_constant.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();

  factory ProfileService() {
    return _instance;
  }

  ProfileService._internal();

  Future<UserModel> updateProfile({
    required int userId,
    required String name,
    required String email,
    required String phone,
    required String address,
    String? imagePath,
  }) async {
    try {
      final formData = dio.FormData();
      formData.fields.addAll([
        MapEntry('username', name),
        MapEntry('email', email),
        MapEntry('phone', phone),
        MapEntry('location', address),
      ]);

      if (imagePath != null && imagePath.isNotEmpty) {
        final shouldSendAsText =
            imagePath.startsWith('assets/') ||
            imagePath.startsWith('data:') ||
            imagePath.startsWith('http') ||
            imagePath.startsWith('/uploads');

        if (shouldSendAsText) {
          formData.fields.add(MapEntry('image', imagePath));
        } else {
          formData.files.add(
            MapEntry(
              'image',
              await dio.MultipartFile.fromFile(
                imagePath,
                filename: imagePath.split('/').last,
              ),
            ),
          );
        }
      }

      final response = await ApiManager.instance.put<Map<String, dynamic>>(
        '${AppConstant.updateUserProfile}/$userId',
        data: formData,
        options: dio.Options(contentType: 'multipart/form-data'),
      );

      final responseData = response.data;
      final userData = responseData?['data'];
      if (userData is Map<String, dynamic>) {
        return UserModel.fromJson(userData);
      }
      if (userData is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(userData));
      }

      throw ApiException('Invalid profile response from server');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to update profile: $e');
    }
  }
}

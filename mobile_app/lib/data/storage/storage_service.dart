import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../common/models/user_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'accessToken';
  static const String _userDataKey = 'userData';
  static const String _languageCodeKey = 'languageCode';

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  // Token Management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  // User Data Management
  Future<void> saveUserData(UserModel user) async {
    await _secureStorage.write(
      key: _userDataKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<UserModel?> getUserData() async {
    final userJson = await _secureStorage.read(key: _userDataKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> saveLanguageCode(String languageCode) async {
    await _secureStorage.write(key: _languageCodeKey, value: languageCode);
  }

  Future<String?> getLanguageCode() async {
    return await _secureStorage.read(key: _languageCodeKey);
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _userDataKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

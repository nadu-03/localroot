import 'package:get/get.dart';
import '../models/user_model.dart';
import '../../data/storage/storage_service.dart';

class UserController extends GetxController {
  final storageService = StorageService();
  final user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final userData = await storageService.getUserData();
      user.value = userData;
    } catch (e) {
      user.value = null;
    }
  }

  Future<void> updateUserData(UserModel newUser) async {
    user.value = newUser;
    await storageService.saveUserData(newUser);
  }

  Future<void> logout() async {
    user.value = null;
    await storageService.clearAll();
  }

  String get userName => user.value?.displayName ?? 'User';
  String get userFullName => user.value?.fullName ?? 'User';
  String get userEmail => user.value?.email ?? '';
}

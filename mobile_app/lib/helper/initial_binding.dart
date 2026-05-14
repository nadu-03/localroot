import 'package:get/get.dart';
import '../common/controllers/user_controller.dart';
import '../features/language/controllers/language_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UserController());
    Get.put(LanguageController());
  }
}

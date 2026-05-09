import 'package:get/get.dart';
import '../common/controllers/user_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UserController());
  }
}

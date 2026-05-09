import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../menu/controllers/menu_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(HomeController.new);
    Get.lazyPut<AppMenuController>(AppMenuController.new);
  }
}

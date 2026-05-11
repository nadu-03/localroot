import 'package:get/get.dart';
import '../controllers/donation_controller.dart';

class DonationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DonationController>()) {
      Get.lazyPut<DonationController>(() => DonationController());
    }
  }
}

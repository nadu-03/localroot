import 'package:get/get.dart';

import '../../../data/api/api_exceptions.dart';
import '../../../data/api/api_manager.dart';
import '../../../util/app_constant.dart';

class DonationController extends GetxController {
  final donationCenters = <DonationCenter>[].obs;
  final isLoadingDonationCenters = false.obs;
  final donationCentersError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDonationCenters();
  }

  Future<void> loadDonationCenters() async {
    isLoadingDonationCenters.value = true;
    donationCentersError.value = '';

    try {
      final response = await ApiManager.instance.get(
        AppConstant.getDonationCenters,
      );
      final responseData = response.data;
      final rawCenters = responseData is Map && responseData['data'] != null
          ? responseData['data']
          : responseData;

      final loadedCenters = <DonationCenter>[];
      if (rawCenters is List) {
        for (final entry in rawCenters) {
          if (entry is Map) {
            final center = DonationCenter.fromJson(entry);
            if (center.name.isNotEmpty) {
              loadedCenters.add(center);
            }
          }
        }
      }

      donationCenters.assignAll(loadedCenters);
    } on ApiException catch (e) {
      donationCentersError.value = e.message;
      Get.snackbar(
        'Donation Centers',
        e.message,
        snackPosition: SnackPosition.TOP,
      );
    } catch (_) {
      const message = 'Failed to load donation centers';
      donationCentersError.value = message;
      Get.snackbar(
        'Donation Centers',
        message,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingDonationCenters.value = false;
    }
  }
}

class DonationCenter {
  final int id;
  final String name;
  final String location;
  final String description;
  final String phone;
  final String email;
  final String icon;

  const DonationCenter({
    required this.id,
    required this.name,
    required this.location,
    this.description = '',
    this.phone = '',
    this.email = '',
    required this.icon,
  });

  factory DonationCenter.fromJson(Map<dynamic, dynamic> json) {
    final id = int.tryParse(
          (json['charity_id'] ?? json['id'])?.toString() ?? '',
        ) ??
        0;

    return DonationCenter(
      id: id,
      name: json['name']?.toString() ?? '',
      location:
          (json['address'] ?? json['location'] ?? json['gift_location'])
                  ?.toString() ??
              '',
      description: json['description']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      icon: 'location_on',
    );
  }
}

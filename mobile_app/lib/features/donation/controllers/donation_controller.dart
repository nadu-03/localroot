import 'package:get/get.dart';

class DonationController extends GetxController {
  final donationCenters = <DonationCenter>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDonationCenters();
  }

  void _initializeDonationCenters() {
    donationCenters.assignAll([
      const DonationCenter(
        name: 'Green Hope Center',
        location: 'Colombo 05',
        icon: 'location_on',
      ),
      const DonationCenter(
        name: 'Care Share Hub',
        location: 'Kandy Town',
        icon: 'location_on',
      ),
      const DonationCenter(
        name: 'LocalRoot Drop Point',
        location: 'Galle Road',
        icon: 'location_on',
      ),
    ]);
  }
}

class DonationCenter {
  final String name;
  final String location;
  final String icon;

  const DonationCenter({
    required this.name,
    required this.location,
    required this.icon,
  });
}

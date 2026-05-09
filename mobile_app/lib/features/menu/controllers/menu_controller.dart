import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/views/home_view.dart';
import '../../home/views/donation_view.dart';
import '../../home/views/profile_view.dart';
import '../../home/views/sell_view.dart';
import '../enums/navbar_type_enum.dart';

class AppMenuController extends GetxController {
  final navbarType = NavbarType.home.obs;

  final List<Widget> screenList = const <Widget>[
    HomeView(),
    SellView(),
    DonationView(),
    ProfileView(),
  ];

  int get currentIndex => _getNavbarIndex(navbarType.value);

  void changeNavBar(int index) {
    navbarType.value = _getNavbarType(index);
  }

  NavbarType _getNavbarType(int index) {
    switch (index) {
      case 0:
        return NavbarType.home;
      case 1:
        return NavbarType.sell;
      case 2:
        return NavbarType.donate;
      case 3:
        return NavbarType.profile;
      default:
        return NavbarType.home;
    }
  }

  int _getNavbarIndex(NavbarType type) {
    switch (type) {
      case NavbarType.home:
        return 0;
      case NavbarType.sell:
        return 1;
      case NavbarType.donate:
        return 2;
      case NavbarType.profile:
        return 3;
    }
  }
}

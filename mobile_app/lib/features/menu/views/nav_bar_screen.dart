import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/color_resources.dart';
import '../controllers/menu_controller.dart';

class NavBarScreen extends GetView<AppMenuController> {
  const NavBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex,
          children: controller.screenList,
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          // margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: ColorResources.primaryGreen, width: 2),
          ),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) {
                final isActive = controller.currentIndex == index;
                return _BottomItemWidget(
                  index: index,
                  isActive: isActive,
                  onTap: () => controller.changeNavBar(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomItemWidget extends StatelessWidget {
  final int index;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomItemWidget({
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 56,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? ColorResources.primaryGreenLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          _tabIcon(index, isActive),
          size: 34,
          color: isActive ? const Color(0xFF6D4C41) : const Color(0xFF9E9E9E),
        ),
      ),
    );
  }

  IconData _tabIcon(int index, bool isActive) {
    switch (index) {
      case 0:
        return isActive ? Icons.home_rounded : Icons.home_outlined;
      case 1:
        return isActive ? Icons.local_offer : Icons.local_offer_outlined;
      case 2:
        return isActive
            ? Icons.volunteer_activism
            : Icons.volunteer_activism_outlined;
      default:
        return isActive ? Icons.person : Icons.person_outline;
    }
  }
}

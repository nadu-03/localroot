import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/controllers/user_controller.dart';

import '../../menu/controllers/menu_controller.dart';
import '../../../util/color_resources.dart';
import 'add_new_item_view.dart';
import 'view_listing_view.dart';
import 'user_chat_view.dart';

class SellView extends StatelessWidget {
  const SellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  children: [
                    _buildDashboardCard(),
                    const SizedBox(height: 10),
                    _buildSellingBanner(),
                    const SizedBox(height: 15),
                    _buildActionButton(
                      icon: Icons.add_business_outlined,
                      title: 'Add New Item',
                      onTap: () => Get.to(() => const AddNewItemView()),
                    ),
                    const SizedBox(height: 10),
                    _buildActionButton(
                      icon: Icons.view_list_outlined,
                      title: 'View Listing',
                      onTap: () => Get.to(() => const ViewListingView()),
                    ),
                    const SizedBox(height: 10),
                    _buildActionButton(
                      icon: Icons.forum_outlined,
                      title: 'User Chat',
                      onTap: () => Get.to(() => const UserChatView()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      color: ColorResources.primaryGreen,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.find<AppMenuController>().changeNavBar(3),
            borderRadius: BorderRadius.circular(17),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(Icons.person, color: Colors.black, size: 24),
            ),
          ),
          const SizedBox(width: 10),
          Obx(() {
            final userController = Get.find<UserController>();
            return Text(
              'Hi ${userController.user.value?.username ?? 'User'},',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            );
          }),
          const Spacer(),
          const Icon(Icons.notifications, color: Colors.black, size: 20),
          const SizedBox(width: 14),
          const Icon(Icons.menu, color: Colors.black, size: 28),
        ],
      ),
    );
  }

  Widget _buildDashboardCard() {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    'Seller Dashboard',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'manage your trift items\nand track your sales here',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B6B6B)),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _metricBox('Total sold\nitems', '12 items'),
                      const SizedBox(width: 6),
                      _metricBox('Total\nIncome', '7000LKR'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 6, 6, 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/onboading_slide_1.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(7, 7, 7, 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellingBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        'assets/images/seller_banner_1.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 66,
        decoration: BoxDecoration(
          color: ColorResources.primaryGreen,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF7AA466), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              offset: Offset(0, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 18),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF6D4C41),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 44),
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

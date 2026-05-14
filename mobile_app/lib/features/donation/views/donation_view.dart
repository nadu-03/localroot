import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/controllers/user_controller.dart';
import '../../../common/widgets/user_profile_avatar.dart';

import '../../menu/controllers/menu_controller.dart';
import '../../menu/widgets/app_menu_drawer.dart';
import '../../../util/color_resources.dart';
import '../../../features/home/views/ai_chat_bot_view.dart';
import '../bindings/donation_binding.dart';
import '../views/donation_centers_view.dart';
import '../../seller/views/add_new_item_view.dart';
import '../../seller/bindings/seller_binding.dart';

class DonationView extends StatelessWidget {
  const DonationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      endDrawer: const AppMenuDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  children: [
                    _buildDashboardCard(),
                    const SizedBox(height: 10),
                    _buildDonationBanner(context),
                    const SizedBox(height: 14),
                    _buildActionButton(
                      context,
                      icon: Icons.add_box_outlined,
                      title: 'Add Donation Item',
                      onTap: () => Get.to(
                        () => const AddNewItemView(),
                        binding: SellerBinding(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildActionButton(
                      context,
                      icon: Icons.chat_bubble_outline,
                      title: 'AI Chat Bot',
                      onTap: () => Get.to(() => const AiChatBotView()),
                    ),
                    const SizedBox(height: 10),
                    _buildActionButton(
                      context,
                      icon: Icons.location_on_outlined,
                      title: 'See Donation Centers',
                      onTap: () => Get.to(
                        () => const DonationCentersView(),
                        binding: DonationBinding(),
                      ),
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
          UserProfileAvatar(
            onTap: () => Get.find<AppMenuController>().changeNavBar(3),
            radius: 17,
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
          const AppMenuButton(),
        ],
      ),
    );
  }

  Widget _buildDashboardCard() {
    return Container(
      width: double.infinity,
      height: 220,
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
                    'Donation DashBoard',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'manage your donation items\nand track your impact here',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B6B6B)),
                  ),
                  // const Spacer(),
                  _metricBox('Total donated\nitems', '12 items'),
               
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
                  'assets/images/onboading_slide_2.png',
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
        padding: const EdgeInsets.fromLTRB(7, 7, 20, 7),
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

  Widget _buildDonationBanner(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset('assets/images/home_banner_1.png', fit: BoxFit.cover),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
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
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }
}

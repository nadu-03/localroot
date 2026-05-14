import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/controllers/user_controller.dart';
import '../../../common/widgets/user_profile_avatar.dart';

import '../../menu/controllers/menu_controller.dart';
import '../../menu/widgets/app_menu_drawer.dart';
import '../../../util/color_resources.dart';
import 'add_new_item_view.dart';
import '../bindings/seller_binding.dart';
import 'view_listing_view.dart';
import '../../../features/home/views/user_chat_list_view.dart';

class SellView extends StatelessWidget {
  const SellView({super.key});

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
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Column(
                  children: [
                    _buildDashboardCard(),
                    const SizedBox(height: 10),
                    _buildSellingBanner(),
                    const SizedBox(height: 15),
                    _buildActionButton(
                      icon: Icons.add_business_outlined,
                      title: 'add_new_item',
                      onTap: () => Get.to(
                        () => const AddNewItemView(),
                        binding: SellerBinding(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildActionButton(
                      icon: Icons.view_list_outlined,
                      title: 'view_listing',
                      onTap: () => Get.to(
                        () => const ViewListingView(),
                        binding: SellerBinding(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildActionButton(
                      icon: Icons.forum_outlined,
                      imagePath: 'assets/images/msg_white_icon.png',
                      title: 'user_chat',
                      onTap: () => Get.to(
                        () => const UserChatListView(
                          mode: ChatListMode.seller,
                          title: 'user_chats',
                          participantRole: 'user',
                          emptyMessage: 'no_buyer_messages',
                        ),
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
              'hi_user'.trParams({
                'name': userController.user.value?.username ?? 'user'.tr,
              }),
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
                  Text(
                    'seller_dashboard'.tr,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'seller_dashboard_subtitle'.tr,
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B6B6B)),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _metricBox('total_sold_items'.tr, '12 items'),
                      const SizedBox(width: 6),
                      _metricBox('total_income'.tr, '7000LKR'),
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
    String? imagePath,
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
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF6D4C41),
                borderRadius: BorderRadius.circular(4),
              ),
              child: imagePath == null
                  ? Icon(icon, color: Colors.white, size: 26)
                  : Padding(
                      padding: const EdgeInsets.all(7),
                      child: Image.asset(imagePath, fit: BoxFit.contain),
                    ),
            ),
            const SizedBox(width: 36),
            Text(
              title.tr,
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

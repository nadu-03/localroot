import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../menu/controllers/menu_controller.dart';
import '../../../util/color_resources.dart';
import 'ai_chat_bot_view.dart';
import 'add_new_item_view.dart';
import 'donation_centers_view.dart';

class DonationView extends StatelessWidget {
  const DonationView({super.key});

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
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  children: [
                    _buildDonationBanner(context),
                    const SizedBox(height: 14),
                    _buildActionButton(
                      context,
                      icon: Icons.add_box_outlined,
                      title: 'Add Item',
                      onTap: () => Get.to(() => const AddNewItemView()),
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
                      onTap: () => Get.to(() => const DonationCentersView()),
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
          Text(
            'Hi Naduni,',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const Icon(Icons.notifications, color: Colors.black, size: 20),
          const SizedBox(width: 14),
          const Icon(Icons.menu, color: Colors.black, size: 28),
        ],
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

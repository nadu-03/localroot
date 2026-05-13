import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/controllers/user_controller.dart';
import '../../../data/api/api_manager.dart';
import '../../../util/app_constant.dart';
import '../../../util/app_routes.dart';
import '../../home/views/drawer_info_views.dart';

class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => IconButton(
        onPressed: () => Scaffold.of(ctx).openEndDrawer(),
        icon: const Icon(Icons.menu, color: Colors.black, size: 28),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      ),
    );
  }
}

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Policy'),
                    onTap: () {
                      Get.back();
                      Get.to(() => const PrivacyPolicyView());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.gavel_outlined),
                    title: const Text('Terms & Conditions'),
                    onTap: () {
                      Get.back();
                      Get.to(() => const TermsConditionsView());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About Us'),
                    onTap: () {
                      Get.back();
                      Get.to(() => const AboutUsView());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.contact_mail_outlined),
                    title: const Text('Contact Us'),
                    onTap: () {
                      Get.back();
                      Get.to(() => const ContactUsView());
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Log out'),
                onTap: () => _showLogoutDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure?'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('No')),
            TextButton(
              onPressed: () async {
                String snackTitle = 'Success';
                String snackMessage = 'Logged out successfully';
                Color snackColor = Colors.green;
                try {
                  final resp = await ApiManager.instance.post(
                    AppConstant.authLogout,
                  );
                  snackMessage =
                      resp.data?['message']?.toString() ??
                      'Logged out successfully';
                } catch (e) {
                  debugPrint('Logout API error: $e');
                  snackTitle = 'Error';
                  snackMessage = 'Logout failed';
                  snackColor = Colors.red;
                }
                try {
                  final userController = Get.find<UserController>();
                  await userController.logout();
                } catch (_) {}
                Get.back(closeOverlays: true);
                Get.offAllNamed(AppRoutes.login);
                Future.delayed(const Duration(milliseconds: 150), () {
                  Get.snackbar(
                    snackTitle,
                    snackMessage,
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: snackColor,
                    colorText: Colors.white,
                  );
                });
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}

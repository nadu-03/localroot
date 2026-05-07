import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../menu/controllers/menu_controller.dart';
import '../../../util/app_routes.dart';
import '../../../util/app_constant.dart';
import '../../../util/color_resources.dart';
import '../../../data/api/api_manager.dart';
import '../../../common/controllers/user_controller.dart';
import '../controllers/home_controller.dart';
import 'drawer_info_views.dart';
import 'notification_view.dart';
import 'product_detail_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      endDrawer: _buildRightDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCampaignBanner(context),
                    _buildCategories(context),
                    _buildProductsGrid(context),
                    const SizedBox(height: 8),
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
    final userController = Get.find<UserController>();
    return Container(
      color: ColorResources.primaryGreen,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        children: [
          Row(
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
                  child: const Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Obx(
                () => Text(
                  'Hi ${userController.user.value?.username ?? 'User'},',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Get.to(() => const NotificationView()),
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.black,
                  size: 20,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              const SizedBox(width: 14),
              Builder(
                builder: (ctx) => IconButton(
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                  icon: const Icon(Icons.menu, color: Colors.black, size: 28),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  'Find items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8E8E8E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.search, color: Colors.black54, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightDrawer(BuildContext context) {
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

  Widget _buildCampaignBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/images/home_banner_1.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Categories',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black,
                child: Icon(Icons.chevron_right, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.isLoadingCategories.value) {
              return const SizedBox(
                height: 86,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            if (controller.categories.isEmpty) {
              return SizedBox(
                height: 86,
                child: Center(
                  child: Text(
                    'No categories available',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            return SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return GestureDetector(
                    onTap: () => controller.openCategory(category),
                    child: SizedBox(
                      width: 64,
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFEDEDED),
                              border: Border.all(
                                color: const Color(0xFFD2D2D2),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: ClipOval(
                              child: _buildAssetImage(
                                category.imagePath,
                                width: 44,
                                height: 44,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: GridView.builder(
        itemCount: controller.products.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.66,
        ),
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return GestureDetector(
            onTap: () => Get.to(
              () =>
                  ProductDetailView(categoryName: 'Clothes', product: product),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFB8B8B8)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    offset: Offset(1, 2),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFECECEC), Color(0xFFDCDCDC)],
                        ),
                        border: Border.all(color: const Color(0xFFCECECE)),
                      ),
                      alignment: Alignment.center,
                      child: _buildAssetImage(
                        product.imagePath,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: Color(0xFF8B5A3C),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${product.priceLkr} LKR',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 24,
                            alignment: Alignment.center,
                            color: ColorResources.primaryGreen,
                            child: Text(
                              'Buy now',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          height: 24,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          color: const Color(0xFFECECEC),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_circle_outlined,
                                size: 14,
                                color: Color(0xFF8B5A3C),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.sellerLabel,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Color(0xFF8B5A3C),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssetImage(
    String imagePath, {
    required double width,
    required double height,
    BoxFit fit = BoxFit.contain,
  }) {
    if (imagePath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => const Icon(
          Icons.image_outlined,
          color: Color(0xFF8C8C8C),
          size: 24,
        ),
      );
    }

    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.image_not_supported,
          color: Color(0xFF8C8C8C),
          size: 24,
        );
      },
    );
  }
}

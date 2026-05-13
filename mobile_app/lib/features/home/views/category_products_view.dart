import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

import '../../../util/app_constant.dart';
import 'package:get/get.dart';
import '../../../common/controllers/user_controller.dart';
import '../../../common/widgets/user_profile_avatar.dart';
import '../../menu/widgets/app_menu_drawer.dart';

import '../../../util/color_resources.dart';
import '../controllers/home_controller.dart';
import 'product_detail_view.dart';
import 'user_chat_view.dart';

class CategoryProductsView extends StatelessWidget {
  final HomeCategory category;
  final List<HomeProduct> products;

  const CategoryProductsView({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      endDrawer: const AppMenuDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                      child: Text(
                        category.displayName,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (products.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Text(
                            'No items available',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          itemCount: products.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.58,
                              ),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return _ProductCard(
                              product: product,
                              categoryName:
                                  product.categoryName ?? category.displayName,
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
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
      child: Column(
        children: [
          Row(
            children: [
              const UserProfileAvatar(radius: 17),
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
}

class _ProductCard extends StatelessWidget {
  final HomeProduct product;
  final String categoryName;

  const _ProductCard({required this.product, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
        () => ProductDetailView(categoryName: categoryName, product: product),
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
                child: _buildAssetImage(product.imagePath),
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _addToCart,
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 20,
                        color: Color(0xFF8B5A3C),
                      ),
                    ),
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
                    child: InkWell(
                      onTap: _addToCart,
                      child: Container(
                        height: 28,
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
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: InkWell(
                      onTap: _openSellerChat,
                      child: Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        color: const Color(0xFFD9D9D9),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/msg_icon.png',
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'Seller',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSellerChat() {
    final sellerId = product.sellerId;
    if (sellerId == null || sellerId == 0) {
      Get.snackbar(
        'Seller chat',
        'Seller details are not available for this item.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final buyerId = Get.find<UserController>().user.value?.userId;
    if (buyerId == sellerId) {
      Get.snackbar(
        'Seller chat',
        'This is your own item.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    Get.to(
      () => UserChatView(
        sellerId: sellerId,
        sellerName: product.sellerLabel,
        itemId: product.id == 0 ? null : product.id,
        itemTitle: product.title,
      ),
    );
  }

  void _addToCart() {
    Get.find<HomeController>().addToCart(product);
  }

  Widget _buildAssetImage(String imagePath) {
    try {
      final lower = imagePath.toLowerCase();
      if (lower.startsWith('data:')) {
        final comma = imagePath.indexOf(',');
        if (comma != -1) {
          final meta = imagePath.substring(5, comma);
          final data = imagePath.substring(comma + 1);
          final bytes = base64Decode(data);
          if (meta.contains('svg')) {
            return SvgPicture.memory(
              bytes,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            );
          }
          return Image.memory(
            bytes,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          );
        }
      }

      if (imagePath.startsWith('/media') || imagePath.startsWith('media/')) {
        return Image.network(
          AppConstant.baseUrl + imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.image_not_supported,
            color: Color(0xFF8C8C8C),
            size: 24,
          ),
        );
      }

      if (lower.endsWith('.svg')) {
        return SvgPicture.asset(
          imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      }

      if (lower.startsWith('http://') || lower.startsWith('https://')) {
        return Image.network(
          imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      }

      return Image.asset(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.image_not_supported,
            color: Color(0xFF8C8C8C),
            size: 24,
          );
        },
      );
    } catch (_) {
      return const Icon(
        Icons.image_not_supported,
        color: Color(0xFF8C8C8C),
        size: 24,
      );
    }
  }
}

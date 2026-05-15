import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../util/app_constant.dart';
import '../../../util/color_resources.dart';
import '../controllers/home_controller.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  HomeController get controller => Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: ColorResources.primaryGreen,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Cart',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return Center(
            child: Text(
              'No items in cart',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: controller.cartItems.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final product = controller.cartItems[index];
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFB8B8B8)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: _buildAssetImage(product.imagePath),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.priceLkr} LKR',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.removeFromCart(product),
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: Color(0xFF8B5A3C),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
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
            return SvgPicture.memory(bytes, fit: BoxFit.cover);
          }
          return Image.memory(bytes, fit: BoxFit.cover);
        }
      }

      if (imagePath.startsWith('/media') || imagePath.startsWith('media/')) {
        return Image.network(
          AppConstant.baseUrl + imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallbackIcon(),
        );
      }

      if (lower.endsWith('.svg')) {
        return SvgPicture.asset(imagePath, fit: BoxFit.cover);
      }

      if (lower.startsWith('http://') || lower.startsWith('https://')) {
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallbackIcon(),
        );
      }

      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackIcon(),
      );
    } catch (_) {
      return _fallbackIcon();
    }
  }

  Widget _fallbackIcon() {
    return const ColoredBox(
      color: Color(0xFFEDEDED),
      child: Icon(
        Icons.image_not_supported,
        color: Color(0xFF8C8C8C),
        size: 24,
      ),
    );
  }
}

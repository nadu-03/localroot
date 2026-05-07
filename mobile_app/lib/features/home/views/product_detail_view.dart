import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

import '../../../util/app_constant.dart';
import 'package:get/get.dart';

import '../../../util/color_resources.dart';
import '../../../common/controllers/user_controller.dart';
import '../controllers/home_controller.dart';

class ProductDetailView extends StatelessWidget {
  final String categoryName;
  final HomeProduct product;

  const ProductDetailView({
    super.key,
    required this.categoryName,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  'Home  /',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFB5B5B5)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 3,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                  child: _buildAssetImage(product.imagePath, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFB5B5B5)),
                        color: const Color(0xFFF1F1F1),
                      ),
                      child: _buildAssetImage(
                        product.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(
                  categoryName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8A8A8A),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: Text(
                  'Size',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _SizeChip(label: 'S', selected: false),
                    _SizeChip(label: 'M', selected: true),
                    _SizeChip(label: 'L', selected: false),
                    _SizeChip(label: 'XL', selected: false),
                    _SizeChip(label: 'XXL', selected: false),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: Text(
                  '${product.priceLkr} LKR',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorResources.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9D9D9),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                          color: Color(0xFF6D4C41),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Chat with Seller',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      color: ColorResources.primaryGreen,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(Icons.person, color: Colors.black, size: 24),
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

  Widget _buildAssetImage(String imagePath, {BoxFit fit = BoxFit.contain}) {
    try {
      final lower = imagePath.toLowerCase();
      if (lower.startsWith('data:')) {
        final comma = imagePath.indexOf(',');
        if (comma != -1) {
          final meta = imagePath.substring(5, comma);
          final data = imagePath.substring(comma + 1);
          final bytes = base64Decode(data);
          if (meta.contains('svg')) {
            return SvgPicture.memory(bytes, fit: fit);
          }
          return Image.memory(bytes, fit: fit);
        }
      }

      if (imagePath.startsWith('/media') || imagePath.startsWith('media/')) {
        return Image.network(
          AppConstant.baseUrl + imagePath,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.image_not_supported,
            color: Color(0xFF8C8C8C),
            size: 24,
          ),
        );
      }

      if (lower.endsWith('.svg')) {
        return SvgPicture.asset(imagePath, fit: fit);
      }

      if (lower.startsWith('http://') || lower.startsWith('https://')) {
        return Image.network(imagePath, fit: fit);
      }

      return Image.asset(
        imagePath,
        fit: fit,
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

class _SizeChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _SizeChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFD9D9D9) : const Color(0xFFF2F2F2),
        border: Border.all(color: const Color(0xFFB5B5B5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

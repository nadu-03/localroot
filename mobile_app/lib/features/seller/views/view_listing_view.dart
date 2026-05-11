import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/app_constant.dart';
import '../../../util/color_resources.dart';
import '../controllers/seller_controller.dart';

class ViewListingView extends StatelessWidget {
  const ViewListingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SellerController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Listing',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _TabButton(
                        label: 'sold',
                        selected: controller.selectedListingTab.value == 0,
                        onTap: () => controller.selectListingTab(0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => _TabButton(
                        label: 'unsold',
                        selected: controller.selectedListingTab.value == 1,
                        onTap: () => controller.selectListingTab(1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            Expanded(
              child: Obx(
                () => _ListingBody(
                  items: controller.currentListings,
                  isLoading: controller.isLoadingListings.value,
                  error: controller.listingError.value,
                  tabLabel: controller.selectedListingTab.value == 0
                      ? 'sold'
                      : 'unsold',
                  onRefresh: controller.loadSellerListings,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingBody extends StatelessWidget {
  final List<SellerListingItem> items;
  final bool isLoading;
  final String? error;
  final String tabLabel;
  final Future<void> Function() onRefresh;

  const _ListingBody({
    required this.items,
    required this.isLoading,
    required this.error,
    required this.tabLabel,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Text(
                error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6F6F6F),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Text(
                'No $tabLabel items yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6F6F6F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                _ListingImage(imagePath: item.imagePath),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6F6F6F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.price,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ListingImage extends StatelessWidget {
  final String imagePath;

  const _ListingImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD6D6D6)),
      ),
      clipBehavior: Clip.hardEdge,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    try {
      if (imagePath.startsWith('data:image')) {
        final comma = imagePath.indexOf(',');
        if (comma > -1) {
          return Image.memory(
            base64Decode(imagePath.substring(comma + 1)),
            fit: BoxFit.cover,
            errorBuilder: _imageError,
          );
        }
      }

      if (imagePath.startsWith('/media') || imagePath.startsWith('media/')) {
        final path = imagePath.startsWith('/') ? imagePath : '/$imagePath';
        return Image.network(
          '${AppConstant.baseUrl}$path',
          fit: BoxFit.cover,
          errorBuilder: _imageError,
        );
      }

      if (imagePath.startsWith('http')) {
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: _imageError,
        );
      }

      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: _imageError,
      );
    } catch (_) {
      return _imageError(null, null, null);
    }
  }

  Widget _imageError(
    BuildContext? context,
    Object? error,
    StackTrace? stackTrace,
  ) {
    return const ColoredBox(
      color: Color(0xFFF3F3F3),
      child: Icon(Icons.image_not_supported, color: Color(0xFF9A9A9A)),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? ColorResources.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD2D2D2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              offset: Offset(0, 1),
              blurRadius: 1,
            ),
          ],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

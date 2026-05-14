import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

import '../../../util/app_constant.dart';
import 'package:get/get.dart';

import '../../menu/controllers/menu_controller.dart';
import '../../menu/widgets/app_menu_drawer.dart';
import '../../../util/color_resources.dart';
import '../../../common/controllers/user_controller.dart';
import '../../../common/widgets/user_profile_avatar.dart';
import '../controllers/home_controller.dart';
import 'notification_view.dart';
import 'product_detail_view.dart';
import 'user_chat_list_view.dart';
import 'user_chat_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _searchTextController = TextEditingController();

  HomeController get controller => Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _searchTextController.text = controller.searchQuery.value;
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

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
              child: RefreshIndicator(
                color: ColorResources.primaryGreen,
                onRefresh: () async {
                  await Future.wait([
                    controller.loadCategories(),
                    controller.loadProducts(),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
              UserProfileAvatar(
                onTap: () => Get.find<AppMenuController>().changeNavBar(3),
                radius: 17,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Obx(
                  () => Text(
                    'hi_user'.trParams({
                      'name': userController.user.value?.username ?? 'User',
                    }),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
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
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => Get.to(
                  () => const UserChatListView(
                    mode: ChatListMode.buyer,
                    title: 'messages',
                    participantRole: 'seller',
                    emptyMessage: 'no_seller_messages',
                  ),
                ),
                icon: const Icon(Icons.message, color: Colors.black, size: 21),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              const SizedBox(width: 14),
              const AppMenuButton(),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 38,
            padding: const EdgeInsets.fromLTRB(14, 0, 10, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchTextController,
                    onChanged: controller.searchItems,
                    onSubmitted: (_) => controller.loadProducts(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'find_items'.tr,
                      hintStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(
                            color: const Color(0xFF9A9A9A),
                            fontWeight: FontWeight.w500,
                          ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchTextController.clear();
                            controller.clearSearch();
                          },
                          icon: const Icon(Icons.close, size: 18),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                        )
                      : const Icon(
                          Icons.search,
                          color: Colors.black54,
                          size: 20,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                'categories'.tr,
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
              return const SizedBox(height: 86, child: _CategoryShimmerList());
            }

            if (controller.categories.isEmpty) {
              return SizedBox(
                height: 86,
                child: Center(
                  child: Text(
                    'no_categories'.tr,
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
    return Obx(() {
      if (controller.isLoadingProducts.value) {
        return const _ProductGridShimmer();
      }

      if (controller.products.isEmpty) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 40, 14, 0),
          child: Center(
            child: Obx(
              () => Text(
                controller.searchQuery.value.trim().isEmpty
                    ? 'no_items_available'.tr
                    : 'no_items_found'.tr,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        );
      }

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
            childAspectRatio: 0.58,
          ),
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return GestureDetector(
              onTap: () => Get.to(
                () => ProductDetailView(
                  categoryName: product.categoryName ?? 'Item',
                  product: product,
                ),
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
                          InkWell(
                            onTap: () => controller.addToCart(product),
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
                              onTap: () => controller.addToCart(product),
                              child: Container(
                                height: 28,
                                alignment: Alignment.center,
                                color: ColorResources.primaryGreen,
                                child: Text(
                                  'buy_now'.tr,
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
                              onTap: () => _openSellerChat(product),
                              child: Container(
                                height: 28,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
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
                                        'seller'.tr,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
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
          },
        ),
      );
    });
  }

  void _openSellerChat(HomeProduct product) {
    final sellerId = product.sellerId;
    if (sellerId == null || sellerId == 0) {
      Get.snackbar(
        'seller_chat'.tr,
        'seller_details_not_available'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final buyerId = Get.find<UserController>().user.value?.userId;
    if (buyerId == sellerId) {
      Get.snackbar(
        'seller_chat'.tr,
        'own_item_message'.tr,
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

  Widget _buildAssetImage(
    String imagePath, {
    required double width,
    required double height,
    BoxFit fit = BoxFit.contain,
  }) {
    try {
      final lower = imagePath.toLowerCase();

      // Data URI (base64) e.g. data:image/svg+xml;base64,...
      if (lower.startsWith('data:')) {
        final comma = imagePath.indexOf(',');
        if (comma != -1) {
          final meta = imagePath.substring(5, comma);
          final data = imagePath.substring(comma + 1);
          final bytes = base64Decode(data);
          if (meta.contains('svg')) {
            return SvgPicture.memory(
              bytes,
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

          return Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.image_not_supported,
              color: Color(0xFF8C8C8C),
              size: 24,
            ),
          );
        }
      }

      // If imagePath looks like a server media path, construct full URL
      if (imagePath.startsWith('/media') || imagePath.startsWith('media/')) {
        final url = AppConstant.baseUrl + imagePath;
        return Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.image_not_supported,
            color: Color(0xFF8C8C8C),
            size: 24,
          ),
        );
      }

      // SVG asset path
      if (lower.endsWith('.svg')) {
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

      // Network absolute URL
      if (lower.startsWith('http://') || lower.startsWith('https://')) {
        return Image.network(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.image_not_supported,
            color: Color(0xFF8C8C8C),
            size: 24,
          ),
        );
      }

      // Fallback to asset
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
    } catch (_) {
      return const Icon(
        Icons.image_not_supported,
        color: Color(0xFF8C8C8C),
        size: 24,
      );
    }
  }
}

class _CategoryShimmerList extends StatelessWidget {
  const _CategoryShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        return const SizedBox(
          width: 64,
          child: Column(
            children: [
              _ShimmerBox(width: 52, height: 52, shape: BoxShape.circle),
              SizedBox(height: 8),
              _ShimmerBox(width: 50, height: 10),
            ],
          ),
        );
      },
    );
  }
}

class _ProductGridShimmer extends StatelessWidget {
  const _ProductGridShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: GridView.builder(
        itemCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.58,
        ),
        itemBuilder: (context, index) {
          return Container(
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: _ShimmerBox(width: double.infinity, height: 160),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: _ShimmerBox(width: double.infinity, height: 14),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 6, 70, 0),
                  child: _ShimmerBox(width: double.infinity, height: 12),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Row(
                    children: [
                      Expanded(child: _ShimmerBox(width: 60, height: 28)),
                      SizedBox(width: 4),
                      Expanded(child: _ShimmerBox(width: 60, height: 28)),
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

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BoxShape shape;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.shape = BoxShape.rectangle,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerPosition = (_controller.value * 2) - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment(-1 + shimmerPosition, 0),
              end: Alignment(1 + shimmerPosition, 0),
              colors: const [
                Color(0xFFE2E2E2),
                Color(0xFFF3F3F3),
                Color(0xFFE2E2E2),
              ],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}

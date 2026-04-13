import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/color_resources.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopHeader(context),
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
    return Container(
      color: ColorResources.primaryGreen,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        children: [
          Row(
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

  Widget _buildCampaignBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      color: const Color(0xFF5E8C39),
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 120, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THRIFTING + DONATION:\nTHE SUSTAINABLE CYCLE',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DECLUTTER. SHOP. GIVE BACK\nWITH LocalRoot.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 18,
                        height: 18,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 16,
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LocalRoot',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: -14,
              bottom: -6,
              child: Image.asset(
                'assets/images/start_screen_image.png',
                width: 170,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 130,
                    height: 130,
                    child: Icon(Icons.phone_iphone, color: Colors.white),
                  );
                },
              ),
            ),
          ],
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
                'categories',
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
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEDEDED),
                          border: Border.all(color: const Color(0xFFD2D2D2)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
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
                    child: Icon(
                      index.isEven ? Icons.checkroom : Icons.menu_book,
                      color: const Color(0xFF8C8C8C),
                      size: 40,
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
          );
        },
      ),
    );
  }
}

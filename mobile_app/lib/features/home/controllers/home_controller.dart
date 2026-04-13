import 'package:get/get.dart';

class HomeController extends GetxController {
  final selectedTabIndex = 0.obs;

  final categories = const <HomeCategory>[
    HomeCategory(name: 'clothes', emoji: '👕'),
    HomeCategory(name: 'Books', emoji: '📚'),
    HomeCategory(name: 'Furniture', emoji: '🪑'),
    HomeCategory(name: 'Decos', emoji: '🪴'),
    HomeCategory(name: 'others', emoji: '📦'),
  ];

  final products = const <HomeProduct>[
    HomeProduct(
      title: 'Brown corset blouse',
      priceLkr: 1000,
      sellerLabel: 'Seller',
    ),
    HomeProduct(
      title: 'Little women Book',
      priceLkr: 750,
      sellerLabel: 'Seller',
    ),
    HomeProduct(
      title: 'Vintage desk lamp',
      priceLkr: 2200,
      sellerLabel: 'Seller',
    ),
    HomeProduct(
      title: 'Handmade wall decor',
      priceLkr: 1450,
      sellerLabel: 'Seller',
    ),
  ];

  void setTab(int index) {
    selectedTabIndex.value = index;
  }
}

class HomeCategory {
  final String name;
  final String emoji;

  const HomeCategory({required this.name, required this.emoji});
}

class HomeProduct {
  final String title;
  final int priceLkr;
  final String sellerLabel;

  const HomeProduct({
    required this.title,
    required this.priceLkr,
    required this.sellerLabel,
  });
}

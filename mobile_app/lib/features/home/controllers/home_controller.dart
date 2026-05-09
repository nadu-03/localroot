import 'package:get/get.dart';

import '../views/category_products_view.dart';

class HomeController extends GetxController {
  final selectedTabIndex = 0.obs;

  final categories = const <HomeCategory>[
    HomeCategory(
      key: 'clothes',
      displayName: 'Clothes',
      imagePath: 'assets/images/clothes.png',
    ),
    HomeCategory(
      key: 'books',
      displayName: 'Books',
      imagePath: 'assets/images/books.png',
    ),
    HomeCategory(
      key: 'furniture',
      displayName: 'Furniture',
      imagePath: 'assets/images/furniture.png',
    ),
    HomeCategory(
      key: 'decos',
      displayName: 'Decos',
      imagePath: 'assets/images/decos.png',
    ),
    HomeCategory(
      key: 'others',
      displayName: 'Others',
      imagePath: 'assets/images/clothes.png',
    ),
  ];

  final products = const <HomeProduct>[
    HomeProduct(
      title: 'Brown corset blouse',
      priceLkr: 1000,
      sellerLabel: 'Seller',
      imagePath: 'assets/images/clothe_1.png',
    ),
    HomeProduct(
      title: 'Little women Book',
      priceLkr: 750,
      sellerLabel: 'Seller',
      imagePath: 'assets/images/clothe_2.png',
    ),
    HomeProduct(
      title: 'Vintage desk lamp',
      priceLkr: 2200,
      sellerLabel: 'Seller',
      imagePath: 'assets/images/clothe_1.png',
    ),
    HomeProduct(
      title: 'Handmade wall decor',
      priceLkr: 1450,
      sellerLabel: 'Seller',
      imagePath: 'assets/images/clothe_2.png',
    ),
  ];

  final categoryProducts = const <String, List<HomeProduct>>{
    'clothes': [
      HomeProduct(
        title: 'Blue checked Blouse',
        priceLkr: 800,
        sellerLabel: 'Seller',
        imagePath: 'assets/images/clothe_1.png',
      ),
      HomeProduct(
        title: 'Printed skirt',
        priceLkr: 790,
        sellerLabel: 'Seller',
        imagePath: 'assets/images/clothe_2.png',
      ),
      HomeProduct(
        title: 'Men\'s Tshirt',
        priceLkr: 900,
        sellerLabel: 'Seller',
        imagePath: 'assets/images/clothe_1.png',
      ),
      HomeProduct(
        title: 'Brown Blouse',
        priceLkr: 750,
        sellerLabel: 'Seller',
        imagePath: 'assets/images/clothe_2.png',
      ),
      HomeProduct(
        title: 'Brown Blouse',
        priceLkr: 750,
        sellerLabel: 'Seller',
        imagePath: 'assets/images/clothe_2.png',
      ),
      HomeProduct(
        title: 'Brown Blouse',
        priceLkr: 750,
        sellerLabel: 'Seller',
        imagePath: 'assets/images/clothe_2.png',
      ),
    ],
    'books': [
      HomeProduct(
        title: 'Little Women',
        priceLkr: 650,
        sellerLabel: 'Seller',
        imagePath: 'assets/images/books.png',
      ),
    ],
    'furniture': [
      HomeProduct(
        title: 'Wooden Chair',
        priceLkr: 2500,
        sellerLabel: 'Seller',
        imagePath: 'assets/images/furniture.png',
      ),
    ],
    'decos': [
      HomeProduct(
        title: 'Wall Decor',
        priceLkr: 1200,
        sellerLabel: 'Seller',
        imagePath: 'assets/images/decos.png',
      ),
    ],
    'others': [
      HomeProduct(
        title: 'Mixed Item',
        priceLkr: 500,
        sellerLabel: 'Seller',
        imagePath: 'assets/images/logo.png',
      ),
    ],
  };

  void setTab(int index) {
    selectedTabIndex.value = index;
  }

  void openCategory(HomeCategory category) {
    Get.to(
      () => CategoryProductsView(
        category: category,
        products: categoryProducts[category.key] ?? products,
      ),
    );
  }
}

class HomeCategory {
  final String key;
  final String displayName;
  final String imagePath;

  const HomeCategory({
    required this.key,
    required this.displayName,
    required this.imagePath,
  });
}

class HomeProduct {
  final String title;
  final int priceLkr;
  final String sellerLabel;
  final String imagePath;

  const HomeProduct({
    required this.title,
    required this.priceLkr,
    required this.sellerLabel,
    required this.imagePath,
  });
}

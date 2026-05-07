import 'package:get/get.dart';

import '../../../data/api/api_exceptions.dart';
import '../../../data/api/api_manager.dart';
import '../../../util/app_constant.dart';
import '../views/category_products_view.dart';

class HomeController extends GetxController {
  final selectedTabIndex = 0.obs;
  final isLoadingCategories = false.obs;

  final categories = <HomeCategory>[].obs;

  static const List<String> _sampleCategoryImages = [
    'assets/images/clothes.png',
    'assets/images/books.png',
    'assets/images/furniture.png',
    'assets/images/decos.png',
    'assets/images/logo.png',
  ];

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoadingCategories.value = true;
    try {
      final response = await ApiManager.instance.get(
        AppConstant.getAllCategories,
      );
      final responseData = response.data;
      final rawCategories = responseData is Map && responseData['data'] != null
          ? responseData['data']
          : responseData;

      final loadedCategories = <HomeCategory>[];
      if (rawCategories is List) {
        for (var index = 0; index < rawCategories.length; index++) {
          final entry = rawCategories[index];
          if (entry is Map) {
            final idValue = entry['id'] ?? entry['category_id'];
            final nameValue =
                entry['name'] ?? entry['title'] ?? entry['category_name'];
            final parsedId = int.tryParse(idValue?.toString() ?? '');
            final parsedName = nameValue?.toString();
            if (parsedId != null &&
                parsedName != null &&
                parsedName.isNotEmpty) {
              loadedCategories.add(
                HomeCategory(
                  id: parsedId,
                  key: _normalizeCategoryKey(parsedName),
                  displayName: parsedName,
                  imagePath:
                      _sampleCategoryImages[index %
                          _sampleCategoryImages.length],
                ),
              );
            }
          }
        }
      }

      categories.assignAll(loadedCategories);
    } on ApiException catch (e) {
      Get.snackbar('Categories', e.message, snackPosition: SnackPosition.TOP);
    } catch (_) {
      Get.snackbar(
        'Categories',
        'Failed to load categories',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  String _normalizeCategoryKey(String value) {
    return value.trim().toLowerCase().replaceAll(' ', '_');
  }

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
  final int id;
  final String key;
  final String displayName;
  final String imagePath;

  const HomeCategory({
    required this.id,
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

import 'package:get/get.dart';

import '../../../data/api/api_exceptions.dart';
import '../../../data/api/api_manager.dart';
import '../../../util/app_constant.dart';
import '../views/category_products_view.dart';

class HomeController extends GetxController {
  final selectedTabIndex = 0.obs;
  final isLoadingCategories = false.obs;
  final isLoadingProducts = false.obs;
  final searchQuery = ''.obs;

  final categories = <HomeCategory>[].obs;
  final products = <HomeProduct>[].obs;
  final cartItems = <HomeProduct>[].obs;
  Worker? _searchWorker;

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
    _searchWorker = debounce<String>(
      searchQuery,
      (_) => loadProducts(),
      time: const Duration(milliseconds: 450),
    );
    loadCategories();
    loadProducts();
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    super.onClose();
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
              // Use image from API when available (can be data URI or path),
              // otherwise fall back to bundled sample images.
              final apiImage = entry['image']?.toString();
              final imagePath = (apiImage != null && apiImage.isNotEmpty)
                  ? apiImage
                  : _sampleCategoryImages[index % _sampleCategoryImages.length];

              loadedCategories.add(
                HomeCategory(
                  id: parsedId,
                  key: _normalizeCategoryKey(parsedName),
                  displayName: parsedName,
                  imagePath: imagePath,
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

  Future<void> loadProducts() async {
    isLoadingProducts.value = true;
    try {
      final query = searchQuery.value.trim();
      final queryParameters = <String, dynamic>{'status': 'unsold'};
      if (query.isNotEmpty) {
        queryParameters['q'] = query;
      }

      final response = await ApiManager.instance.get(
        AppConstant.getAllProducts,
        queryParameters: queryParameters,
      );
      final responseData = response.data;
      final rawProducts = responseData is Map && responseData['data'] != null
          ? responseData['data']
          : responseData;

      final loadedProducts = <HomeProduct>[];
      if (rawProducts is List) {
        for (final entry in rawProducts) {
          if (entry is Map) {
            final product = HomeProduct.fromJson(entry);
            if (product.title.isNotEmpty) {
              loadedProducts.add(product);
            }
          }
        }
      }

      products.assignAll(loadedProducts);
    } on ApiException catch (e) {
      Get.snackbar('Items', e.message, snackPosition: SnackPosition.TOP);
    } catch (_) {
      Get.snackbar(
        'Items',
        'Failed to load items',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingProducts.value = false;
    }
  }

  void searchItems(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    if (searchQuery.value.isEmpty) return;
    searchQuery.value = '';
  }

  void setTab(int index) {
    selectedTabIndex.value = index;
  }

  void openCategory(HomeCategory category) {
    final filteredProducts = products
        .where((product) => product.categoryId == category.id)
        .toList();

    Get.to(
      () => CategoryProductsView(
        category: category,
        products: filteredProducts,
      ),
    );
  }

  void addToCart(HomeProduct product) {
    if (product.id != 0 &&
        cartItems.any((cartItem) => cartItem.id == product.id)) {
      Get.snackbar(
        'Cart',
        '${product.title} is already in your cart.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    cartItems.add(product);
    Get.snackbar(
      'Cart',
      '${product.title} added to cart.',
      snackPosition: SnackPosition.TOP,
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
  final int id;
  final int? categoryId;
  final String? categoryName;
  final String title;
  final int priceLkr;
  final int? sellerId;
  final String sellerLabel;
  final String imagePath;
  final String description;

  const HomeProduct({
    this.id = 0,
    this.categoryId,
    this.categoryName,
    this.sellerId,
    required this.title,
    required this.priceLkr,
    required this.sellerLabel,
    required this.imagePath,
    this.description = '',
  });

  factory HomeProduct.fromJson(Map<dynamic, dynamic> json) {
    final id = int.tryParse(
          (json['item_id'] ?? json['id'])?.toString() ?? '',
        ) ??
        0;
    final category = json['category'];
    final seller = json['seller'];
    final categoryIdValue = json['category_id'] ??
        (category is Map ? category['category_id'] ?? category['id'] : null);
    final categoryId = int.tryParse(
      categoryIdValue?.toString() ?? '',
    );
    final categoryName = category is Map
        ? (category['name'] ?? category['title'] ?? category['category_name'])
              ?.toString()
        : json['category_name']?.toString();
    final sellerLabel = seller is Map
        ? (seller['username'] ?? seller['name'] ?? seller['email'])
                ?.toString() ??
            'Seller'
        : 'Seller';
    final sellerId = int.tryParse(
      (json['seller_id'] ?? _sellerIdFromJson(seller))?.toString() ??
          '',
    );
    final image = json['image']?.toString();
    final price = double.tryParse(json['price']?.toString() ?? '0') ?? 0;

    return HomeProduct(
      id: id,
      categoryId: categoryId,
      categoryName: categoryName,
      sellerId: sellerId,
      title: json['title']?.toString() ?? '',
      priceLkr: price.round(),
      sellerLabel: sellerLabel,
      imagePath: image != null && image.isNotEmpty
          ? image
          : 'assets/images/logo.png',
      description: json['description']?.toString() ?? '',
    );
  }

  static dynamic _sellerIdFromJson(dynamic seller) {
    if (seller is! Map) return null;
    return seller['user_id'] ?? seller['id'];
  }
}

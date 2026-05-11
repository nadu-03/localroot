import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/seller_service.dart';
import '../../../common/controllers/user_controller.dart';
import '../../../data/api/api_exceptions.dart';
import '../../menu/controllers/menu_controller.dart';

class SellerController extends GetxController {
  final selectedListingTab = 0.obs;
  final _sellerService = SellerService();

  // Listing data models
  final soldItems = <SellerListingItem>[].obs;
  final unsoldItems = <SellerListingItem>[].obs;
  final isLoadingListings = false.obs;
  final listingError = Rx<String?>(null);

  // Add item form states
  final categories = <CategoryData>[].obs;
  final isLoadingCategories = false.obs;
  final categoryError = Rx<String?>(null);
  final isSubmittingItem = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSellerListings();
    loadCategories();
  }

  Future<void> loadSellerListings() async {
    try {
      isLoadingListings.value = true;
      listingError.value = null;

      final userController = Get.find<UserController>();
      if (userController.user.value == null) {
        await userController.loadUserData();
      }

      final sellerId = userController.user.value?.userId;
      if (sellerId == null) {
        soldItems.clear();
        unsoldItems.clear();
        listingError.value = 'Seller account not found. Please log in again.';
        return;
      }

      final listings = await _sellerService.fetchSellerListings(sellerId);
      final sold = <SellerListingItem>[];
      final unsold = <SellerListingItem>[];

      for (final listing in listings) {
        final item = SellerListingItem.fromData(listing);
        if (listing.status == 'sold') {
          sold.add(item);
        } else {
          unsold.add(item);
        }
      }

      soldItems.assignAll(sold);
      unsoldItems.assignAll(unsold);
    } on ApiException catch (e) {
      listingError.value = e.message;
      Get.snackbar(
        'Listings error',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      listingError.value = 'Failed to load listings';
      Get.snackbar(
        'Listings error',
        'Failed to load listings',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingListings.value = false;
    }
  }

  /// Load categories from API
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      categoryError.value = null;
      final loadedCategories = await _sellerService.fetchCategories();
      categories.assignAll(loadedCategories);
      if (categories.isEmpty) {
        categoryError.value = 'No categories available';
      }
    } on ApiException catch (e) {
      categoryError.value = e.message;
      Get.snackbar(
        'Categories error',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      categoryError.value = 'Failed to load categories';
      Get.snackbar(
        'Categories error',
        'Failed to load categories',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Submit a new item
  Future<bool> submitItem({
    required String title,
    required String description,
    required int categoryId,
    required double price,
    required String status,
    String? imagePath,
  }) async {
    try {
      isSubmittingItem.value = true;

      final userController = Get.find<UserController>();
      final sellerId = userController.user.value?.userId;
      if (sellerId == null) {
        Get.snackbar(
          'Error',
          'Seller account not found. Please log in again.',
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      final response = await _sellerService.createItem(
        sellerId: sellerId,
        title: title,
        description: description,
        categoryId: categoryId,
        price: price,
        status: status,
        imagePath: imagePath,
      );

      if (response.success && response.data != null) {
        final itemTitle = response.data!.title;

        Get.back();
        try {
          Get.find<AppMenuController>().changeNavBar(1);
        } catch (_) {}

        await Future<void>.delayed(const Duration(milliseconds: 250));
        await loadSellerListings();
        Get.snackbar(
          'Item added successfully',
          'Successfully created: $itemTitle',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        return true;
      } else {
        // Treat non-success responses as errors and show an error snackbar
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to add item',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'Add item failed',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Add item failed',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSubmittingItem.value = false;
    }
  }

  void selectListingTab(int index) {
    selectedListingTab.value = index;
  }

  List<SellerListingItem> get currentListings =>
      selectedListingTab.value == 0 ? soldItems : unsoldItems;
}

class SellerListingItem {
  final String imagePath;
  final String title;
  final String category;
  final String price;

  const SellerListingItem({
    required this.imagePath,
    required this.title,
    required this.category,
    required this.price,
  });

  factory SellerListingItem.fromData(SellerListingItemData data) {
    return SellerListingItem(
      imagePath: data.image == null || data.image!.isEmpty
          ? 'assets/images/logo.png'
          : data.image!,
      title: data.title,
      category: data.category,
      price: '${data.price.round()} LKR',
    );
  }
}

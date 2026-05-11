import 'package:dio/dio.dart' as dio;

import '../../../data/api/api_exceptions.dart';
import '../../../data/api/api_manager.dart';
import '../../../util/app_constant.dart';

class SellerService {
  static final SellerService _instance = SellerService._internal();

  factory SellerService() {
    return _instance;
  }

  SellerService._internal();

  // Fetch all categories from backend
  Future<List<CategoryData>> fetchCategories() async {
    try {
      final response = await ApiManager.instance.get(
        AppConstant.getAllCategories,
      );

      final responseData = response.data;
      final rawCategories = responseData is Map && responseData['data'] != null
          ? responseData['data']
          : responseData;

      final categories = <CategoryData>[];
      if (rawCategories is List) {
        for (final category in rawCategories) {
          if (category is Map) {
            final idValue = category['id'] ?? category['category_id'];
            final nameValue =
                category['name'] ??
                category['title'] ??
                category['category_name'];
            final parsedId = int.tryParse(idValue?.toString() ?? '');
            if (parsedId != null && nameValue != null) {
              categories.add(
                CategoryData(id: parsedId, name: nameValue.toString()),
              );
            }
          }
        }
      }
      return categories;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch categories: $e');
    }
  }

  Future<List<SellerListingItemData>> fetchSellerListings(int sellerId) async {
    try {
      final response = await ApiManager.instance.get(
        '${AppConstant.getAllProducts}/seller/$sellerId',
      );

      final responseData = response.data;
      final rawItems = responseData is Map && responseData['data'] != null
          ? responseData['data']
          : responseData;

      final items = <SellerListingItemData>[];
      if (rawItems is List) {
        for (final item in rawItems) {
          if (item is Map) {
            final listingItem = SellerListingItemData.fromJson(item);
            if (listingItem.title.isNotEmpty) {
              items.add(listingItem);
            }
          }
        }
      }

      return items;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to fetch seller listings: $e');
    }
  }

  // Create a new item with optional image
  Future<ItemCreateResponse> createItem({
    required int sellerId,
    required String title,
    required String description,
    required int categoryId,
    required double price,
    required String status,
    String? imagePath,
  }) async {
    try {
      final formData = dio.FormData();
      formData.fields.addAll([
        MapEntry('seller_id', sellerId.toString()),
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('category_id', categoryId.toString()),
        MapEntry('price', price.toString()),
        MapEntry('status', status),
      ]);

      // Add image if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'image',
            await dio.MultipartFile.fromFile(
              imagePath,
              filename: imagePath.split('/').last,
            ),
          ),
        );
      }

      final response = await ApiManager.instance.post(
        AppConstant.createItem,
        data: formData,
        options: dio.Options(contentType: 'multipart/form-data'),
      );

      return ItemCreateResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to create item: $e');
    }
  }
}

// Response model for item creation
class ItemCreateResponse {
  final bool success;
  final int code;
  final String message;
  final ItemData? data;

  ItemCreateResponse({
    required this.success,
    required this.code,
    required this.message,
    this.data,
  });

  factory ItemCreateResponse.fromJson(Map<String, dynamic> json) {
    return ItemCreateResponse(
      success: json['success'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? ItemData.fromJson(json['data']) : null,
    );
  }
}

// Item data model
class ItemData {
  final int itemId;
  final String title;
  final String description;
  final int categoryId;
  final double price;
  final String? image;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemData({
    required this.itemId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.price,
    this.image,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemData.fromJson(Map<String, dynamic> json) {
    return ItemData(
      itemId: json['id'] ?? json['item_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      image: json['image'],
      status: json['status'] ?? 'available',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}

// Category data model
class CategoryData {
  final int id;
  final String name;

  CategoryData({required this.id, required this.name});

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class SellerListingItemData {
  final int id;
  final String title;
  final String category;
  final double price;
  final String? image;
  final String status;

  const SellerListingItemData({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    this.image,
    required this.status,
  });

  factory SellerListingItemData.fromJson(Map<dynamic, dynamic> json) {
    final category = json['category'];
    final categoryName = category is Map
        ? (category['name'] ?? category['title'] ?? category['category_name'])
              ?.toString()
        : (json['category'] ?? json['category_name'])?.toString();
    final price = double.tryParse(json['price']?.toString() ?? '0') ?? 0;

    return SellerListingItemData(
      id:
          int.tryParse(
            (json['item_id'] ?? json['id'])?.toString() ?? '',
          ) ??
          0,
      title: json['title']?.toString() ?? '',
      category: categoryName == null || categoryName.isEmpty
          ? 'Uncategorized'
          : categoryName,
      price: price,
      image: json['image']?.toString(),
      status: (json['status'] ?? 'active').toString().toLowerCase(),
    );
  }
}

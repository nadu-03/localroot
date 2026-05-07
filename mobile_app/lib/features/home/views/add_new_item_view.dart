import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/controllers/user_controller.dart';
import '../../../data/api/api_exceptions.dart';
import '../../../data/api/api_manager.dart';
import '../../../util/app_constant.dart';
import '../../../util/color_resources.dart';

class AddNewItemView extends StatefulWidget {
  const AddNewItemView({super.key});

  @override
  State<AddNewItemView> createState() => _AddNewItemViewState();
}

class _AddNewItemViewState extends State<AddNewItemView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _statusController = TextEditingController(text: 'available');
  final _imagePicker = ImagePicker();

  final List<_CategoryOption> _categories = [];

  int? _selectedCategoryId;
  bool _isLoadingCategories = true;
  String? _categoryError;
  XFile? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiManager.instance.get(
        AppConstant.getAllCategories,
      );
      final responseData = response.data;
      final rawCategories = responseData is Map && responseData['data'] != null
          ? responseData['data']
          : responseData;

      final loadedCategories = <_CategoryOption>[];
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
              loadedCategories.add(
                _CategoryOption(id: parsedId, name: nameValue.toString()),
              );
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _categories
          ..clear()
          ..addAll(loadedCategories);
        _selectedCategoryId = _categories.isNotEmpty
            ? _categories.first.id
            : null;
        _categoryError = _categories.isEmpty ? 'No categories available' : null;
        _isLoadingCategories = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _categoryError = e.message;
        _isLoadingCategories = false;
      });
      Get.snackbar(
        'Categories error',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categoryError = 'Failed to load categories';
        _isLoadingCategories = false;
      });
      Get.snackbar(
        'Categories error',
        'Failed to load categories',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (!mounted) return;
    setState(() => _selectedImage = picked);
  }

  Future<void> _submitItem() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedImage == null) {
      Get.snackbar(
        'Validation',
        'Please select an image',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final userController = Get.find<UserController>();
    final sellerId = userController.user.value?.userId;
    if (sellerId == null) {
      Get.snackbar(
        'Error',
        'Seller account not found. Please log in again.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final parsedPrice = double.tryParse(_priceController.text.trim());
    if (parsedPrice == null) {
      Get.snackbar(
        'Validation',
        'Please enter a valid price',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final selectedCategoryId = _selectedCategoryId;
    if (selectedCategoryId == null) {
      Get.snackbar(
        'Validation',
        'Please select a category',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final formData = dio.FormData();
      formData.fields.addAll([
        MapEntry('seller_id', sellerId.toString()),
        MapEntry('title', _titleController.text.trim()),
        MapEntry('description', _descriptionController.text.trim()),
        MapEntry('category_id', selectedCategoryId.toString()),
        MapEntry('price', parsedPrice.toString()),
        MapEntry(
          'status',
          _statusController.text.trim().isEmpty
              ? 'available'
              : _statusController.text.trim(),
        ),
      ]);
      formData.files.add(
        MapEntry(
          'image',
          await dio.MultipartFile.fromFile(
            _selectedImage!.path,
            filename: _selectedImage!.name,
          ),
        ),
      );

      final response = await ApiManager.instance.post(
        AppConstant.createItem,
        data: formData,
        options: dio.Options(contentType: 'multipart/form-data'),
      );

      final message =
          response.data?['message']?.toString() ?? 'Item added successfully';
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      if (!mounted) return;
      setState(() {
        _titleController.clear();
        _priceController.clear();
        _descriptionController.clear();
        _statusController.text = 'available';
        _selectedCategoryId = _categories.isNotEmpty
            ? _categories.first.id
            : null;
        _selectedImage = null;
      });
      Get.back();
    } on ApiException catch (e) {
      Get.snackbar(
        'Add item failed',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (_) {
      Get.snackbar(
        'Add item failed',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.close, size: 28),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add New Item',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _label('product name'),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration(),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Product name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _label('product price'),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Price is required';
                    }
                    if (double.tryParse(value!.trim()) == null) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _label('category'),
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFCFCF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: _isLoadingCategories
                        ? const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Loading categories...'),
                          )
                        : DropdownButton<int>(
                            value: _selectedCategoryId,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            hint: Text(_categoryError ?? 'Select category'),
                            items: _categories
                                .map(
                                  (category) => DropdownMenuItem<int>(
                                    value: category.id,
                                    child: Text(category.name),
                                  ),
                                )
                                .toList(),
                            onChanged: _categories.isEmpty
                                ? null
                                : (value) {
                                    if (value == null) return;
                                    setState(() => _selectedCategoryId = value);
                                  },
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                _label('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: _inputDecoration(isMultiline: true),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _label('status'),
                TextFormField(
                  controller: _statusController,
                  decoration: _inputDecoration(),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Status is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _label('upload Images'),
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFCFCF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage == null
                        ? Stack(
                            alignment: Alignment.center,
                            children: const [
                              Positioned(
                                top: 10,
                                child: Text(
                                  'Image',
                                  style: TextStyle(
                                    color: Color(0xFFB2B2B2),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Icon(Icons.add_photo_alternate_rounded, size: 48),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedImage!.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorResources.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Add Item',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: ColorResources.accentBrown,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static InputDecoration _inputDecoration({bool isMultiline = false}) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF9DCB84), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFCFCFCF),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: isMultiline ? 10 : 12,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
  }
}

class _CategoryOption {
  final int id;
  final String name;

  const _CategoryOption({required this.id, required this.name});
}

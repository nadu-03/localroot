import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../util/color_resources.dart';
import '../controllers/seller_controller.dart';

class AddNewItemView extends StatefulWidget {
  const AddNewItemView({super.key});

  @override
  State<AddNewItemView> createState() => _AddNewItemViewState();
}

class _AddNewItemViewState extends State<AddNewItemView> {
  late SellerController _sellerController;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _statusController;
  late final ImagePicker _imagePicker;

  XFile? _selectedImage;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _sellerController = Get.find<SellerController>();
    _formKey = GlobalKey<FormState>();
    _titleController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _statusController = TextEditingController(text: 'available');
    _imagePicker = ImagePicker();

    // Set initial category if available
    if (_sellerController.categories.isNotEmpty) {
      _selectedCategoryId = _sellerController.categories.first.id;
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

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

    final success = await _sellerController.submitItem(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: selectedCategoryId,
      price: parsedPrice,
      status: _statusController.text.trim().isEmpty
          ? 'available'
          : _statusController.text.trim(),
      imagePath: _selectedImage?.path,
    );

    if (success && mounted) {
      // on success, controller navigates back and switches to seller tab.
      // Optionally clear local fields if still mounted, but do not pop here
      _titleController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _statusController.text = 'available';
      if (_sellerController.categories.isNotEmpty) {
        _selectedCategoryId = _sellerController.categories.first.id;
      }
      _selectedImage = null;
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
                Obx(
                  () => Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFCFCF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: _sellerController.isLoadingCategories.value
                          ? const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Loading categories...'),
                            )
                          : DropdownButton<int>(
                              value: _selectedCategoryId,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              hint: Text(
                                _sellerController.categoryError.value ??
                                    'Select category',
                              ),
                              items: _sellerController.categories
                                  .map(
                                    (category) => DropdownMenuItem<int>(
                                      value: category.id,
                                      child: Text(category.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _sellerController.categories.isEmpty
                                  ? null
                                  : (value) {
                                      if (value == null) return;
                                      setState(
                                        () => _selectedCategoryId = value,
                                      );
                                    },
                            ),
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
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: _sellerController.isSubmittingItem.value
                          ? null
                          : _submitItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorResources.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _sellerController.isSubmittingItem.value
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

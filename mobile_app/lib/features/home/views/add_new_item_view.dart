import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/color_resources.dart';

class AddNewItemView extends StatefulWidget {
  const AddNewItemView({super.key});

  @override
  State<AddNewItemView> createState() => _AddNewItemViewState();
}

class _AddNewItemViewState extends State<AddNewItemView> {
  String selectedCategory = 'Clothes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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
              _field(TextField(decoration: _inputDecoration())),
              const SizedBox(height: 8),
              _label('product price'),
              _field(TextField(decoration: _inputDecoration())),
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
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: const [
                      DropdownMenuItem(
                        value: 'Clothes',
                        child: Text('Clothes'),
                      ),
                      DropdownMenuItem(value: 'Books', child: Text('Books')),
                      DropdownMenuItem(
                        value: 'Furniture',
                        child: Text('Furniture'),
                      ),
                      DropdownMenuItem(value: 'Decos', child: Text('Decos')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedCategory = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _label('Description'),
              _field(
                TextField(
                  maxLines: 4,
                  decoration: _inputDecoration(isMultiline: true),
                ),
                height: 86,
              ),
              const SizedBox(height: 8),
              _label('size'),
              _field(TextField(decoration: _inputDecoration())),
              const SizedBox(height: 8),
              _label('upload Images'),
              Container(
                width: double.infinity,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFCFCF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
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
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorResources.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Add Item',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    );
  }

  static InputDecoration _inputDecoration({bool isMultiline = false}) {
    return InputDecoration(
      border: InputBorder.none,
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

  Widget _field(Widget child, {double height = 40}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFCFCFCF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

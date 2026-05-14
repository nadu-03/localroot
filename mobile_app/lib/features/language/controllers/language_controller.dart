import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/storage/storage_service.dart';

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

class LanguageController extends GetxController {
  final StorageService _storageService = StorageService();

  final selectedCode = 'en'.obs;

  static const supportedLanguages = <LanguageOption>[
    LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
    LanguageOption(code: 'si', name: 'Sinhala', nativeName: 'සිංහල'),
    LanguageOption(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
  ];

  Locale get locale => Locale(selectedCode.value);

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Future<void> changeLanguage(String code) async {
    selectedCode.value = code;
    final locale = Locale(code);
    Get.updateLocale(locale);
    await _storageService.saveLanguageCode(code);
  }

  LanguageOption optionFor(String code) {
    return supportedLanguages.firstWhere(
      (option) => option.code == code,
      orElse: () => supportedLanguages.first,
    );
  }

  Future<void> _loadSavedLanguage() async {
    final savedCode = await _storageService.getLanguageCode();
    if (savedCode == null || savedCode.isEmpty) {
      await changeLanguage('en');
      return;
    }

    selectedCode.value = savedCode;
    Get.updateLocale(Locale(savedCode));
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/color_resources.dart';
import '../controllers/language_controller.dart';

class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.creamBg,
      appBar: AppBar(title: Text('language'.tr)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'choose_language'.tr,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: ColorResources.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'language_subtitle'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ColorResources.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  final selectedCode = controller.selectedCode.value;
                  return ListView.separated(
                    itemCount: LanguageController.supportedLanguages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final option =
                          LanguageController.supportedLanguages[index];
                      return _LanguageTile(
                        option: option,
                        isSelected: option.code == selectedCode,
                        onTap: () => controller.changeLanguage(option.code),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final LanguageOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? ColorResources.primaryGreenDark
                  : ColorResources.borderGrey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isSelected
                    ? ColorResources.primaryGreenLight
                    : ColorResources.lightGrey,
                child: Text(
                  option.code.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: ColorResources.accentBrown,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.nativeName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ColorResources.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ColorResources.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: ColorResources.primaryGreenDark,
                )
              else
                const Icon(Icons.chevron_right, color: ColorResources.textGrey),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/color_resources.dart';
import '../controllers/donation_controller.dart';

class DonationCentersView extends GetView<DonationController> {
  const DonationCentersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: ColorResources.primaryGreen,
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    color: Colors.black,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'donation_centers'.tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () {
                  if (controller.isLoadingDonationCenters.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.donationCentersError.value.isNotEmpty) {
                    return _DonationCentersMessage(
                      icon: Icons.error_outline,
                      message: controller.donationCentersError.value,
                      buttonText: 'try_again',
                      onPressed: controller.loadDonationCenters,
                    );
                  }

                  final centers = controller.donationCenters;
                  if (centers.isEmpty) {
                    return _DonationCentersMessage(
                      icon: Icons.location_off_outlined,
                      message: 'no_donation_centers_available'.tr,
                      buttonText: 'refresh',
                      onPressed: controller.loadDonationCenters,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.loadDonationCenters,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: centers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final center = centers[index];
                        return _DonationCenterCard(center: center);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationCenterCard extends StatelessWidget {
  final DonationCenter center;

  const _DonationCenterCard({required this.center});

  @override
  Widget build(BuildContext context) {
    final subtitle = center.location.isNotEmpty
        ? center.location
        : center.description.isNotEmpty
            ? center.description
            : 'location_not_provided'.tr;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7D7D7)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF6D4C41),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF666666),
                      ),
                ),
                if (center.phone.isNotEmpty || center.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (center.phone.isNotEmpty) center.phone,
                      if (center.email.isNotEmpty) center.email,
                    ].join(' | '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF777777),
                        ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black54),
        ],
      ),
    );
  }
}

class _DonationCentersMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String buttonText;
  final Future<void> Function() onPressed;

  const _DonationCentersMessage({
    required this.icon,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: const Color(0xFF6D4C41)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF555555),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorResources.primaryGreen,
                foregroundColor: Colors.black,
              ),
              child: Text(buttonText.tr),
            ),
          ],
        ),
      ),
    );
  }
}

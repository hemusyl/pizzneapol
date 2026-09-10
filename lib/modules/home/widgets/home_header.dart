import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/location_controller.dart';

/// Top header matching the reference screenshot:
/// - Left: Hamburger menu icon
/// - Center-left: Circular mascot logo badge + "PIZZNEAPOL PIZZA" bold text
/// - Right: "DELIVERY ▾" dropdown indicator
class HomeHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;

  const HomeHeader({
    super.key,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Hamburger Menu Icon
          InkWell(
            onTap: onMenuPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MenuLine(width: 22),
                  SizedBox(height: 4),
                  _MenuLine(width: 16),
                  SizedBox(height: 4),
                  _MenuLine(width: 22),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 2. PIZZNEAPOL PIZZA Logo badge + Brand Text
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_pizza_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'PIZZNEAPOL PIZZA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),

          const Spacer(),

          // 3. DELIVERY ▾ Dropdown on the right
          Obx(() {
            return InkWell(
              onTap: () => _showDeliveryOptions(context, locationController),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locationController.deliveryType.value,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showDeliveryOptions(BuildContext context, LocationController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Fulfillment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delivery_dining, color: AppColors.primary),
              title: const Text('Delivery to Address', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: controller.deliveryType.value == 'DELIVERY'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                controller.setDeliveryType('DELIVERY');
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.storefront, color: AppColors.primary),
              title: const Text('Store Pickup', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: controller.deliveryType.value == 'PICKUP'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                controller.setDeliveryType('PICKUP');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuLine extends StatelessWidget {
  final double width;
  const _MenuLine({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 2.6,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

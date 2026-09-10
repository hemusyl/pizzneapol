import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/location_controller.dart';

/// Location & delivery address banner matching the reference screenshot:
/// - Light peach/cream background (#FFF2E8)
/// - Height ~42px with rounded 12px corners
/// - Dynamic address in orange text
/// - Location pin icon on the right
class LocationBar extends StatelessWidget {
  const LocationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Obx(() {
        return InkWell(
          onTap: () => _showAddressSelectionModal(context, locationController),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              color: AppColors.primaryPeach,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    locationController.currentAddress.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 19,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showAddressSelectionModal(BuildContext context, LocationController controller) {
    final textController = TextEditingController();

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Input for entering a custom address
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Enter new delivery address...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      controller.addAddress(textController.text.trim());
                      Get.back();
                    }
                  },
                ),
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  controller.addAddress(val.trim());
                  Get.back();
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Saved Addresses',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Obx(() {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.savedAddresses.length,
                  itemBuilder: (context, index) {
                    final addr = controller.savedAddresses[index];
                    final isSelected = addr == controller.currentAddress.value;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.place_outlined,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                      title: Text(
                        addr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () {
                        controller.setAddress(addr);
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

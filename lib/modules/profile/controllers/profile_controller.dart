import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';

/// Controller managing user account information, notification preferences,
/// and profile editing.
class ProfileController extends GetxController {
  /// Current authenticated user profile
  final Rx<UserModel> user = UserModel(
    id: 'USR-1092',
    name: 'Alex Johnson',
    email: 'alex.johnson@example.com',
    phone: '+1 (555) 234-5678',
    memberSince: DateTime(2023, 4, 15),
  ).obs;

  /// User preference toggles
  final RxBool pushNotifications = true.obs;
  final RxBool orderAlerts = true.obs;
  final RxBool specialOffers = false.obs;

  /// Updates personal details
  void updateProfile({
    required String name,
    required String phone,
    required String email,
  }) {
    user.value = user.value.copyWith(
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
    );

    if (Get.context != null) {
      Get.snackbar(
        'Profile Updated',
        'Your profile changes have been saved successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF36C0A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Toggles push notifications
  void togglePushNotifications(bool value) {
    pushNotifications.value = value;
  }

  /// Toggles order status SMS/alert updates
  void toggleOrderAlerts(bool value) {
    orderAlerts.value = value;
  }

  /// Toggles promotional emails and notifications
  void toggleSpecialOffers(bool value) {
    specialOffers.value = value;
  }

  /// Performs user sign out
  void signOut() {
    if (Get.context != null) {
      Get.snackbar(
        'Signed Out',
        'You have been signed out of your account.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.grey.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }
}

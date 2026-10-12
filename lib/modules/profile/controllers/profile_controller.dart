import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/session_service.dart';

/// Controller managing user account information, notification preferences,
/// and profile editing.
class ProfileController extends GetxController {
  final IAuthRepository? authRepository;

  ProfileController({IAuthRepository? repository})
      : authRepository = repository ??
            (Get.isRegistered<AuthRepository>()
                ? Get.find<AuthRepository>()
                : null);

  /// Current authenticated user profile (null when guest / not logged in)
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  /// Whether user is currently authenticated
  bool get isLoggedIn => user.value != null;

  /// Notification preference toggles
  final RxBool pushNotifications = true.obs;
  final RxBool orderAlerts = true.obs;
  final RxBool specialOffers = false.obs;

  /// Restaurant Owner / Kitchen Manager mode toggle (for testing/admin access)
  final RxBool isOwnerMode = false.obs;

  /// Whether current user can access the Owner / Kitchen Dashboard
  bool get canAccessOwnerDashboard => (user.value?.isOwner ?? false) || isOwnerMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadInitialUser();
  }

  void _loadInitialUser() {
    if (authRepository != null && authRepository!.currentUser != null) {
      user.value = authRepository!.currentUser;
    }
  }

  /// Sets current logged in user
  void setUser(UserModel? newUser) {
    user.value = newUser;
  }

  /// Updates personal details
  void updateProfile({
    required String name,
    required String phone,
    required String email,
  }) {
    if (user.value == null) return;
    user.value = user.value!.copyWith(
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

  /// Toggles simulated Restaurant Owner / Kitchen Manager role
  void toggleOwnerMode(bool value) {
    isOwnerMode.value = value;
    if (Get.context != null) {
      Get.snackbar(
        value ? 'Restaurant Owner Mode Enabled' : 'Customer Mode Active',
        value
            ? 'You can now manage kitchen orders and trigger push notifications!'
            : 'Switched back to standard customer view.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: value ? const Color(0xFFF36C0A) : Colors.grey.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Performs user sign out
  void signOut() {
    user.value = null;
    authRepository?.logout();
    SessionService.clearSession();
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

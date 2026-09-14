import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../profile/controllers/profile_controller.dart';

/// Controller handling Customer Authentication (Login & Register) state and interactions.
class AuthController extends GetxController {
  final IAuthRepository authRepository;

  AuthController({IAuthRepository? repository})
      : authRepository = repository ??
            (Get.isRegistered<AuthRepository>()
                ? Get.find<AuthRepository>()
                : AuthRepository());

  // ==========================================
  // TEXT CONTROLLERS
  // ==========================================

  // Login inputs
  final TextEditingController loginIdentifierController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Register inputs
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerMobileController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerAddressController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();
  final TextEditingController registerConfirmPasswordController = TextEditingController();

  // ==========================================
  // REACTIVE OBSERVABLES
  // ==========================================

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxBool isLoginPasswordHidden = true.obs;
  final RxBool isRegisterPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;

  @override
  void onClose() {
    loginIdentifierController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerMobileController.dispose();
    registerEmailController.dispose();
    registerAddressController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    super.onClose();
  }

  // ==========================================
  // PASSWORD VISIBILITY TOGGLES
  // ==========================================

  void toggleLoginPasswordVisibility() {
    isLoginPasswordHidden.value = !isLoginPasswordHidden.value;
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordHidden.value = !isRegisterPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // ==========================================
  // LOGIN ACTION
  // ==========================================

  Future<bool> login() async {
    final identifier = loginIdentifierController.text.trim();
    final password = loginPasswordController.text;

    if (identifier.isEmpty) {
      _showError('Please enter your email address or mobile number.');
      return false;
    }

    if (password.isEmpty) {
      _showError('Please enter your password.');
      return false;
    }

    errorMessage.value = '';
    isLoading.value = true;

    try {
      final result = await authRepository.login(
        identifier: identifier,
        password: password,
      );

      isLoading.value = false;

      if (result.success && result.user != null) {
        // Synchronize with ProfileController if active
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().user.value = result.user!;
        }

        _showSuccess('Welcome back, ${result.user!.name}!');

        // Clear password
        loginPasswordController.clear();

        // Navigate
        if (Get.key.currentState != null) {
          if (Get.key.currentState!.canPop()) {
            Get.back();
          } else {
            Get.offAllNamed(Routes.MAIN);
          }
        }
        return true;
      } else {
        final err = result.formattedErrorString;
        errorMessage.value = err;
        _showError(err);
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      final msg = 'An unexpected error occurred: $e';
      errorMessage.value = msg;
      _showError(msg);
      return false;
    }
  }

  // ==========================================
  // REGISTER ACTION
  // ==========================================

  Future<bool> register() async {
    final name = registerNameController.text.trim();
    final mobile = registerMobileController.text.trim();
    final email = registerEmailController.text.trim();
    final address = registerAddressController.text.trim();
    final password = registerPasswordController.text;
    final confirmPassword = registerConfirmPasswordController.text;

    // Validation
    if (name.isEmpty) {
      _showError('Please enter your full name.');
      return false;
    }

    if (mobile.isEmpty) {
      _showError('Please enter your mobile phone number.');
      return false;
    }

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      _showError('Please enter a valid email address.');
      return false;
    }

    if (address.isEmpty) {
      _showError('Please enter your delivery address.');
      return false;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters long.');
      return false;
    }

    if (password != confirmPassword) {
      _showError('Password confirmation does not match.');
      return false;
    }

    errorMessage.value = '';
    isLoading.value = true;

    try {
      final result = await authRepository.register(
        name: name,
        mobile: mobile,
        email: email,
        address: address,
        password: password,
        confirmPassword: confirmPassword,
      );

      isLoading.value = false;

      if (result.success && result.user != null) {
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().user.value = result.user!;
        }

        _showSuccess('Account created successfully! Welcome, ${result.user!.name}.');

        // Clear sensitive inputs
        registerPasswordController.clear();
        registerConfirmPasswordController.clear();

        if (Get.key.currentState != null) {
          Get.offAllNamed(Routes.MAIN);
        }
        return true;
      } else {
        final err = result.formattedErrorString;
        errorMessage.value = err;
        _showError(err);
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      final msg = 'An unexpected error occurred: $e';
      errorMessage.value = msg;
      _showError(msg);
      return false;
    }
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  void logout() {
    authRepository.logout();
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().signOut();
    }
    _showSuccess('Signed out successfully.');
    if (Get.key.currentState != null) {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  // ==========================================
  // HELPERS
  // ==========================================

  void _showError(String message) {
    if (Get.context != null) {
      Get.snackbar(
        'Authentication Notice',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    }
  }

  void _showSuccess(String message) {
    if (Get.context != null) {
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
      );
    }
  }
}

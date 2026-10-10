import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/session_service.dart';
import '../../../data/services/notification_service.dart';
import '../../profile/controllers/profile_controller.dart';

/// Controller managing splash screen animations, session restoration,
/// and initial route determination.
class SplashController extends GetxController {
  final RxDouble opacity = 0.0.obs;
  final RxDouble scale = 0.85.obs;

  @override
  void onInit() {
    super.onInit();
    _startAnimationAndRestoreSession();
  }

  Future<void> _startAnimationAndRestoreSession() async {
    // Trigger fade and scale animation
    await Future.delayed(const Duration(milliseconds: 100));
    opacity.value = 1.0;
    scale.value = 1.0;

    // Concurrently restore session from local storage
    try {
      final token = await SessionService.getToken();
      final user = await SessionService.getUser();

      if (token != null && token.isNotEmpty && user != null) {
        if (Get.isRegistered<AuthRepository>()) {
          Get.find<AuthRepository>().restoreSession(user: user, token: token);
        }
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().setUser(user);
        } else {
          Get.put(ProfileController(), permanent: true).setUser(user);
        }
        if (Get.isRegistered<NotificationService>()) {
          Get.find<NotificationService>().syncTokenWithBackend();
        }
      }
    } catch (_) {
      // Graceful fallback to unauthenticated state if storage access fails
    }

    // Display splash for 1.8 seconds for smooth branding
    await Future.delayed(const Duration(milliseconds: 1700));

    // Navigate to Home/Main view (whether logged in or guest)
    if (Get.key.currentState != null) {
      Get.offAllNamed(Routes.MAIN);
    }
  }
}

import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';

/// Dependency injection binding for Authentication module (Login and Register).
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => AuthRepository());
    }
    Get.lazyPut<AuthController>(
      () => AuthController(repository: Get.find<AuthRepository>()),
    );
  }
}

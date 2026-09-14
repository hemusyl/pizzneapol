import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

/// Dependency injection binding for Splash module.
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}

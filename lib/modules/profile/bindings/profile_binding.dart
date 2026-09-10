import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

/// Dependency injection binding for the Profile module.
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

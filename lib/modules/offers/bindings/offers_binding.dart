import 'package:get/get.dart';
import '../controllers/offers_controller.dart';

/// Dependency injection binding for Offers screen.
class OffersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OffersController>()) {
      Get.lazyPut<OffersController>(() => OffersController());
    }
  }
}

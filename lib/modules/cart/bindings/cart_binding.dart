import 'package:get/get.dart';
import '../controllers/cart_controller.dart';

/// Dependency injection binding for the Cart module.
class CartBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CartController>()) {
      Get.put<CartController>(CartController(), permanent: true);
    }
  }
}

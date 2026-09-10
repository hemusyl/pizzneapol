import 'package:get/get.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';

/// Dependency injection binding for the Checkout module.
class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CartController>()) {
      Get.lazyPut<CartController>(() => CartController());
    }
    Get.lazyPut<CheckoutController>(() => CheckoutController(
          cartController: Get.find<CartController>(),
        ));
  }
}

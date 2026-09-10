import 'package:get/get.dart';
import '../../../data/repositories/order_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/orders_controller.dart';

/// Dependency injection binding for the Orders module.
class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CartController>()) {
      Get.lazyPut<CartController>(() => CartController());
    }
    if (!Get.isRegistered<OrderRepository>()) {
      Get.lazyPut<OrderRepository>(() => OrderRepository());
    }
    Get.lazyPut<OrdersController>(() => OrdersController(
          cartController: Get.find<CartController>(),
          orderRepository: Get.find<OrderRepository>(),
        ));
  }
}

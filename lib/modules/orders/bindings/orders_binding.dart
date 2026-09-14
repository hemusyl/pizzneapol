import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/repositories/order_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/orders_controller.dart';

/// Dependency injection binding for the Orders module.
class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    final api = Get.isRegistered<ApiProvider>() ? Get.find<ApiProvider>() : null;

    if (!Get.isRegistered<CartController>()) {
      Get.lazyPut<CartController>(() => CartController());
    }
    if (!Get.isRegistered<OrderRepository>()) {
      Get.lazyPut<OrderRepository>(() => OrderRepository(apiProvider: api));
    }
    Get.lazyPut<OrdersController>(() => OrdersController(
          cartController: Get.find<CartController>(),
          orderRepository: Get.find<OrderRepository>(),
        ));
  }
}

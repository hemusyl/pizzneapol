import 'package:get/get.dart';
import '../controllers/owner_orders_controller.dart';

/// Bindings for Restaurant Owner & Kitchen Management view.
class OwnerOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OwnerOrdersController>(() => OwnerOrdersController());
  }
}

import 'package:get/get.dart';
import '../controllers/product_controller.dart';

/// Dependency injection binding for the Product Details module.
class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
  }
}

import 'package:get/get.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../controllers/home_controller.dart';
import '../controllers/location_controller.dart';

/// Dependency injection binding for the Home module.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryRepository>(() => CategoryRepository());
    Get.lazyPut<ProductRepository>(() => ProductRepository());
    Get.lazyPut<LocationController>(() => LocationController());
    Get.lazyPut<HomeController>(() => HomeController(
          categoryRepository: Get.find<CategoryRepository>(),
          productRepository: Get.find<ProductRepository>(),
        ));
  }
}

import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../controllers/home_controller.dart';
import '../controllers/location_controller.dart';

/// Dependency injection binding for the Home module.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    final api = Get.isRegistered<ApiProvider>() ? Get.find<ApiProvider>() : null;

    if (!Get.isRegistered<CategoryRepository>()) {
      Get.lazyPut<CategoryRepository>(() => CategoryRepository(apiProvider: api));
    }
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(() => ProductRepository(apiProvider: api));
    }
    if (!Get.isRegistered<LocationController>()) {
      Get.lazyPut<LocationController>(() => LocationController());
    }
    Get.lazyPut<HomeController>(() => HomeController(
          categoryRepository: Get.find<CategoryRepository>(),
          productRepository: Get.find<ProductRepository>(),
        ));
  }
}

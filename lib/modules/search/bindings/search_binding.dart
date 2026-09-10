import 'package:get/get.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../controllers/food_search_controller.dart';

/// Dependency injection binding for the Search module.
class SearchBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CategoryRepository>()) {
      Get.lazyPut<CategoryRepository>(() => CategoryRepository());
    }
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(() => ProductRepository());
    }

    Get.lazyPut<FoodSearchController>(() => FoodSearchController(
          categoryRepository: Get.find<CategoryRepository>(),
          productRepository: Get.find<ProductRepository>(),
        ));
  }
}

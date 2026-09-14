import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../controllers/food_search_controller.dart';

/// Dependency injection binding for the Search module.
class SearchBinding extends Bindings {
  @override
  void dependencies() {
    final api = Get.isRegistered<ApiProvider>() ? Get.find<ApiProvider>() : null;

    if (!Get.isRegistered<CategoryRepository>()) {
      Get.lazyPut<CategoryRepository>(() => CategoryRepository(apiProvider: api));
    }
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(() => ProductRepository(apiProvider: api));
    }

    Get.lazyPut<FoodSearchController>(() => FoodSearchController(
          categoryRepository: Get.find<CategoryRepository>(),
          productRepository: Get.find<ProductRepository>(),
        ));
  }
}

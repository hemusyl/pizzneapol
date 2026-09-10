import 'package:get/get.dart';
import '../../../data/repositories/product_repository.dart';
import '../controllers/favorite_controller.dart';

/// Dependency injection binding for Favorites screen.
class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FavoriteController>()) {
      Get.lazyPut<FavoriteController>(
        () => FavoriteController(
          productRepository: Get.isRegistered<ProductRepository>()
              ? Get.find<ProductRepository>()
              : ProductRepository(),
        ),
      );
    }
  }
}

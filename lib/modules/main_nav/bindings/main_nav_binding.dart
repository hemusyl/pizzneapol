import 'package:get/get.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../favorites/controllers/favorite_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/controllers/location_controller.dart';
import '../../offers/controllers/offers_controller.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../search/controllers/food_search_controller.dart';
import '../controllers/main_nav_controller.dart';

/// Dependency injection binding for the main navigation shell.
/// Registers API providers, data repositories, and feature controllers.
class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavController>(() => MainNavController());

    // Data Providers & Repositories
    Get.lazyPut<ApiProvider>(() => ApiProvider());
    Get.lazyPut<CategoryRepository>(() => CategoryRepository());
    Get.lazyPut<ProductRepository>(() => ProductRepository());
    Get.lazyPut<OrderRepository>(() => OrderRepository());

    if (!Get.isRegistered<LocationController>()) {
      Get.put<LocationController>(LocationController(), permanent: true);
    }

    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(() => HomeController(
            categoryRepository: Get.find<CategoryRepository>(),
            productRepository: Get.find<ProductRepository>(),
          ));
    }

    if (!Get.isRegistered<FoodSearchController>()) {
      Get.lazyPut<FoodSearchController>(() => FoodSearchController(
            categoryRepository: Get.find<CategoryRepository>(),
            productRepository: Get.find<ProductRepository>(),
          ));
    }

    if (!Get.isRegistered<OrdersController>()) {
      Get.lazyPut<OrdersController>(() => OrdersController(
            orderRepository: Get.find<OrderRepository>(),
          ));
    }

    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(() => ProfileController());
    }

    if (!Get.isRegistered<FavoriteController>()) {
      Get.lazyPut<FavoriteController>(() => FavoriteController(
            productRepository: Get.find<ProductRepository>(),
          ));
    }

    if (!Get.isRegistered<OffersController>()) {
      Get.lazyPut<OffersController>(() => OffersController());
    }
  }
}

import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../modules/cart/controllers/cart_controller.dart';
import '../../modules/favorites/controllers/favorite_controller.dart';
import '../../modules/home/controllers/location_controller.dart';
import '../../modules/profile/controllers/profile_controller.dart';
import '../../data/services/notification_service.dart';

/// Global initial bindings initialized before the app displays its first view.
/// Registers application-wide singletons.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. HTTP Client Provider for Laravel REST API
    Get.put<ApiProvider>(ApiProvider(), permanent: true);

    // 2. Data Repositories connected to live Laravel backend with offline fallback
    Get.put<CategoryRepository>(
      CategoryRepository(apiProvider: Get.find<ApiProvider>()),
      permanent: true,
    );
    Get.put<ProductRepository>(
      ProductRepository(apiProvider: Get.find<ApiProvider>()),
      permanent: true,
    );
    Get.put<OrderRepository>(
      OrderRepository(apiProvider: Get.find<ApiProvider>()),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepository(apiProvider: Get.find<ApiProvider>()),
      permanent: true,
    );

    // 3. Core App Controllers
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<LocationController>(LocationController(), permanent: true);
    Get.put<FavoriteController>(FavoriteController(), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);

    // 4. Push Notification Service
    Get.putAsync<NotificationService>(() => NotificationService().init(), permanent: true);
  }
}

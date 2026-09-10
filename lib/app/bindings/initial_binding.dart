import 'package:get/get.dart';
import '../../modules/cart/controllers/cart_controller.dart';
import '../../modules/favorites/controllers/favorite_controller.dart';
import '../../modules/home/controllers/location_controller.dart';

/// Global initial bindings initialized before the app displays its first view.
/// Registers application-wide singletons.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<LocationController>(LocationController(), permanent: true);
    Get.put<FavoriteController>(FavoriteController(), permanent: true);
  }
}

// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import '../../modules/cart/bindings/cart_binding.dart';
import '../../modules/cart/views/cart_view.dart';
import '../../modules/checkout/bindings/checkout_binding.dart';
import '../../modules/checkout/views/checkout_view.dart';
import '../../modules/favorites/bindings/favorites_binding.dart';
import '../../modules/favorites/views/favorites_view.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/main_nav/bindings/main_nav_binding.dart';
import '../../modules/main_nav/views/main_nav_view.dart';
import '../../modules/offers/bindings/offers_binding.dart';
import '../../modules/offers/views/offers_view.dart';
import '../../modules/orders/bindings/orders_binding.dart';
import '../../modules/orders/views/orders_view.dart';
import '../../modules/product/bindings/product_binding.dart';
import '../../modules/product/views/product_details_view.dart';
import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/profile/views/profile_view.dart';
import '../../modules/search/bindings/search_binding.dart';
import '../../modules/search/views/search_view.dart';
import 'app_routes.dart';

/// Centralized route registration using GetX GetPage definitions.
class AppPages {
  AppPages._();

  static const INITIAL = Routes.MAIN;

  static final routes = [
    GetPage(
      name: Routes.MAIN,
      page: () => const MainNavView(),
      binding: MainNavBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PRODUCT_DETAILS,
      page: () => const ProductDetailsView(),
      binding: ProductBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: Routes.CART,
      page: () => const CartView(),
      binding: CartBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: Routes.CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: Routes.ORDERS,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.FAVORITES,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: Routes.OFFERS,
      page: () => const OffersView(),
      binding: OffersBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}

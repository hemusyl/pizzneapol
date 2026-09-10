import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../favorites/controllers/favorite_controller.dart';

/// Controller for ProductDetailsScreen managing size selection, quantity stepper,
/// dynamic pricing, and adding customized items to the cart.
class ProductController extends GetxController {
  /// The product being viewed
  final Rxn<ProductModel> product = Rxn<ProductModel>();

  /// Selected size (default 'Medium')
  final RxString selectedSize = 'Medium'.obs;

  /// Quantity to add
  final RxInt quantity = 1.obs;

  /// Favorite toggle state
  final RxBool isFavorite = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Retrieve product passed as navigation arguments
    if (Get.arguments is ProductModel) {
      final p = Get.arguments as ProductModel;
      product.value = p;
      if (Get.isRegistered<FavoriteController>()) {
        isFavorite.value = Get.find<FavoriteController>().isFavorite(p.id);
      } else {
        isFavorite.value = p.isFavorite;
      }
      if (p.sizes.isNotEmpty) {
        selectedSize.value = p.sizes.contains('Medium') ? 'Medium' : p.sizes.first;
      }
    }
  }

  /// Calculates unit price according to selected size
  double get unitPrice {
    final base = product.value?.price ?? 0.0;
    switch (selectedSize.value) {
      case 'Small':
        return base > 3 ? base - 2.0 : base;
      case 'Large':
        return base + 3.0;
      case 'Medium':
      default:
        return base;
    }
  }

  /// Total calculated price for the chosen size and quantity
  double get totalPrice => unitPrice * quantity.value;

  /// Updates the chosen size
  void selectSize(String size) {
    selectedSize.value = size;
  }

  /// Increments quantity
  void incrementQuantity() {
    quantity.value++;
  }

  /// Decrements quantity (minimum 1)
  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  /// Toggles favorite status
  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    if (Get.isRegistered<FavoriteController>() && product.value != null) {
      final favController = Get.find<FavoriteController>();
      if (isFavorite.value != favController.isFavorite(product.value!.id)) {
        favController.toggleFavorite(product.value!);
      }
    }
  }

  /// Adds configured product to cart and returns to previous screen
  void addToCart() {
    if (product.value == null) return;

    final cartController = Get.find<CartController>();
    cartController.addToCart(
      product.value!,
      size: selectedSize.value,
      quantity: quantity.value,
    );

    if (Get.context != null && Navigator.canPop(Get.context!)) {
      Get.back();
    }
  }
}

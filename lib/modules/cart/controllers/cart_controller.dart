import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/product_model.dart';

/// Central controller managing the user's shopping cart.
/// Injected globally so any screen or card can add items and react to changes.
class CartController extends GetxController {
  /// Observable list of cart items
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  /// Fixed delivery fee ($3.00 as specified in the screenshot/prompt)
  final RxDouble deliveryFee = 3.00.obs;

  /// Promotional discount
  final RxDouble discount = 0.00.obs;

  /// Total count of items in the cart
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal calculation
  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Final total calculation (subtotal + deliveryFee - discount)
  double get total {
    if (cartItems.isEmpty) return 0.0;
    final totalAmount = subtotal + deliveryFee.value - discount.value;
    return totalAmount > 0 ? totalAmount : 0.0;
  }

  /// Adds a product to cart or increments quantity if already present
  void addToCart(ProductModel product, {String size = 'Medium', int quantity = 1}) {
    final existingIndex = cartItems.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == size,
    );

    if (existingIndex != -1) {
      cartItems[existingIndex].quantity += quantity;
      cartItems.refresh();
    } else {
      cartItems.add(
        CartItemModel(
          product: product,
          selectedSize: size,
          quantity: quantity,
        ),
      );
    }

    // Modern feedback snackbar (only when UI context is mounted)
    if (Get.context != null) {
      Get.rawSnackbar(
        title: 'Added to Cart',
        message: '${product.name} ($size) added!',
        backgroundColor: AppColors.textPrimary,
        icon: const Icon(Icons.check_circle, color: AppColors.primary),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(milliseconds: 1600),
        animationDuration: const Duration(milliseconds: 300),
      );
    }
  }

  /// Increments quantity of an existing item
  void increaseQuantity(CartItemModel item) {
    item.quantity++;
    cartItems.refresh();
  }

  /// Decrements quantity or removes if quantity reaches 0
  void decreaseQuantity(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
    } else {
      removeFromCart(item);
    }
  }

  /// Removes an item from the cart
  void removeFromCart(CartItemModel item) {
    cartItems.remove(item);
  }

  /// Clears all items from the cart
  void clearCart() {
    cartItems.clear();
  }
}

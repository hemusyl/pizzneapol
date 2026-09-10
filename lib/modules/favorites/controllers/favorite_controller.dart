import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

/// Controller managing user bookmarked/favorite pizzas.
/// Provides reactive state for favorite toggling, counting, and instant cart dispatch.
class FavoriteController extends GetxController {
  final ProductRepository? productRepository;
  final bool autoLoad;

  FavoriteController({
    this.productRepository,
    this.autoLoad = true,
  });

  /// Observable list of favorite products
  final RxList<ProductModel> favorites = <ProductModel>[].obs;

  /// Loading indicator
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (autoLoad) {
      loadFavorites();
    }
  }

  /// Initial load of favorite products
  Future<void> loadFavorites() async {
    if (favorites.isNotEmpty) return;

    try {
      isLoading.value = true;
      ProductRepository repo;
      if (productRepository != null) {
        repo = productRepository!;
      } else if (Get.isRegistered<ProductRepository>()) {
        repo = Get.find<ProductRepository>();
      } else {
        repo = ProductRepository();
      }

      final allProducts = await repo.getProducts();
      final initialFavs = allProducts.where((p) => p.isFavorite).toList();
      if (initialFavs.isNotEmpty) {
        favorites.assignAll(initialFavs);
      }
    } catch (_) {
      // Fallback: favorites remain empty
    } finally {
      isLoading.value = false;
    }
  }

  /// Checks if a product is in favorites
  bool isFavorite(int productId) {
    return favorites.any((item) => item.id == productId);
  }

  /// Toggles favorite status for a given product
  void toggleFavorite(ProductModel product) {
    if (isFavorite(product.id)) {
      favorites.removeWhere((item) => item.id == product.id);
      _showSnackbar(
        title: 'Removed from Favorites',
        message: '${product.name} removed from your saved list.',
        icon: Icons.favorite_border_rounded,
        iconColor: AppColors.textSecondary,
      );
    } else {
      final favProduct = product.copyWith(isFavorite: true);
      favorites.add(favProduct);
      _showSnackbar(
        title: 'Added to Favorites',
        message: '${product.name} saved to your favorites!',
        icon: Icons.favorite_rounded,
        iconColor: AppColors.heartRed,
      );
    }
  }

  /// Removes a product by ID
  void removeFavorite(int productId) {
    final index = favorites.indexWhere((item) => item.id == productId);
    if (index != -1) {
      final name = favorites[index].name;
      favorites.removeAt(index);
      _showSnackbar(
        title: 'Removed from Favorites',
        message: '$name removed from your saved list.',
        icon: Icons.favorite_border_rounded,
        iconColor: AppColors.textSecondary,
      );
    }
  }

  /// Clears all favorites
  void clearFavorites() {
    favorites.clear();
  }

  /// Total count of favorite items
  int get favoriteCount => favorites.length;

  /// Helper to show safe feedback snackbar when UI context is available
  void _showSnackbar({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    if (Get.context != null && !Get.testMode) {
      Get.rawSnackbar(
        title: title,
        message: message,
        backgroundColor: AppColors.textPrimary,
        icon: Icon(icon, color: iconColor, size: 22),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 2),
      );
    }
  }
}

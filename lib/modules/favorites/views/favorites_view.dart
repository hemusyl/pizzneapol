import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../widgets/food_image_view.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../main_nav/controllers/main_nav_controller.dart';
import '../controllers/favorite_controller.dart';

/// FavoritesView screen displaying all bookmarked Neapolitan pizzas and dishes.
/// Features one-tap removal, quick add to cart, and smooth navigation to product details.
class FavoritesView extends GetView<FavoriteController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered if opened directly
    final favController = Get.isRegistered<FavoriteController>()
        ? Get.find<FavoriteController>()
        : Get.put(FavoriteController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else if (Get.isRegistered<MainNavController>()) {
              Get.find<MainNavController>().changeTab(0);
            }
          },
        ),
        title: const Text(
          'My Favorites',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            if (favController.favorites.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textSecondary,
                size: 24,
              ),
              tooltip: 'Clear all favorites',
              onPressed: () => _confirmClearAll(context, favController),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (favController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (favController.favorites.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header summary count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${favController.favoriteCount} ${favController.favoriteCount == 1 ? 'pizza' : 'pizzas'} saved',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Text(
                    'Tap heart to remove',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Vertical list of favorite items
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24.0),
                itemCount: favController.favorites.length,
                itemBuilder: (context, index) {
                  final product = favController.favorites[index];
                  return _buildFavoriteCard(context, product, favController);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Empty state when no favorite pizzas exist
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.primaryPeach,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Explore our delicious handcrafted Neapolitan pizzas and tap the heart icon on any card to save your top picks!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Get.back();
                } else if (Get.isRegistered<MainNavController>()) {
                  Get.find<MainNavController>().changeTab(0);
                }
              },
              icon: const Icon(Icons.local_pizza_rounded, size: 20),
              label: const Text(
                'Explore Menu',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Individual card for a favorite product
  Widget _buildFavoriteCard(
    BuildContext context,
    ProductModel product,
    FavoriteController favController,
  ) {
    final cartController =
        Get.isRegistered<CartController>() ? Get.find<CartController>() : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          onTap: () {
            Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.borderLight.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Circular Food Image
                FoodImageView(
                  imagePath: product.image,
                  size: 96,
                  categoryName: product.categoryName,
                  productName: product.name,
                  isCircular: true,
                ),
                const SizedBox(width: 14),

                // 2. Center Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title & Favorite Heart Button Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => favController.removeFavorite(product.id),
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.favorite_rounded,
                                color: AppColors.heartRed,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Description
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price and "+ ADD" button row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (cartController != null)
                            InkWell(
                              onTap: () {
                                cartController.addToCart(product);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'ADD',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Dialog confirmation before clearing all favorites
  void _confirmClearAll(BuildContext context, FavoriteController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear Favorites?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to remove all saved pizzas from your favorites?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearFavorites();
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

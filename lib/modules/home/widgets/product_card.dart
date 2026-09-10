import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../widgets/food_image_view.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../favorites/controllers/favorite_controller.dart';

/// Product card matching the screenshot:
/// - Left: Large circular pizza image (95-105px)
/// - Right:
///   - Bold product name & favorite heart toggle
///   - 2-line ingredients/description
///   - Bold price ($12)
///   - Orange "+ ADD" button
class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final favController =
        Get.isRegistered<FavoriteController>() ? Get.find<FavoriteController>() : null;

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
                // 1. LEFT: Circular Food / Pizza Image
                FoodImageView(
                  imagePath: product.image,
                  size: 102,
                  categoryName: product.categoryName,
                  productName: product.name,
                  isCircular: true,
                ),
                const SizedBox(width: 14),

                // 2. RIGHT: Content column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Product Title & Favorite Heart Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (favController != null)
                            Obx(() {
                              final isFav = favController.isFavorite(product.id);
                              return InkWell(
                                onTap: () => favController.toggleFavorite(product),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Icon(
                                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    size: 20,
                                    color: isFav
                                        ? AppColors.heartRed
                                        : AppColors.textSecondary.withValues(alpha: 0.5),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Description
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.28,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Price and "+ ADD" button row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price in bold
                          Text(
                            '\$${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          // Orange "+ ADD" button
                          InkWell(
                            onTap: () {
                              cartController.addToCart(product);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
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
                                    size: 16,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'ADD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
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
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/home_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/category_item.dart';
import '../widgets/home_header.dart';
import '../widgets/location_bar.dart';
import '../widgets/product_card.dart';

/// Main Home screen closely matching the reference screenshot:
/// - Custom Header with Hamburger Menu, Logo badge, and "DELIVERY ▾"
/// - Dynamic Location Bar (#FFF2E8 peach background, orange text and pin)
/// - Horizontal Categories list (Pizza, Salad, Dessert, Sides, Drinks) with selected card highlight
/// - Vertical Products ListView with circular pizza pictures, descriptions, price, and "+ ADD" button
/// - Full reactive GetX integration (Obx) with loading and error states
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.refreshHomeData(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // 1. Fixed Header Section (Menu, Logo, Delivery type)
              SliverToBoxAdapter(
                child: HomeHeader(
                  onMenuPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
              ),

              // 2. Dynamic Location Bar ("29 Hola street, California, USA")
              const SliverToBoxAdapter(
                child: LocationBar(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 12),
              ),

              // 3. Horizontal Food Categories Section
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.categories.isEmpty && controller.isLoading.value) {
                    return const SizedBox(
                      height: 110,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: controller.categories.length,
                      itemBuilder: (context, index) {
                        final category = controller.categories[index];
                        final isSelected = controller.selectedCategory.value?.id == category.id;

                        return CategoryItem(
                          category: category,
                          isSelected: isSelected,
                          onTap: () => controller.selectCategory(category),
                        );
                      },
                    ),
                  );
                }),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),

              // 4. Vertical Product List Section
              Obx(() {
                if (controller.isLoading.value && controller.allProducts.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                            const SizedBox(height: 12),
                            Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => controller.refreshHomeData(),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (controller.filteredProducts.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu, size: 56, color: AppColors.textLight),
                            SizedBox(height: 12),
                            Text(
                              'No products found in this category',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = controller.filteredProducts[index];
                        return ProductCard(product: product);
                      },
                      childCount: controller.filteredProducts.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

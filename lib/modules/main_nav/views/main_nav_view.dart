import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/views/cart_view.dart';
import '../../home/views/home_view.dart';
import '../../orders/views/orders_view.dart';
import '../../profile/views/profile_view.dart';
import '../../search/views/search_view.dart';
import '../controllers/main_nav_controller.dart';

/// Persistent Main Shell with 5-tab BottomNavigationBar:
/// 1. Home
/// 2. Search
/// 3. Cart (with reactive item counter badge)
/// 4. Orders
/// 5. Profile
class MainNavView extends GetView<MainNavController> {
  const MainNavView({super.key});

  static const List<Widget> _screens = [
    HomeView(),
    SearchView(),
    CartView(),
    OrdersView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: controller.currentIndex.value,
          children: _screens,
        );
      }),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Obx(() {
            return BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: (index) => controller.changeTab(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded),
                  activeIcon: Icon(Icons.search_rounded),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: _buildCartBadge(cartController, isActive: false),
                  activeIcon: _buildCartBadge(cartController, isActive: true),
                  label: 'Cart',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long_rounded),
                  label: 'Orders',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Reactive cart icon with animated numeric badge
  Widget _buildCartBadge(CartController cartController, {required bool isActive}) {
    return Obx(() {
      final count = cartController.itemCount;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            isActive ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined,
            size: 24,
          ),
          if (count > 0)
            Positioned(
              right: -8,
              top: -6,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: 1.0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

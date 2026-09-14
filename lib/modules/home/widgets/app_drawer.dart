import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../profile/controllers/profile_controller.dart';

/// Navigation Drawer opened by the hamburger menu icon
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Profile Header
          Obx(() {
            final profileCtrl = Get.isRegistered<ProfileController>()
                ? Get.find<ProfileController>()
                : null;
            final user = profileCtrl?.user.value;
            final name = user != null && user.name.isNotEmpty ? user.name : 'Pizza Guest';
            final email = user != null && (user.email.isNotEmpty || user.phone.isNotEmpty)
                ? (user.email.isNotEmpty ? user.email : user.phone)
                : 'Tap to Sign In / Register';

            return UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              onDetailsPressed: () {
                Get.back();
                Get.toNamed(Routes.LOGIN);
              },
              currentAccountPicture: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.person,
                  size: 45,
                  color: AppColors.primary,
                ),
              ),
              accountName: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: Text(
                email,
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }),

          // Drawer Links
          _drawerItem(
            icon: Icons.home_rounded,
            title: 'Home',
            onTap: () => Get.back(),
          ),
          _drawerItem(
            icon: Icons.category_rounded,
            title: 'Categories',
            onTap: () {
              Get.back();
              // Scroll to categories or open categories
            },
          ),
          _drawerItem(
            icon: Icons.receipt_long_rounded,
            title: 'My Orders',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.ORDERS);
            },
          ),
          _drawerItem(
            icon: Icons.shopping_bag_rounded,
            title: 'Cart',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.CART);
            },
          ),
          _drawerItem(
            icon: Icons.local_offer_rounded,
            title: 'Offers & Deals',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.OFFERS);
            },
          ),
          _drawerItem(
            icon: Icons.favorite_rounded,
            title: 'Favorites',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.FAVORITES);
            },
          ),
          const Divider(color: AppColors.divider),
          _drawerItem(
            icon: Icons.settings_rounded,
            title: 'Settings',
            onTap: () {
              Get.back();
              Get.toNamed(Routes.PROFILE);
            },
          ),
          _drawerItem(
            icon: Icons.info_outline_rounded,
            title: 'About Pizzneapol',
            onTap: () {
              Get.back();
              Get.defaultDialog(
                title: 'PIZZNEAPOL PIZZA',
                middleText: 'Modern Pizza Ordering App built with Flutter & GetX.',
                confirmTextColor: Colors.white,
                buttonColor: AppColors.primary,
                onConfirm: () => Get.back(),
              );
            },
          ),
          Obx(() {
            final profileCtrl = Get.isRegistered<ProfileController>()
                ? Get.find<ProfileController>()
                : null;
            final isLoggedIn = profileCtrl?.isLoggedIn ?? false;

            if (!isLoggedIn) {
              return _drawerItem(
                icon: Icons.login_rounded,
                title: 'Sign In / Register',
                textColor: AppColors.primary,
                iconColor: AppColors.primary,
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.LOGIN);
                },
              );
            }

            return _drawerItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              textColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () {
                Get.back();
                if (Get.isRegistered<AuthRepository>()) {
                  Get.find<AuthRepository>().logout();
                }
                if (Get.isRegistered<ProfileController>()) {
                  Get.find<ProfileController>().signOut();
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = AppColors.textPrimary,
    Color iconColor = AppColors.primary,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
        ),
      ),
      onTap: onTap,
    );
  }
}

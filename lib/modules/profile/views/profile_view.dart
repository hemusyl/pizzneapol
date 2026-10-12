import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/notification_service.dart';
import '../../main_nav/controllers/main_nav_controller.dart';
import '../controllers/profile_controller.dart';

/// User profile and account management view.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Header Card
            _buildProfileHeader(context),
            const SizedBox(height: 20),

            // Restaurant Management Section (Visible for owners or when Owner Mode is enabled)
            Obx(() {
              if (_controller.canAccessOwnerDashboard) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('RESTAURANT MANAGEMENT'),
                    const SizedBox(height: 8),
                    _buildOwnerDashboardCard(context),
                    const SizedBox(height: 20),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // 2. Account Section
            _buildSectionHeader('ACCOUNT'),
            const SizedBox(height: 8),
            _buildAccountOptions(context),
            const SizedBox(height: 20),

            // 3. App Preferences Section
            _buildSectionHeader('PREFERENCES'),
            const SizedBox(height: 8),
            _buildPreferencesCard(),
            const SizedBox(height: 20),

            // 4. Support & Info Section
            _buildSectionHeader('SUPPORT & ABOUT'),
            const SizedBox(height: 8),
            _buildSupportCard(context),
            const SizedBox(height: 24),

            // 5. Sign Out Button
            _buildSignOutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Profile info header card with avatar and edit button
  Widget _buildProfileHeader(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Obx(() {
          final user = _controller.user.value;
          final isLoggedIn = user != null;
          final name = isLoggedIn ? user.name : 'Guest User';
          final email = isLoggedIn ? user.email : 'Sign in to access your account & orders';
          final phone = isLoggedIn
              ? (user.address.isNotEmpty ? user.address : user.phone)
              : 'Tap to sign in / register';
          final initials = isLoggedIn && user.name.isNotEmpty
              ? user.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join()
              : 'G';

          return Row(
            children: [
              // User Avatar with Peach tint & Orange border
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryPeach,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Center(
                  child: isLoggedIn
                      ? Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(
                          Icons.person_outline_rounded,
                          size: 32,
                          color: AppColors.primary,
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Name, Email, Phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              // Action button (Edit if logged in, Login if guest)
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPeach,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isLoggedIn ? Icons.edit_rounded : Icons.login_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                onPressed: () {
                  if (isLoggedIn) {
                    _showEditProfileDialog(context);
                  } else {
                    Get.toNamed(Routes.LOGIN);
                  }
                },
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// Account management options card
  Widget _buildAccountOptions(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            _menuTile(
              icon: Icons.location_on_outlined,
              title: 'Saved Addresses',
              subtitle: 'Manage home, office & delivery spots',
              onTap: () => _showSavedAddressesDialog(context),
            ),
            const Divider(height: 1, indent: 56, color: AppColors.divider),
            _menuTile(
              icon: Icons.credit_card_outlined,
              title: 'Payment Methods',
              subtitle: 'Cards, wallets & payment options',
              onTap: () => _showPaymentMethodsDialog(context),
            ),
            const Divider(height: 1, indent: 56, color: AppColors.divider),
            _menuTile(
              icon: Icons.receipt_long_outlined,
              title: 'My Orders',
              subtitle: 'View ongoing deliveries & past receipts',
              onTap: () {
                if (Get.isRegistered<MainNavController>()) {
                  Get.find<MainNavController>().changeTab(3); // Orders tab
                }
              },
            ),
            const Divider(height: 1, indent: 56, color: AppColors.divider),
            _menuTile(
              icon: Icons.favorite_border_rounded,
              title: 'My Favorites',
              subtitle: 'Bookmarked Neapolitan pizzas & treats',
              onTap: () => Get.toNamed(Routes.FAVORITES),
            ),
            const Divider(height: 1, indent: 56, color: AppColors.divider),
            _menuTile(
              icon: Icons.local_offer_outlined,
              title: 'Offers & Promos',
              subtitle: 'Discount vouchers and exclusive deals',
              onTap: () => Get.toNamed(Routes.OFFERS),
            ),
          ],
        ),
      ),
    );
  }

  /// App notification & SMS preferences
  Widget _buildPreferencesCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Obx(() {
          return Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Daily deals & order delivery updates', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                value: _controller.pushNotifications.value,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primaryPeach,
                onChanged: (val) => _controller.togglePushNotifications(val),
              ),
              const Divider(height: 1, indent: 56, color: AppColors.divider),
              SwitchListTile(
                secondary: const Icon(Icons.sms_outlined, color: AppColors.primary),
                title: const Text('Order Status Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Driver arrival & oven status alerts', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                value: _controller.orderAlerts.value,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primaryPeach,
                onChanged: (val) => _controller.toggleOrderAlerts(val),
              ),
              const Divider(height: 1, indent: 56, color: AppColors.divider),
              SwitchListTile(
                secondary: const Icon(Icons.local_offer_outlined, color: AppColors.primary),
                title: const Text('Special Offers & Discounts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Promotional coupons & weekend combos', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                value: _controller.specialOffers.value,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primaryPeach,
                onChanged: (val) => _controller.toggleSpecialOffers(val),
              ),
              const Divider(height: 1, indent: 56, color: AppColors.divider),
              SwitchListTile(
                secondary: const Icon(Icons.storefront_outlined, color: AppColors.primary),
                title: const Text('Restaurant Owner Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Enable kitchen management & order dispatch', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                value: _controller.isOwnerMode.value,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primaryPeach,
                onChanged: (val) => _controller.toggleOwnerMode(val),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Support & Legal Card
  Widget _buildSupportCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            _menuTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & FAQ',
              subtitle: 'Frequently asked questions & customer care',
              onTap: () {
                Get.snackbar(
                  'Customer Support',
                  'Reach us at support@pizzneapol.com or call 1-800-PIZZA',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: const Color(0xFFF36C0A),
                  colorText: Colors.white,
                );
              },
            ),
            const Divider(height: 1, indent: 56, color: AppColors.divider),
            _menuTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy & Terms',
              subtitle: 'Data usage & terms of service',
              onTap: () {
                Get.snackbar(
                  'Legal Terms',
                  'PIZZNEAPOL PIZZA • All rights reserved 2026',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.grey.shade800,
                  colorText: Colors.white,
                );
              },
            ),
            const Divider(height: 1, indent: 56, color: AppColors.divider),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
              title: const Text('FCM Device Token', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('Tap to copy device push token for Firebase testing', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              trailing: const Icon(Icons.copy_rounded, size: 18, color: AppColors.textSecondary),
              onTap: () {
                final fcmService = Get.isRegistered<NotificationService>()
                    ? Get.find<NotificationService>()
                    : null;
                final token = fcmService?.fcmToken.value;
                if (token != null && token.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: token));
                  Get.snackbar(
                    'FCM Token Copied!',
                    'Device token copied to clipboard for Firebase Console testing.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green.shade700,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 4),
                  );
                } else {
                  Get.snackbar(
                    'Token Not Available',
                    'Waiting for FCM token generation from Google Play Services.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.orange.shade800,
                    colorText: Colors.white,
                  );
                }
              },
            ),
            const Divider(height: 1, indent: 56, color: AppColors.divider),
            const ListTile(
              leading: Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
              title: Text('App Version', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              trailing: Text('v1.0.0 (Step 14)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  /// Restaurant Owner & Kitchen Management Card
  Widget _buildOwnerDashboardCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.primaryPeach,
              child: Row(
                children: [
                  const Icon(Icons.local_pizza_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Kitchen & Orders Dashboard',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'OWNER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.soup_kitchen_outlined, color: AppColors.primary),
              title: const Text(
                'Live Kitchen Order Manager',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: const Text(
                'Accept orders, advance oven stages & trigger push notifications',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
              onTap: () => Get.toNamed(Routes.OWNER_ORDERS),
            ),
          ],
        ),
      ),
    );
  }

  /// Sign in and sign out buttons
  Widget _buildSignOutButton(BuildContext context) {
    return Obx(() {
      final isLoggedIn = _controller.isLoggedIn;
      if (!isLoggedIn) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed(Routes.LOGIN),
            icon: const Icon(Icons.login_rounded, color: Colors.white),
            label: const Text(
              'Sign In / Create Account',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
        );
      }

      return SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () => _showSignOutConfirmDialog(context),
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          label: const Text(
            'Sign Out',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    });
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.primaryPeach,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  /// Edit Profile Dialog
  void _showEditProfileDialog(BuildContext context) {
    final currentUser = _controller.user.value;
    final nameController = TextEditingController(text: currentUser?.name ?? '');
    final phoneController = TextEditingController(text: currentUser?.phone ?? '');
    final emailController = TextEditingController(text: currentUser?.email ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                _controller.updateProfile(
                  name: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// Saved Addresses modal
  void _showSavedAddressesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.home_rounded, color: AppColors.primary),
                title: Text('Home (Default)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('29 Hola street, California, USA', style: TextStyle(fontSize: 12)),
              ),
              Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.work_outline_rounded, color: AppColors.primary),
                title: Text('Office', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('742 Evergreen Terrace, Springfield', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// Payment Methods modal
  void _showPaymentMethodsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.credit_card_rounded, color: AppColors.primary),
                title: Text('Visa ending in 4242', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('Expires 08/28 • Default', style: TextStyle(fontSize: 12)),
              ),
              Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.payments_rounded, color: AppColors.primary),
                title: Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('Pay at your door', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// Sign out confirmation modal
  void _showSignOutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to sign out of your PIZZNEAPOL PIZZA account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (Get.isRegistered<AuthRepository>()) {
                  Get.find<AuthRepository>().logout();
                }
                _controller.signOut();
                Get.toNamed(Routes.LOGIN);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

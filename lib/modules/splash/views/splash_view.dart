import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/splash_controller.dart';

/// Splash Screen view shown on app launch.
class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Obx(() {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              opacity: controller.opacity.value,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                scale: controller.scale.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Logo Icon Badge
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPeach,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_pizza_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App Title
                    const Text(
                      'PIZZNEAPOL',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle / Tagline
                    const Text(
                      'Authentic Neapolitan Pizza',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Loading indicator
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),

                    const Spacer(),

                    // Footer
                    const Text(
                      'Wood-Fired • Fresh Ingredients • Fast Delivery',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

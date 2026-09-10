import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/offer_model.dart';
import '../../main_nav/controllers/main_nav_controller.dart';
import '../controllers/offers_controller.dart';

/// OffersView screen displaying promotional vouchers, coupons, and discount codes.
/// Allows instant code copying, visual feedback, and direct checkout application.
class OffersView extends GetView<OffersController> {
  const OffersView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    final offersController = Get.isRegistered<OffersController>()
        ? Get.find<OffersController>()
        : Get.put(OffersController());

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
          'Offers & Promos',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Promotional Header Banner
            _buildPromoBanner(),
            const SizedBox(height: 20),

            // 2. Section Title
            Obx(() => Text(
                  'Available Deals (${offersController.offers.length})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                )),
            const SizedBox(height: 12),

            // 3. List of Voucher Cards
            Obx(() {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: offersController.offers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final offer = offersController.offers[index];
                  return _buildVoucherCard(context, offer, offersController);
                },
              );
            }),

            const SizedBox(height: 24),

            // 4. How to Redeem Help Section
            _buildHowToRedeemGuide(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Top hero banner introducing pizza discounts
  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFFE05A00),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_offer_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'PIZZNEAPOL REWARDS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Save Big on Every Slice!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Copy voucher codes below and paste them at checkout to enjoy discounts on authentic wood-fired Neapolitan pizzas.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// Individual voucher ticket card
  Widget _buildVoucherCard(
    BuildContext context,
    OfferModel offer,
    OffersController controller,
  ) {
    final accentColor = Color(offer.bannerColor);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Tag & Validity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offer.tag,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      offer.validUntil,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Row 2: Discount highlight + Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Discount Badge Box
                Container(
                  width: 80,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPeach,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      offer.discountText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title, Description, Min spend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        offer.minSpend,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Divider with perforated / dashed aesthetic
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),

            // Row 3: Promo code pill & Action buttons
            Row(
              children: [
                // Promo Code box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    offer.promoCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Spacer(),

                // Copy Code Button
                Obx(() {
                  final isCopied = controller.copiedCode.value == offer.promoCode;
                  return OutlinedButton.icon(
                    onPressed: () => controller.copyPromoCode(offer.promoCode),
                    icon: Icon(
                      isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                      size: 15,
                      color: isCopied ? AppColors.success : AppColors.primary,
                    ),
                    label: Text(
                      isCopied ? 'COPIED' : 'COPY',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isCopied ? AppColors.success : AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isCopied ? AppColors.success : AppColors.primary,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  );
                }),
                const SizedBox(width: 8),

                // Use Now Button
                ElevatedButton(
                  onPressed: () => controller.useOffer(offer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  ),
                  child: const Text(
                    'USE NOW',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Step-by-step voucher guide card
  Widget _buildHowToRedeemGuide() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'How to Redeem Vouchers',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _guideStep(1, 'Tap "COPY" on any coupon voucher above.'),
            _guideStep(2, 'Add your favorite Neapolitan pizzas to the cart.'),
            _guideStep(3, 'On the Checkout screen, paste the code into the Promo Box and tap "APPLY".'),
          ],
        ),
      ),
    );
  }

  Widget _guideStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.primaryPeach,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

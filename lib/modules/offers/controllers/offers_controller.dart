import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/offer_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../checkout/controllers/checkout_controller.dart';

/// Controller managing promotional offers, deals, and coupon codes.
class OffersController extends GetxController {
  /// List of active offers & deals
  final RxList<OfferModel> offers = <OfferModel>[].obs;

  /// Most recently copied promo code
  final RxString copiedCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOffers();
  }

  /// Populates available offers
  void loadOffers() {
    offers.assignAll(OfferModel.defaultOffers);
  }

  /// Copies promo code to system clipboard and provides feedback
  Future<void> copyPromoCode(String code) async {
    copiedCode.value = code;
    await Clipboard.setData(ClipboardData(text: code));

    if (Get.context != null && !Get.testMode) {
      Get.rawSnackbar(
        title: 'Code Copied!',
        message: 'Promo code "$code" copied to clipboard.',
        backgroundColor: AppColors.textPrimary,
        icon: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Applies code and directs user to checkout or menu
  void useOffer(OfferModel offer) {
    copyPromoCode(offer.promoCode);

    final cartController =
        Get.isRegistered<CartController>() ? Get.find<CartController>() : null;

    if (cartController != null && cartController.cartItems.isNotEmpty) {
      if (Get.isRegistered<CheckoutController>()) {
        Get.find<CheckoutController>().applyPromoCode(offer.promoCode);
      }
      Get.toNamed(Routes.CHECKOUT);
    } else {
      Get.toNamed(Routes.MAIN);
    }
  }
}

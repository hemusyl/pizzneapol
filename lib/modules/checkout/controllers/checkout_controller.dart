import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/payment_method.dart';
import '../../../data/repositories/order_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../home/controllers/location_controller.dart';
import '../../orders/controllers/orders_controller.dart';

/// Controller handling address selection, promo codes, payment methods,
/// and order checkout placement.
class CheckoutController extends GetxController {
  final CartController cartController;

  CheckoutController({CartController? cartController})
      : cartController = cartController ??
            (Get.isRegistered<CartController>()
                ? Get.find<CartController>()
                : Get.put(CartController()));

  /// Observable list of saved addresses
  final RxList<AddressModel> savedAddresses = <AddressModel>[
    const AddressModel(
      id: 1,
      label: 'Home',
      addressLine: '29 Hola street, California, USA',
      city: 'California',
      zipCode: '90001',
      contactPhone: '+1 (555) 234-5678',
      isDefault: true,
    ),
    const AddressModel(
      id: 2,
      label: 'Office',
      addressLine: '742 Evergreen Terrace, Springfield',
      city: 'Springfield',
      zipCode: '97477',
      contactPhone: '+1 (555) 876-5432',
      isDefault: false,
    ),
    const AddressModel(
      id: 3,
      label: 'Beach House',
      addressLine: '100 Ocean Drive, Santa Monica, CA',
      city: 'Santa Monica',
      zipCode: '90401',
      contactPhone: '+1 (555) 345-6789',
      isDefault: false,
    ),
  ].obs;

  /// Currently selected delivery address
  late final Rx<AddressModel> selectedAddress = savedAddresses.firstWhere(
    (a) => a.isDefault,
    orElse: () => savedAddresses.first,
  ).obs;

  /// Selected payment method
  final Rx<PaymentMethodType> selectedPaymentMethod =
      PaymentMethodType.cashOnDelivery.obs;

  /// Promo code status
  final RxString appliedPromoCode = ''.obs;
  final RxDouble promoDiscountAmount = 0.0.obs;

  /// Delivery instructions / note
  final RxString deliveryNotes = ''.obs;

  /// Loading state for order placement
  final RxBool isPlacingOrder = false.obs;

  /// Most recently placed order
  final Rxn<OrderModel> lastPlacedOrder = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    // Sync with LocationController if registered
    if (Get.isRegistered<LocationController>()) {
      final locController = Get.find<LocationController>();
      if (locController.currentAddress.value.isNotEmpty) {
        selectedAddress.value = selectedAddress.value.copyWith(
          addressLine: locController.currentAddress.value,
        );
      }
    }
  }

  /// Changes the active delivery address
  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
    if (Get.isRegistered<LocationController>()) {
      Get.find<LocationController>().setAddress(address.addressLine);
    }
  }

  /// Adds a new address to the saved addresses list
  void addNewAddress(AddressModel newAddress) {
    savedAddresses.add(newAddress);
    selectAddress(newAddress);
  }

  /// Changes the payment method
  void selectPaymentMethod(PaymentMethodType type) {
    selectedPaymentMethod.value = type;
  }

  /// Updates delivery notes
  void updateDeliveryNotes(String notes) {
    deliveryNotes.value = notes;
  }

  /// Subtotal from cart
  double get subtotal => cartController.subtotal;

  /// Calculated delivery fee (waived if FREESHIP promo applied)
  double get deliveryFee {
    if (appliedPromoCode.value == 'FREESHIP') {
      return 0.0;
    }
    return cartController.deliveryFee.value;
  }

  /// Total discount (promo code + any cart discount)
  double get totalDiscount =>
      cartController.discount.value + promoDiscountAmount.value;

  /// Grand total calculation
  double get grandTotal {
    final rawTotal = subtotal + deliveryFee - totalDiscount;
    return max(0.0, rawTotal);
  }

  /// Applies a promo code with immediate discount calculation
  bool applyPromoCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return false;

    if (cleanCode == 'PIZZA20') {
      appliedPromoCode.value = cleanCode;
      promoDiscountAmount.value = subtotal * 0.20;
      _showFeedbackSnackbar(
        title: 'Promo Applied!',
        message: '20% discount applied to your order (-\$${promoDiscountAmount.value.toStringAsFixed(2)})',
        isError: false,
      );
      return true;
    } else if (cleanCode == 'FREESHIP') {
      appliedPromoCode.value = cleanCode;
      promoDiscountAmount.value = 0.0; // Delivery fee becomes 0 directly
      _showFeedbackSnackbar(
        title: 'Free Delivery Applied!',
        message: 'Delivery fee of \$${cartController.deliveryFee.value.toStringAsFixed(2)} has been waived!',
        isError: false,
      );
      return true;
    } else if (cleanCode == 'SAVE5') {
      appliedPromoCode.value = cleanCode;
      promoDiscountAmount.value = 5.0;
      _showFeedbackSnackbar(
        title: 'Promo Applied!',
        message: '\$5.00 discount applied to your order!',
        isError: false,
      );
      return true;
    } else {
      _showFeedbackSnackbar(
        title: 'Invalid Code',
        message: 'The code "$cleanCode" is invalid. Try "PIZZA20" or "FREESHIP".',
        isError: true,
      );
      return false;
    }
  }

  /// Removes currently applied promo code
  void removePromoCode() {
    appliedPromoCode.value = '';
    promoDiscountAmount.value = 0.0;
  }

  /// Places order, generates OrderModel, and clears cart
  Future<OrderModel?> placeOrder() async {
    if (cartController.cartItems.isEmpty) {
      _showFeedbackSnackbar(
        title: 'Cart is Empty',
        message: 'Please add items to your cart before checking out.',
        isError: true,
      );
      return null;
    }

    isPlacingOrder.value = true;
    try {
      // Simulate network latency (e.g., payment gateway / server verification)
      await Future.delayed(const Duration(milliseconds: 600));

      final orderId = 'PZ-${(DateTime.now().millisecondsSinceEpoch % 90000) + 10000}';
      final paymentTitle = PaymentMethodOption.availableMethods
          .firstWhere((p) => p.type == selectedPaymentMethod.value)
          .title;

      final newOrder = OrderModel(
        id: orderId,
        items: List.from(cartController.cartItems),
        deliveryAddress: selectedAddress.value.addressLine,
        paymentMethod: paymentTitle,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        discount: totalDiscount,
        total: grandTotal,
        orderDate: DateTime.now(),
        status: OrderStatus.confirmed,
        deliveryNotes: deliveryNotes.value.isNotEmpty ? deliveryNotes.value : null,
      );

      lastPlacedOrder.value = newOrder;

      // Add to OrdersController / OrderRepository
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().addOrder(newOrder);
      } else if (Get.isRegistered<OrderRepository>()) {
        Get.find<OrderRepository>().createOrder(newOrder);
      }

      // Clear the cart
      cartController.clearCart();

      return newOrder;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  void _showFeedbackSnackbar({
    required String title,
    required String message,
    required bool isError,
  }) {
    if (Get.context != null) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFFF36C0A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }
}

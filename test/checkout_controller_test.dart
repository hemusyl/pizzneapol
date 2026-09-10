import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/models/address_model.dart';
import 'package:pizzneapol/data/models/payment_method.dart';
import 'package:pizzneapol/data/models/product_model.dart';
import 'package:pizzneapol/modules/cart/controllers/cart_controller.dart';
import 'package:pizzneapol/modules/checkout/controllers/checkout_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testProduct1 = ProductModel(
    id: 1,
    name: 'Margarita',
    description: 'Cheese & Tomato',
    price: 12.0,
    image: 'assets/images/pizza/margherita.png',
    categoryId: 1,
    categoryName: 'Pizza',
  );

  const testProduct2 = ProductModel(
    id: 2,
    name: 'Classic Pepperoni',
    description: 'Pepperoni & Cheese',
    price: 14.0,
    image: 'assets/images/pizza/pepperoni.png',
    categoryId: 1,
    categoryName: 'Pizza',
  );

  group('CheckoutController Unit Tests', () {
    late CartController cartController;
    late CheckoutController checkoutController;

    setUp(() {
      Get.reset();
      cartController = CartController();
      checkoutController = CheckoutController(cartController: cartController);
    });

    tearDown(() {
      Get.reset();
    });

    test('Initializes with default address and cashOnDelivery payment method', () {
      expect(checkoutController.selectedAddress.value.addressLine, contains('29 Hola street'));
      expect(checkoutController.selectedPaymentMethod.value, equals(PaymentMethodType.cashOnDelivery));
      expect(checkoutController.appliedPromoCode.value, isEmpty);
      expect(checkoutController.promoDiscountAmount.value, equals(0.0));
    });

    test('selectAddress updates active delivery address', () {
      final newAddress = const AddressModel(
        id: 2,
        label: 'Office',
        addressLine: '742 Evergreen Terrace, Springfield',
      );
      checkoutController.selectAddress(newAddress);
      expect(checkoutController.selectedAddress.value.addressLine, equals('742 Evergreen Terrace, Springfield'));
    });

    test('selectPaymentMethod updates chosen payment method', () {
      checkoutController.selectPaymentMethod(PaymentMethodType.creditCard);
      expect(checkoutController.selectedPaymentMethod.value, equals(PaymentMethodType.creditCard));
    });

    test('applyPromoCode PIZZA20 calculates 20% discount on subtotal', () {
      // Add $26 of items: 12.0 + 14.0 = 26.0
      cartController.addToCart(testProduct1);
      cartController.addToCart(testProduct2);

      expect(checkoutController.subtotal, equals(26.0));
      final success = checkoutController.applyPromoCode('PIZZA20');

      expect(success, isTrue);
      expect(checkoutController.appliedPromoCode.value, equals('PIZZA20'));
      expect(checkoutController.promoDiscountAmount.value, equals(5.20)); // 26 * 0.2
      // Delivery fee is 3.0, total = 26.0 + 3.0 - 5.20 = 23.80
      expect(checkoutController.grandTotal, equals(23.80));
    });

    test('applyPromoCode FREESHIP waives delivery fee', () {
      cartController.addToCart(testProduct1); // 12.0
      expect(checkoutController.deliveryFee, equals(3.0));

      final success = checkoutController.applyPromoCode('FREESHIP');
      expect(success, isTrue);
      expect(checkoutController.deliveryFee, equals(0.0));
      expect(checkoutController.grandTotal, equals(12.0));
    });

    test('removePromoCode resets promo state', () {
      cartController.addToCart(testProduct1);
      checkoutController.applyPromoCode('SAVE5');
      expect(checkoutController.promoDiscountAmount.value, equals(5.0));

      checkoutController.removePromoCode();
      expect(checkoutController.appliedPromoCode.value, isEmpty);
      expect(checkoutController.promoDiscountAmount.value, equals(0.0));
    });

    test('placeOrder with empty cart returns null', () async {
      final order = await checkoutController.placeOrder();
      expect(order, isNull);
    });

    test('placeOrder with items creates OrderModel and clears cart', () async {
      cartController.addToCart(testProduct1, quantity: 2); // 24.0
      expect(cartController.cartItems.length, equals(1));
      expect(cartController.itemCount, equals(2));

      final order = await checkoutController.placeOrder();

      expect(order, isNotNull);
      expect(order!.id, startsWith('PZ-'));
      expect(order.items.length, equals(1));
      expect(order.subtotal, equals(24.0));
      expect(order.deliveryFee, equals(3.0));
      expect(order.total, equals(27.0));
      expect(order.deliveryAddress, contains('29 Hola street'));

      // Verify cart was cleared
      expect(cartController.cartItems.isEmpty, isTrue);
      expect(cartController.itemCount, equals(0));
      expect(checkoutController.lastPlacedOrder.value, equals(order));
    });
  });
}

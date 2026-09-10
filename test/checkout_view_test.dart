import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/models/product_model.dart';
import 'package:pizzneapol/modules/cart/controllers/cart_controller.dart';
import 'package:pizzneapol/modules/checkout/controllers/checkout_controller.dart';
import 'package:pizzneapol/modules/checkout/views/checkout_view.dart';

void main() {
  const testProduct = ProductModel(
    id: 1,
    name: 'Margarita',
    description: 'Cheese & Tomato',
    price: 12.0,
    image: 'assets/images/pizza/margherita.png',
    categoryId: 1,
    categoryName: 'Pizza',
  );

  testWidgets('CheckoutView renders sections, applies promo code, changes payment, and places order', (WidgetTester tester) async {
    Get.reset();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.reset();
      Get.reset();
    });

    // 1. Setup CartController with 2 Margarita pizzas ($24)
    final cartController = Get.put(CartController());
    cartController.addToCart(testProduct, quantity: 2);
    Get.put(CheckoutController(cartController: cartController));

    await tester.pumpWidget(const GetMaterialApp(
      home: CheckoutView(),
    ));
    await tester.pumpAndSettle();

    // 2. Verify Delivery Address Section
    expect(find.text('Delivery Address'), findsOneWidget);
    expect(find.textContaining('29 Hola street'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);

    // 3. Verify Order Items
    expect(find.text('Order Items'), findsOneWidget);
    expect(find.text('Margarita'), findsOneWidget);
    expect(find.text('2x'), findsOneWidget);
    expect(find.text('Size: Medium'), findsOneWidget);

    // 4. Verify Payment Methods
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Cash on Delivery'), findsOneWidget);
    expect(find.text('Credit / Debit Card'), findsOneWidget);

    // Tap on Credit / Debit Card
    await tester.tap(find.text('Credit / Debit Card'));
    await tester.pumpAndSettle();

    // 5. Apply Promo Code 'PIZZA20'
    final promoField = find.widgetWithText(TextField, 'Enter code (e.g. PIZZA20, FREESHIP)');
    expect(promoField, findsOneWidget);
    await tester.enterText(promoField, 'PIZZA20');
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Coupon "PIZZA20" Applied!'), findsOneWidget);

    // 6. Tap "PLACE ORDER"
    final placeOrderBtn = find.textContaining('PLACE ORDER');
    expect(placeOrderBtn, findsOneWidget);

    await tester.tap(placeOrderBtn);
    // Pump past the 600ms latency simulation
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // 7. Verify Order Placed dialog is shown
    expect(find.text('Order Placed!'), findsOneWidget);
    expect(find.textContaining('Order ID: PZ-'), findsOneWidget);
    expect(find.text('Estimated Delivery: 25 - 35 mins'), findsOneWidget);
    expect(find.text('View Orders'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
  });
}

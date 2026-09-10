import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/models/product_model.dart';
import 'package:pizzneapol/main.dart';
import 'package:pizzneapol/modules/cart/controllers/cart_controller.dart';
import 'package:pizzneapol/modules/product/controllers/product_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProductController Unit Tests', () {
    late ProductController controller;
    late CartController cartController;

    const testProduct = ProductModel(
      id: 1,
      name: 'Margherita',
      description: 'Cheese & Tomato',
      price: 12.0,
      image: 'assets/images/pizza/margherita.png',
      categoryId: 1,
      categoryName: 'Pizza',
      sizes: ['Small', 'Medium', 'Large'],
      ingredients: ['Mozzarella', 'Basil', 'Tomato'],
    );

    setUp(() {
      Get.reset();
      cartController = Get.put(CartController());
      controller = ProductController();
      controller.product.value = testProduct;
      controller.selectedSize.value = 'Medium';
      controller.quantity.value = 1;
    });

    test('Computes correct pricing per size', () {
      expect(controller.unitPrice, equals(12.0));
      expect(controller.totalPrice, equals(12.0));

      controller.selectSize('Small');
      expect(controller.unitPrice, equals(10.0));

      controller.selectSize('Large');
      expect(controller.unitPrice, equals(15.0));
    });

    test('Stepper increments and decrements quantity', () {
      controller.incrementQuantity();
      expect(controller.quantity.value, equals(2));
      expect(controller.totalPrice, equals(24.0));

      controller.decrementQuantity();
      expect(controller.quantity.value, equals(1));

      // Minimum is 1
      controller.decrementQuantity();
      expect(controller.quantity.value, equals(1));
    });

    test('addToCart adds configured item to CartController', () {
      controller.selectSize('Large');
      controller.incrementQuantity(); // quantity = 2
      controller.addToCart();

      expect(cartController.cartItems.length, equals(1));
      expect(cartController.cartItems.first.quantity, equals(2));
      expect(cartController.cartItems.first.selectedSize, equals('Large'));
    });
  });

  testWidgets('Tapping product opens ProductDetailsView with interactive size & cart button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PizzneapolApp());
    await tester.pumpAndSettle();

    // 1. Tap on the Margherita card
    final productFinder = find.text('Margarita');
    expect(productFinder, findsOneWidget);
    await tester.tap(productFinder);
    await tester.pumpAndSettle();

    // 2. Verify ProductDetailsScreen is open
    expect(find.text('Product Details'), findsOneWidget);
    expect(find.text('Select Size'), findsOneWidget);
    expect(find.text('Small'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Large'), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);

    // 3. Verify ADD TO CART button is present
    expect(find.textContaining('ADD TO CART'), findsOneWidget);
  });
}

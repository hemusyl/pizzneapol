import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/models/product_model.dart';
import 'package:pizzneapol/modules/cart/controllers/cart_controller.dart';
import 'package:pizzneapol/modules/cart/views/cart_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testProduct = ProductModel(
    id: 1,
    name: 'Margarita',
    description: 'Medium | Cheese , onion, and tomato pure',
    price: 12.0,
    image: 'assets/images/pizza/margherita.png',
    categoryId: 1,
    categoryName: 'Pizza',
  );

  group('CartController Calculation Tests', () {
    late CartController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(CartController());
    });

    test('3 Margherita pizzas calculate exact prompt example totals (\$36 + \$3 = \$39)', () {
      // Add 3 Margherita pizzas at $12 each
      controller.addToCart(testProduct, size: 'Medium', quantity: 3);

      expect(controller.itemCount, equals(3));
      expect(controller.subtotal, equals(36.00));
      expect(controller.deliveryFee.value, equals(3.00));
      expect(controller.total, equals(39.00));
    });

    test('Increment and decrement quantity adjusts totals', () {
      controller.addToCart(testProduct, size: 'Medium', quantity: 1);
      expect(controller.total, equals(15.00)); // 12 + 3

      final item = controller.cartItems.first;
      controller.increaseQuantity(item);
      expect(controller.itemCount, equals(2));
      expect(controller.total, equals(27.00)); // 24 + 3

      controller.decreaseQuantity(item);
      expect(controller.itemCount, equals(1));
      expect(controller.total, equals(15.00));

      controller.decreaseQuantity(item); // Should remove item
      expect(controller.cartItems.isEmpty, isTrue);
      expect(controller.total, equals(0.00));
    });
  });

  testWidgets('CartView renders items, bill breakdown and CHECKOUT button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    Get.reset();
    final cartController = Get.put(CartController());
    cartController.addToCart(testProduct, size: 'Medium', quantity: 3);

    await tester.pumpWidget(
      GetMaterialApp(
        home: const CartView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify item and prompt price values
    expect(find.text('Margarita'), findsOneWidget);
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('\$36.00'), findsNWidgets(2)); // Both item card and subtotal row
    expect(find.text('Delivery Fee'), findsOneWidget);
    expect(find.text('\$3.00'), findsOneWidget);
    expect(find.text('\$39.00'), findsOneWidget);
    expect(find.text('CHECKOUT'), findsOneWidget);
  });
}

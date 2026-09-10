import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/models/product_model.dart';
import 'package:pizzneapol/main.dart';
import 'package:pizzneapol/modules/cart/controllers/cart_controller.dart';
import 'package:pizzneapol/modules/main_nav/controllers/main_nav_controller.dart';

void main() {
  testWidgets('BottomNavigationBar renders 5 tabs, switches views, and updates cart badge reactively', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PizzneapolApp());
    await tester.pumpAndSettle();

    final cartController = Get.find<CartController>();
    final mainNavController = Get.find<MainNavController>();

    // 1. Verify 5 tabs are displayed
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Cart'), findsWidgets);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // 2. Initially cart is empty, badge text '3' does not exist
    expect(find.text('3'), findsNothing);

    // 3. Add 3 items to cart -> Badge updates reactively!
    const testProduct = ProductModel(
      id: 1,
      name: 'Margarita',
      description: 'Cheese & Tomato',
      price: 12.0,
      image: 'assets/images/pizza/margherita.png',
      categoryId: 1,
      categoryName: 'Pizza',
    );
    cartController.addToCart(testProduct, quantity: 3);
    await tester.pumpAndSettle();

    // Verify badge displays '3'
    expect(find.text('3'), findsOneWidget);

    // 4. Tap on 'Search' tab
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(mainNavController.currentIndex.value, equals(1));
    expect(find.text('Search Food'), findsOneWidget);

    // 5. Tap on 'Cart' tab
    await tester.tap(find.text('Cart').last);
    await tester.pumpAndSettle();
    expect(mainNavController.currentIndex.value, equals(2));
    expect(find.text('Subtotal'), findsOneWidget);

    // 6. Tap back to 'Home'
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(mainNavController.currentIndex.value, equals(0));
    expect(find.text('PIZZNEAPOL PIZZA'), findsWidgets);
  });
}

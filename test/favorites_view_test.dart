import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/models/product_model.dart';
import 'package:pizzneapol/modules/cart/controllers/cart_controller.dart';
import 'package:pizzneapol/modules/favorites/controllers/favorite_controller.dart';
import 'package:pizzneapol/modules/favorites/views/favorites_view.dart';

void main() {
  testWidgets('FavoritesView displays empty state and populated list with interactions',
      (WidgetTester tester) async {
    Get.reset();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.reset();
      Get.reset();
    });

    final cartController = Get.put(CartController());
    final favController = Get.put(FavoriteController(autoLoad: false));

    await tester.pumpWidget(const GetMaterialApp(
      home: FavoritesView(),
    ));
    await tester.pumpAndSettle();

    // 1. Verify App Bar & Empty State
    expect(find.text('My Favorites'), findsOneWidget);
    expect(find.text('No Favorites Yet'), findsOneWidget);
    expect(find.text('Explore Menu'), findsOneWidget);

    // 2. Add a favorite pizza
    const testPizza = ProductModel(
      id: 50,
      name: 'Quattro Formaggi',
      description: 'Gorgonzola, Mozzarella, Parmesan, Pecorino',
      price: 15.0,
      image: 'assets/images/pizza/margherita.png',
      categoryId: 1,
      categoryName: 'Pizza',
    );
    favController.toggleFavorite(testPizza);
    await tester.pumpAndSettle();

    // 3. Verify Empty state disappeared, item card appeared
    expect(find.text('No Favorites Yet'), findsNothing);
    expect(find.text('Quattro Formaggi'), findsOneWidget);
    expect(find.text('1 pizza saved'), findsOneWidget);
    expect(find.text('\$15'), findsOneWidget);
    expect(find.text('ADD'), findsOneWidget);

    // 4. Test Add to Cart button
    await tester.tap(find.text('ADD'));
    await tester.pumpAndSettle();
    expect(cartController.cartItems.length, equals(1));
    expect(cartController.cartItems.first.product.name, equals('Quattro Formaggi'));

    // 5. Test removing favorite via heart icon
    final heartIconFinder = find.byIcon(Icons.favorite_rounded);
    expect(heartIconFinder, findsOneWidget);
    await tester.tap(heartIconFinder);
    await tester.pumpAndSettle();

    // 6. Verify returned to empty state
    expect(find.text('No Favorites Yet'), findsOneWidget);
    expect(favController.favorites.isEmpty, isTrue);
  });
}

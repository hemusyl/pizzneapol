import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/modules/cart/controllers/cart_controller.dart';
import 'package:pizzneapol/modules/orders/controllers/orders_controller.dart';
import 'package:pizzneapol/modules/orders/views/orders_view.dart';

void main() {
  testWidgets('OrdersView renders segmented tabs, cards, and live tracking modal', (WidgetTester tester) async {
    Get.reset();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.reset();
      Get.reset();
    });

    Get.put(CartController());
    final ordersController = Get.put(OrdersController());

    await tester.pumpWidget(const GetMaterialApp(
      home: OrdersView(),
    ));
    await tester.pumpAndSettle();

    // 1. Verify Header & Segmented Tabs
    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Active Orders (1)'), findsOneWidget);
    expect(find.text('Order History'), findsOneWidget);

    // 2. Verify Active Order details
    expect(find.text('PZ-83921'), findsOneWidget);
    expect(find.text('Preparing in Oven'), findsOneWidget);
    expect(find.text('Margarita (Large)'), findsOneWidget);
    expect(find.text('Track Order'), findsOneWidget);

    // 3. Switch to 'Order History' tab
    await tester.tap(find.text('Order History'));
    await tester.pumpAndSettle();

    expect(find.text('PZ-71249'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);
    expect(find.text('Reorder'), findsOneWidget);

    // 4. Switch back to 'Active Orders' tab
    await tester.tap(find.textContaining('Active Orders'));
    await tester.pumpAndSettle();

    // 5. Open Order Tracking modal
    await tester.tap(find.text('Track Order'));
    await tester.pumpAndSettle();

    // Verify Tracking modal contents
    expect(find.text('Order Tracking'), findsOneWidget);
    expect(find.text('Estimated Delivery Time'), findsOneWidget);
    expect(find.text('Order Confirmed'), findsOneWidget);
    expect(find.text('Out for Delivery'), findsOneWidget);
    expect(find.text('Marco Rossi'), findsOneWidget);

    // 6. Test interactive status progression button
    final advanceBtn = find.text('Advance Status (Demo)');
    expect(advanceBtn, findsOneWidget);
    await tester.tap(advanceBtn);
    await tester.pumpAndSettle();

    // Order status is now 'Out for Delivery'
    expect(ordersController.orders.first.status.name, equals('outForDelivery'));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/main.dart';

void main() {
  testWidgets('SearchView renders input, filter chips and updates with user text', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.reset();
      Get.reset();
    });

    await tester.pumpWidget(const PizzneapolApp());
    await tester.pumpAndSettle();

    // 1. Navigate to Search tab from BottomNavigationBar
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    // 2. Verify search bar and filter chips
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Pizza'), findsWidgets);

    // 3. Enter query 'Cheesecake'
    await tester.enterText(find.byType(TextField), 'Cheesecake');
    await tester.pump(const Duration(milliseconds: 300));

    // 4. Verify filtered product is displayed
    expect(find.text('Berry Cheesecake'), findsOneWidget);
    expect(find.text('Margarita'), findsNothing);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pizzneapol/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('HomeScreen full render test matching screenshot', (WidgetTester tester) async {
    // Set a phone resolution
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const PizzneapolApp());
    await tester.pumpAndSettle();

    // 1. Header elements
    expect(find.text('PIZZNEAPOL PIZZA'), findsWidgets);
    expect(find.text('DELIVERY'), findsOneWidget);

    // 2. Location banner
    expect(find.text('29 Hola street, California, USA'), findsOneWidget);

    // 3. Category carousel items
    expect(find.text('Pizza'), findsWidgets);
    expect(find.text('Salad'), findsWidgets);
    expect(find.text('Dessert'), findsWidgets);

    // 4. Products matching screenshot
    expect(find.text('Margarita'), findsOneWidget);
    expect(find.text('Classic Pepperoni'), findsOneWidget);
    expect(find.text('Chicken Supreme'), findsOneWidget);

    // Scroll down to reveal subsequent products
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Vegeterian'), findsOneWidget);

    // 5. "+ ADD" buttons
    expect(find.text('ADD'), findsWidgets);
  });
}

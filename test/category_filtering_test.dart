import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizzneapol/main.dart';
import 'package:pizzneapol/modules/home/widgets/category_item.dart';

void main() {
  testWidgets('Category filtering updates product list and category selection reactively', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PizzneapolApp());
    await tester.pumpAndSettle();

    CategoryItem getCategoryItem(String name) {
      return tester.widget<CategoryItem>(
        find.ancestor(
          of: find.text(name),
          matching: find.byType(CategoryItem),
        ),
      );
    }

    // 1. Initially Pizza is selected: Margarita and Classic Pepperoni are visible
    expect(getCategoryItem('Pizza').isSelected, isTrue);
    expect(getCategoryItem('Salad').isSelected, isFalse);
    expect(find.text('Margarita'), findsOneWidget);
    expect(find.text('Classic Pepperoni'), findsOneWidget);
    expect(find.text('Caesar Fresh Salad'), findsNothing);

    // 2. Tap on "Salad" category
    final saladCategoryFinder = find.widgetWithText(GestureDetector, 'Salad');
    expect(saladCategoryFinder, findsOneWidget);
    await tester.tap(saladCategoryFinder);
    await tester.pumpAndSettle();

    // 3. Verify that Salad category is now selected, Pizza is unselected, and Salad items are displayed
    expect(getCategoryItem('Pizza').isSelected, isFalse);
    expect(getCategoryItem('Salad').isSelected, isTrue);
    expect(find.text('Margarita'), findsNothing);
    expect(find.text('Caesar Fresh Salad'), findsOneWidget);
    expect(find.text('Greek Garden Salad'), findsOneWidget);

    // 4. Tap on "Dessert" category
    final dessertCategoryFinder = find.widgetWithText(GestureDetector, 'Dessert');
    expect(dessertCategoryFinder, findsOneWidget);
    await tester.tap(dessertCategoryFinder);
    await tester.pumpAndSettle();

    // 5. Verify Dessert category is selected, Salad is unselected, and Dessert items are displayed
    expect(getCategoryItem('Salad').isSelected, isFalse);
    expect(getCategoryItem('Dessert').isSelected, isTrue);
    expect(find.text('Caesar Fresh Salad'), findsNothing);
    expect(find.text('Berry Cheesecake'), findsOneWidget);
    expect(find.text('Chocolate Lava Cake'), findsOneWidget);

    // 6. Tap back on "Pizza" category
    final pizzaCategoryFinder = find.widgetWithText(GestureDetector, 'Pizza');
    expect(pizzaCategoryFinder, findsOneWidget);
    await tester.tap(pizzaCategoryFinder);
    await tester.pumpAndSettle();

    // 7. Verify Pizza is selected, Dessert is unselected, and Pizza items return immediately
    expect(getCategoryItem('Pizza').isSelected, isTrue);
    expect(getCategoryItem('Dessert').isSelected, isFalse);
    expect(find.text('Margarita'), findsOneWidget);
    expect(find.text('Berry Cheesecake'), findsNothing);
  });
}


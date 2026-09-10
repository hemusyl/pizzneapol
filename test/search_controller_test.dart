import 'package:flutter_test/flutter_test.dart';
import 'package:pizzneapol/data/providers/local_data_provider.dart';
import 'package:pizzneapol/data/repositories/category_repository.dart';
import 'package:pizzneapol/data/repositories/product_repository.dart';
import 'package:pizzneapol/modules/search/controllers/food_search_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FoodSearchController Unit Tests', () {
    late FoodSearchController controller;

    setUp(() {
      final provider = LocalDataProvider();
      controller = FoodSearchController(
        categoryRepository: CategoryRepository(localProvider: provider),
        productRepository: ProductRepository(localProvider: provider),
      );
    });

    test('Loads catalog and filters by name query', () async {
      await controller.loadSearchData();

      expect(controller.allProducts.length, equals(14));
      expect(controller.searchResults.length, equals(14));

      controller.onQueryChanged('Pepperoni');
      expect(controller.searchResults.length, equals(1));
      expect(controller.searchResults.first.name, contains('Pepperoni'));
    });

    test('Filters by category chip', () async {
      await controller.loadSearchData();

      // Category 2 is Salad (2 products in mock data)
      controller.selectCategoryFilter(2);
      expect(controller.searchResults.length, equals(2));
      expect(controller.searchResults.every((p) => p.categoryId == 2), isTrue);
    });

    test('Non-matching query returns empty list', () async {
      await controller.loadSearchData();

      controller.onQueryChanged('NonExistentPizzaXYZ');
      expect(controller.searchResults.isEmpty, isTrue);
    });

    test('Clear query resets search results back to category products', () async {
      await controller.loadSearchData();

      controller.onQueryChanged('Pepperoni');
      expect(controller.searchResults.length, equals(1));

      controller.clearQuery();
      expect(controller.searchQuery.value, isEmpty);
      expect(controller.searchResults.length, equals(14));
    });
  });
}

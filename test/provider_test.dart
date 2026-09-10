import 'package:flutter_test/flutter_test.dart';
import 'package:pizzneapol/data/providers/local_data_provider.dart';
import 'package:pizzneapol/data/repositories/category_repository.dart';
import 'package:pizzneapol/data/repositories/product_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalDataProvider & Repositories Tests', () {
    late LocalDataProvider provider;
    late CategoryRepository categoryRepo;
    late ProductRepository productRepo;

    setUp(() {
      provider = LocalDataProvider();
      categoryRepo = CategoryRepository(localProvider: provider);
      productRepo = ProductRepository(localProvider: provider);
    });

    test('getCategories loads 5 categories successfully', () async {
      final categories = await categoryRepo.getAllCategories();
      expect(categories.length, equals(5));
      expect(categories[0].name, equals('Pizza'));
      expect(categories[1].name, equals('Salad'));
    });

    test('getProducts loads all 14 mock products', () async {
      final products = await productRepo.getProducts();
      expect(products.length, equals(14));
      expect(products[0].name, equals('Margarita'));
      expect(products[0].price, equals(12.0));
    });

    test('getProductsByCategory returns only pizza category items', () async {
      final pizzas = await productRepo.getProductsByCategory(1);
      expect(pizzas.isNotEmpty, isTrue);
      expect(pizzas.every((p) => p.categoryId == 1), isTrue);
    });

    test('searchProducts finds matches correctly', () async {
      final results = await productRepo.searchProducts('Pepperoni');
      expect(results.length, equals(1));
      expect(results.first.name, contains('Pepperoni'));
    });
  });
}

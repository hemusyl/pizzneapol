import 'package:flutter_test/flutter_test.dart';
import 'package:pizzneapol/data/providers/api_provider.dart';
import 'package:pizzneapol/data/repositories/category_repository.dart';
import 'package:pizzneapol/data/repositories/order_repository.dart';
import 'package:pizzneapol/data/repositories/product_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Repository Architecture & Provider Switching Tests', () {
    test('CategoryRepository implements ICategoryRepository and defaults to local', () async {
      final repo = CategoryRepository();
      expect(repo, isA<ICategoryRepository>());
      expect(repo.isRemote, isFalse);

      final categories = await repo.getAllCategories();
      expect(categories.isNotEmpty, isTrue);
      expect(categories.first.name, equals('Pizza'));
    });

    test('CategoryRepository accepts ApiProvider for remote Laravel backend', () async {
      final api = ApiProvider(customBaseUrl: 'http://localhost:8000/api');
      final repo = CategoryRepository(apiProvider: api);

      expect(repo.isRemote, isTrue);
      // On connection error to mock URL, graceful fallback to local data
      final categories = await repo.getAllCategories();
      expect(categories.isNotEmpty, isTrue);
    });

    test('ProductRepository implements IProductRepository and queries catalog', () async {
      final repo = ProductRepository();
      expect(repo, isA<IProductRepository>());
      expect(repo.isRemote, isFalse);

      final allProducts = await repo.getProducts();
      expect(allProducts.isNotEmpty, isTrue);

      final pizzas = await repo.getProductsByCategory(1);
      expect(pizzas.every((p) => p.categoryId == 1), isTrue);

      final margherita = await repo.getProductById(1);
      expect(margherita, isNotNull);
      expect(margherita!.name, equals('Margarita'));

      final searchResults = await repo.searchProducts('pepperoni');
      expect(searchResults.any((p) => p.name.contains('Pepperoni')), isTrue);
    });

    test('ProductRepository with ApiProvider enables remote mode with fallback', () async {
      final api = ApiProvider(customBaseUrl: 'https://api.pizzneapol.com/api');
      final repo = ProductRepository(apiProvider: api);

      expect(repo.isRemote, isTrue);
      final products = await repo.getProducts();
      expect(products.isNotEmpty, isTrue);
    });

    test('OrderRepository implements IOrderRepository and tracks remote flag', () {
      final localRepo = OrderRepository();
      expect(localRepo, isA<IOrderRepository>());
      expect(localRepo.isRemote, isFalse);

      final remoteRepo =
          OrderRepository(apiProvider: ApiProvider());
      expect(remoteRepo.isRemote, isTrue);
    });
  });
}

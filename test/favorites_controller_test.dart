import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/models/product_model.dart';
import 'package:pizzneapol/modules/favorites/controllers/favorite_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavoriteController Unit Tests', () {
    late FavoriteController controller;

    const testProduct1 = ProductModel(
      id: 101,
      name: 'Margherita DOC',
      description: 'San Marzano tomatoes, fresh buffalo mozzarella, fresh basil',
      price: 14.0,
      image: 'assets/images/pizza/margherita.png',
      categoryId: 1,
      categoryName: 'Pizza',
    );

    const testProduct2 = ProductModel(
      id: 102,
      name: 'Diavola Spicy',
      description: 'Calabrian chili, spicy salami, mozzarella',
      price: 16.0,
      image: 'assets/images/pizza/pepperoni.png',
      categoryId: 1,
      categoryName: 'Pizza',
    );

    setUp(() {
      Get.reset();
      Get.testMode = true;
      controller = FavoriteController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Initializes with empty favorites list', () {
      expect(controller.favorites.isEmpty, isTrue);
      expect(controller.favoriteCount, equals(0));
      expect(controller.isFavorite(101), isFalse);
    });

    test('toggleFavorite adds product if not in favorites', () {
      controller.toggleFavorite(testProduct1);

      expect(controller.favoriteCount, equals(1));
      expect(controller.isFavorite(101), isTrue);
      expect(controller.favorites.first.name, equals('Margherita DOC'));
    });

    test('toggleFavorite removes product if already in favorites', () {
      controller.toggleFavorite(testProduct1);
      expect(controller.isFavorite(101), isTrue);

      controller.toggleFavorite(testProduct1);
      expect(controller.isFavorite(101), isFalse);
      expect(controller.favoriteCount, equals(0));
    });

    test('removeFavorite removes specific item by ID', () {
      controller.toggleFavorite(testProduct1);
      controller.toggleFavorite(testProduct2);
      expect(controller.favoriteCount, equals(2));

      controller.removeFavorite(101);
      expect(controller.favoriteCount, equals(1));
      expect(controller.isFavorite(101), isFalse);
      expect(controller.isFavorite(102), isTrue);
    });

    test('clearFavorites removes all items', () {
      controller.toggleFavorite(testProduct1);
      controller.toggleFavorite(testProduct2);
      expect(controller.favoriteCount, equals(2));

      controller.clearFavorites();
      expect(controller.favoriteCount, equals(0));
      expect(controller.favorites.isEmpty, isTrue);
    });
  });
}

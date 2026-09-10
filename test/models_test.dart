import 'package:flutter_test/flutter_test.dart';
import 'package:pizzneapol/data/models/category_model.dart';
import 'package:pizzneapol/data/models/product_model.dart';

void main() {
  group('CategoryModel Tests', () {
    test('Correctly parses from JSON with camelCase and snake_case', () {
      final json = {
        'id': 1,
        'name': 'Pizza',
        'image': 'assets/images/categories/pizza.png',
        'is_active': true,
      };

      final category = CategoryModel.fromJson(json);

      expect(category.id, 1);
      expect(category.name, 'Pizza');
      expect(category.image, 'assets/images/categories/pizza.png');
      expect(category.isActive, true);
    });

    test('toJson produces expected structure', () {
      const category = CategoryModel(
        id: 2,
        name: 'Salad',
        image: 'assets/images/categories/salad.png',
      );

      final json = category.toJson();

      expect(json['id'], 2);
      expect(json['name'], 'Salad');
      expect(json['is_active'], true);
    });
  });

  group('ProductModel Tests', () {
    test('Correctly parses from JSON with numeric types and defaults', () {
      final json = {
        'id': 1,
        'name': 'Margherita',
        'description': 'Medium | Cheese , onion, and tomato pure',
        'price': 12.0,
        'image': 'assets/images/pizza/margherita.png',
        'category_id': 1,
        'category_name': 'Pizza',
        'available': true,
        'rating': 4.9,
        'ingredients': ['Mozzarella', 'Tomato Sauce', 'Basil'],
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, 1);
      expect(product.name, 'Margherita');
      expect(product.price, 12.0);
      expect(product.categoryId, 1);
      expect(product.ingredients.length, 3);
      expect(product.sizes, contains('Medium'));
    });

    test('copyWith updates specific fields without mutating original', () {
      const original = ProductModel(
        id: 1,
        name: 'Classic Pepperoni',
        description: 'Pepperoni & Cheese',
        price: 12.0,
        image: 'assets/images/pizza/pepperoni.png',
        categoryId: 1,
        categoryName: 'Pizza',
      );

      final updated = original.copyWith(price: 14.5, isFavorite: true);

      expect(updated.price, 14.5);
      expect(updated.isFavorite, true);
      expect(updated.name, 'Classic Pepperoni');
      expect(original.price, 12.0);
      expect(original.isFavorite, false);
    });
  });
}

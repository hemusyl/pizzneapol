import 'package:flutter_test/flutter_test.dart';
import 'package:pizzneapol/data/models/category_model.dart';
import 'package:pizzneapol/data/providers/local_data_provider.dart';
import 'package:pizzneapol/data/repositories/category_repository.dart';
import 'package:pizzneapol/data/repositories/product_repository.dart';
import 'package:pizzneapol/modules/home/controllers/home_controller.dart';
import 'package:pizzneapol/modules/home/controllers/location_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationController Tests', () {
    late LocationController locationController;

    setUp(() {
      locationController = LocationController();
    });

    test('Initializes with default address from screenshot', () {
      expect(locationController.currentAddress.value, '29 Hola street, California, USA');
      expect(locationController.deliveryType.value, 'DELIVERY');
    });

    test('Updates address and delivery type reactively', () {
      locationController.setAddress('123 Main St, New York');
      expect(locationController.currentAddress.value, '123 Main St, New York');

      locationController.setDeliveryType('PICKUP');
      expect(locationController.deliveryType.value, 'PICKUP');
    });
  });

  group('HomeController Tests', () {
    late HomeController homeController;

    setUp(() {
      final provider = LocalDataProvider();
      homeController = HomeController(
        categoryRepository: CategoryRepository(localProvider: provider),
        productRepository: ProductRepository(localProvider: provider),
      );
    });

    test('Loads initial data and defaults to first category', () async {
      await homeController.loadHomeData();

      expect(homeController.isLoading.value, isFalse);
      expect(homeController.categories.length, equals(5));
      expect(homeController.selectedCategory.value?.name, equals('Pizza'));
      expect(homeController.filteredProducts.isNotEmpty, isTrue);
      expect(homeController.filteredProducts.every((p) => p.categoryId == 1), isTrue);
    });

    test('selectCategory filters displayed products', () async {
      await homeController.loadHomeData();

      // Switch to Salad (id: 2)
      const saladCategory = CategoryModel(
        id: 2,
        name: 'Salad',
        image: 'assets/images/categories/salad.png',
      );

      homeController.selectCategory(saladCategory);

      expect(homeController.selectedCategory.value?.id, equals(2));
      expect(homeController.filteredProducts.every((p) => p.categoryId == 2), isTrue);
    });
  });
}

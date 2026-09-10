import 'package:flutter_test/flutter_test.dart';
import 'package:pizzneapol/data/models/cart_item_model.dart';
import 'package:pizzneapol/data/models/order_model.dart';
import 'package:pizzneapol/data/models/product_model.dart';
import 'package:pizzneapol/data/repositories/order_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OrderRepository Unit Tests', () {
    late OrderRepository repository;

    setUp(() {
      repository = OrderRepository();
    });

    test('Initializes with default sample orders', () async {
      final orders = await repository.getOrders();
      expect(orders.length, equals(2));
      expect(orders.first.id, equals('PZ-83921'));
      expect(orders.last.id, equals('PZ-71249'));
    });

    test('getOrderById returns matching order or null', () async {
      final order = await repository.getOrderById('PZ-83921');
      expect(order, isNotNull);
      expect(order!.deliveryAddress, contains('California'));

      final nonExistent = await repository.getOrderById('NON-EXISTENT');
      expect(nonExistent, isNull);
    });

    test('createOrder adds new order at the front of the list', () async {
      const samplePizza = ProductModel(
        id: 1,
        name: 'Margarita',
        description: 'Cheese',
        price: 12.0,
        image: 'assets/images/pizza/margherita.png',
        categoryId: 1,
        categoryName: 'Pizza',
      );

      final newOrder = OrderModel(
        id: 'PZ-99999',
        items: [
          CartItemModel(product: samplePizza, quantity: 1),
        ],
        deliveryAddress: '10 Downing St',
        paymentMethod: 'Cash on Delivery',
        subtotal: 12.0,
        deliveryFee: 0.0,
        discount: 0.0,
        total: 12.0,
        orderDate: DateTime.now(),
        status: OrderStatus.confirmed,
      );

      final created = await repository.createOrder(newOrder);
      expect(created.id, equals('PZ-99999'));

      final orders = await repository.getOrders();
      expect(orders.length, equals(3));
      expect(orders.first.id, equals('PZ-99999'));
    });

    test('updateOrderStatus modifies order status correctly', () async {
      final success =
          await repository.updateOrderStatus('PZ-83921', OrderStatus.delivered);
      expect(success, isTrue);

      final updated = await repository.getOrderById('PZ-83921');
      expect(updated!.status, equals(OrderStatus.delivered));
    });
  });
}

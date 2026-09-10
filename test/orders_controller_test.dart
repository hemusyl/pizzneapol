import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/models/cart_item_model.dart';
import 'package:pizzneapol/data/models/order_model.dart';
import 'package:pizzneapol/data/models/product_model.dart';
import 'package:pizzneapol/modules/cart/controllers/cart_controller.dart';
import 'package:pizzneapol/modules/orders/controllers/orders_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testProduct = ProductModel(
    id: 1,
    name: 'Margarita',
    description: 'Cheese & Tomato',
    price: 12.0,
    image: 'assets/images/pizza/margherita.png',
    categoryId: 1,
    categoryName: 'Pizza',
  );

  group('OrdersController Unit Tests', () {
    late CartController cartController;
    late OrdersController ordersController;

    setUp(() {
      Get.reset();
      cartController = CartController();
      ordersController = OrdersController(cartController: cartController);
    });

    tearDown(() {
      Get.reset();
    });

    test('Initializes with initial active and past orders', () {
      expect(ordersController.orders.length, equals(2));
      expect(ordersController.activeOrders.length, equals(1));
      expect(ordersController.pastOrders.length, equals(1));
      expect(ordersController.activeOrders.first.id, equals('PZ-83921'));
      expect(ordersController.activeOrders.first.status, equals(OrderStatus.preparing));
      expect(ordersController.pastOrders.first.id, equals('PZ-71249'));
      expect(ordersController.pastOrders.first.status, equals(OrderStatus.delivered));
    });

    test('switchTab changes active tab index', () {
      expect(ordersController.selectedTab.value, equals(0));
      ordersController.switchTab(1);
      expect(ordersController.selectedTab.value, equals(1));
    });

    test('advanceOrderStatus updates order status step-by-step to delivered', () {
      final activeOrder = ordersController.activeOrders.first;
      expect(activeOrder.status, equals(OrderStatus.preparing));

      // 1. Advance from preparing to outForDelivery
      ordersController.advanceOrderStatus(activeOrder.id);
      expect(ordersController.orders.first.status, equals(OrderStatus.outForDelivery));
      expect(ordersController.activeOrders.length, equals(1));

      // 2. Advance from outForDelivery to delivered
      ordersController.advanceOrderStatus(activeOrder.id);
      expect(ordersController.orders.first.status, equals(OrderStatus.delivered));

      // Now activeOrders is empty and pastOrders has 2 orders
      expect(ordersController.activeOrders.length, equals(0));
      expect(ordersController.pastOrders.length, equals(2));
    });

    test('cancelOrder marks order as cancelled', () {
      // Create a confirmed order
      final order = OrderModel(
        id: 'PZ-TEST1',
        items: [CartItemModel(product: testProduct, quantity: 1)],
        deliveryAddress: '29 Hola street',
        paymentMethod: 'Cash',
        subtotal: 12.0,
        deliveryFee: 3.0,
        discount: 0.0,
        total: 15.0,
        orderDate: DateTime.now(),
        status: OrderStatus.confirmed,
      );
      ordersController.addOrder(order);
      expect(ordersController.activeOrders.length, equals(2));

      final cancelled = ordersController.cancelOrder('PZ-TEST1');
      expect(cancelled, isTrue);
      expect(ordersController.orders.first.status, equals(OrderStatus.cancelled));
      expect(ordersController.activeOrders.length, equals(1));
      expect(ordersController.pastOrders.length, equals(2));
    });

    test('reorder adds past order items into cartController', () {
      final pastOrder = ordersController.pastOrders.first;
      expect(cartController.cartItems.isEmpty, isTrue);

      ordersController.reorder(pastOrder);
      expect(cartController.cartItems.isNotEmpty, isTrue);
      expect(cartController.itemCount, equals(1));
      expect(cartController.cartItems.first.product.name, equals('Classic Pepperoni'));
    });

    test('addOrder adds new order at index 0 and switches to active tab', () {
      ordersController.switchTab(1);
      final newOrder = OrderModel(
        id: 'PZ-NEW99',
        items: [CartItemModel(product: testProduct, quantity: 2)],
        deliveryAddress: '100 Ocean Drive',
        paymentMethod: 'Card',
        subtotal: 24.0,
        deliveryFee: 3.0,
        discount: 0.0,
        total: 27.0,
        orderDate: DateTime.now(),
        status: OrderStatus.confirmed,
      );

      ordersController.addOrder(newOrder);
      expect(ordersController.orders.first.id, equals('PZ-NEW99'));
      expect(ordersController.selectedTab.value, equals(0)); // switched to active tab
    });
  });
}

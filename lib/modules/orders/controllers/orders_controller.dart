import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../main_nav/controllers/main_nav_controller.dart';

/// Controller managing active orders, past order history, order tracking,
/// and status progression via OrderRepository.
class OrdersController extends GetxController {
  final CartController cartController;
  final OrderRepository orderRepository;

  OrdersController({
    CartController? cartController,
    OrderRepository? orderRepository,
  })  : cartController = cartController ??
            (Get.isRegistered<CartController>()
                ? Get.find<CartController>()
                : Get.put(CartController())),
        orderRepository = orderRepository ??
            (Get.isRegistered<OrderRepository>()
                ? Get.find<OrderRepository>()
                : Get.put(OrderRepository())) {
    _loadInitialOrders();
  }

  /// Master list of all customer orders
  final RxList<OrderModel> orders = <OrderModel>[].obs;

  /// Active tab index: 0 = Active Orders, 1 = Order History
  final RxInt selectedTab = 0.obs;

  /// Active order currently being viewed in the live tracker
  final Rxn<OrderModel> selectedTrackingOrder = Rxn<OrderModel>();

  /// Initial orders loaded from OrderRepository
  void _loadInitialOrders() {
    orders.assignAll(orderRepository.initialLocalOrders);
    refreshOrdersFromBackend();
  }

  /// Refreshes orders from the remote Laravel API if connected
  Future<void> refreshOrdersFromBackend() async {
    if (orderRepository.isRemote) {
      final remoteOrders = await orderRepository.getOrders();
      if (remoteOrders.isNotEmpty) {
        orders.assignAll(remoteOrders);
      }
    }
  }

  /// List of ongoing / in-progress orders
  List<OrderModel> get activeOrders => orders
      .where((o) =>
          o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled)
      .toList();

  /// List of completed or cancelled orders
  List<OrderModel> get pastOrders => orders
      .where((o) =>
          o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled)
      .toList();

  /// Changes the segmented tab
  void switchTab(int index) {
    selectedTab.value = index;
  }

  /// Adds a newly placed order from checkout
  void addOrder(OrderModel newOrder) {
    orders.insert(0, newOrder);
    selectedTab.value = 0; // Switch to active tab
    orderRepository.createOrder(newOrder);
  }

  /// Selects an order for tracking modal
  void setTrackingOrder(OrderModel order) {
    selectedTrackingOrder.value = order;
  }

  /// Advances an order's lifecycle for demo / live tracking testing
  void advanceOrderStatus(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final current = orders[index];
    OrderStatus nextStatus = current.status;

    switch (current.status) {
      case OrderStatus.pending:
        nextStatus = OrderStatus.confirmed;
        break;
      case OrderStatus.confirmed:
        nextStatus = OrderStatus.preparing;
        break;
      case OrderStatus.preparing:
        nextStatus = OrderStatus.outForDelivery;
        break;
      case OrderStatus.outForDelivery:
        nextStatus = OrderStatus.delivered;
        break;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        break;
    }

    if (nextStatus != current.status) {
      final updated = current.copyWith(status: nextStatus);
      orders[index] = updated;
      if (selectedTrackingOrder.value?.id == orderId) {
        selectedTrackingOrder.value = updated;
      }
      orderRepository.updateOrderStatus(orderId, nextStatus);
    }
  }

  /// Cancels an order if it is still eligible (pending or confirmed)
  bool cancelOrder(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    final current = orders[index];
    if (current.status == OrderStatus.delivered ||
        current.status == OrderStatus.cancelled ||
        current.status == OrderStatus.outForDelivery) {
      return false;
    }

    final updated = current.copyWith(status: OrderStatus.cancelled);
    orders[index] = updated;
    if (selectedTrackingOrder.value?.id == orderId) {
      selectedTrackingOrder.value = updated;
    }
    orderRepository.updateOrderStatus(orderId, OrderStatus.cancelled);
    return true;
  }

  /// Re-adds items from a past order into the cart
  void reorder(OrderModel order) {
    for (final item in order.items) {
      cartController.addToCart(
        item.product,
        quantity: item.quantity,
        size: item.selectedSize,
      );
    }

    if (Get.context != null) {
      Get.snackbar(
        'Added to Cart',
        'Items from order ${order.id} have been re-added to your cart.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
        duration: const Duration(seconds: 2),
      );
    }

    // Switch to cart tab in main navigation shell if available
    if (Get.isRegistered<MainNavController>()) {
      Get.find<MainNavController>().changeTab(2); // Cart tab
    }
  }
}

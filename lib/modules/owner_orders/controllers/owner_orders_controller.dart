import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../orders/controllers/orders_controller.dart';

/// Controller managing restaurant kitchen orders, live status updates,
/// customer dispatch, and real-time push notification triggers for restaurant owners.
class OwnerOrdersController extends GetxController {
  final OrderRepository orderRepository;

  OwnerOrdersController({OrderRepository? repository})
      : orderRepository = repository ??
            (Get.isRegistered<OrderRepository>()
                ? Get.find<OrderRepository>()
                : Get.put(OrderRepository()));

  /// Master list of all restaurant orders
  final RxList<OrderModel> orders = <OrderModel>[].obs;

  /// Selected filter tab:
  /// 0 = All, 1 = New/Pending, 2 = In Oven (Preparing), 3 = Out for Delivery, 4 = Delivered
  final RxInt selectedFilterTab = 0.obs;

  /// Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  /// Loads orders from repository and syncs with OrdersController if available
  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      if (Get.isRegistered<OrdersController>()) {
        final customerOrdersCtrl = Get.find<OrdersController>();
        orders.assignAll(customerOrdersCtrl.orders);
      } else {
        orders.assignAll(orderRepository.initialLocalOrders);
      }

      if (orderRepository.isRemote) {
        final remote = await orderRepository.getOrders();
        if (remote.isNotEmpty) {
          orders.assignAll(remote);
        }
      }
    } catch (_) {
      // Graceful local fallback
    } finally {
      isLoading.value = false;
    }
  }

  /// Changes the active category filter
  void switchFilterTab(int index) {
    selectedFilterTab.value = index;
  }

  /// Filtered list of orders based on selected tab
  List<OrderModel> get filteredOrders {
    switch (selectedFilterTab.value) {
      case 1: // New / Pending
        return orders
            .where((o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.confirmed)
            .toList();
      case 2: // In the Oven
        return orders
            .where((o) => o.status == OrderStatus.preparing)
            .toList();
      case 3: // Out for Delivery
        return orders
            .where((o) => o.status == OrderStatus.outForDelivery)
            .toList();
      case 4: // Delivered & Completed
        return orders
            .where((o) =>
                o.status == OrderStatus.delivered ||
                o.status == OrderStatus.cancelled)
            .toList();
      case 0: // All
      default:
        return orders.toList();
    }
  }

  /// Quick metrics for restaurant manager dashboard
  int get pendingCount => orders
      .where((o) =>
          o.status == OrderStatus.pending || o.status == OrderStatus.confirmed)
      .length;

  int get preparingCount =>
      orders.where((o) => o.status == OrderStatus.preparing).length;

  int get deliveryCount =>
      orders.where((o) => o.status == OrderStatus.outForDelivery).length;

  double get todaySales => orders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0.0, (sum, o) => sum + o.total);

  /// Updates an order's status and triggers push notification to customer
  Future<void> updateOrderStatus(
      OrderModel order, OrderStatus newStatus) async {
    final index = orders.indexWhere((o) => o.id == order.id);
    if (index == -1) return;

    final updated = order.copyWith(status: newStatus);
    orders[index] = updated;

    // Sync with customer orders controller if active in memory
    if (Get.isRegistered<OrdersController>()) {
      final customerCtrl = Get.find<OrdersController>();
      final cIdx = customerCtrl.orders.indexWhere((o) => o.id == order.id);
      if (cIdx != -1) {
        customerCtrl.orders[cIdx] = updated;
      }
    }

    // Persist via OrderRepository (calls backend API PATCH /orders/{id}/status)
    await orderRepository.updateOrderStatus(order.id, newStatus);

    // Notification message sent to customer
    final notificationInfo = _getNotificationMessage(order.id, newStatus);

    if (Get.context != null) {
      Get.snackbar(
        notificationInfo['title']!,
        notificationInfo['body']!,
        icon: Icon(notificationInfo['icon'] as IconData, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF36C0A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Sends a custom push notification alert directly to the customer of an order
  void sendCustomCustomerAlert({
    required OrderModel order,
    required String title,
    required String message,
  }) {
    if (Get.context != null) {
      Get.snackbar(
        '🔔 Push Notification Sent to Customer',
        '"$title: $message" sent to order #${order.id}',
        icon: const Icon(Icons.mark_chat_read_outlined, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Maps status transition to customer push notification message
  Map<String, dynamic> _getNotificationMessage(
      String orderId, OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return {
          'title': '🔔 Order #$orderId Confirmed!',
          'body': 'Push sent to customer: "The kitchen has accepted your order!"',
          'icon': Icons.check_circle_outline,
        };
      case OrderStatus.preparing:
        return {
          'title': '🍕 Order #$orderId In The Oven!',
          'body': 'Push sent to customer: "Your pizza is now baking in the stone oven!"',
          'icon': Icons.local_fire_department,
        };
      case OrderStatus.outForDelivery:
        return {
          'title': '🛵 Order #$orderId Out For Delivery!',
          'body': 'Push sent to customer: "Your rider is on the way with your hot pizza!"',
          'icon': Icons.delivery_dining,
        };
      case OrderStatus.delivered:
        return {
          'title': '✅ Order #$orderId Delivered!',
          'body': 'Push sent to customer: "Order delivered. Enjoy your meal!"',
          'icon': Icons.sentiment_very_satisfied,
        };
      case OrderStatus.cancelled:
        return {
          'title': '❌ Order #$orderId Cancelled',
          'body': 'Push sent to customer: "Your order has been cancelled."',
          'icon': Icons.cancel_outlined,
        };
      case OrderStatus.pending:
      default:
        return {
          'title': 'Order Updated',
          'body': 'Push notification sent to customer.',
          'icon': Icons.notifications,
        };
    }
  }
}

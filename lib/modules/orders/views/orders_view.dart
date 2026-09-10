import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../main_nav/controllers/main_nav_controller.dart';
import '../controllers/orders_controller.dart';

/// Orders screen with segmented tabs for Active and Past orders,
/// live order tracking timeline, driver contact card, and reorder capability.
class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  late final OrdersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Top Segmented Selector: Active Orders vs Order History
          _buildSegmentedTabHeader(),
          const SizedBox(height: 8),

          // 2. Orders List
          Expanded(
            child: Obx(() {
              final isCurrentTabActive = _controller.selectedTab.value == 0;
              final orderList = isCurrentTabActive
                  ? _controller.activeOrders
                  : _controller.pastOrders;

              if (orderList.isEmpty) {
                return _buildEmptyOrdersView(isActiveTab: isCurrentTabActive);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                physics: const BouncingScrollPhysics(),
                itemCount: orderList.length,
                itemBuilder: (context, index) {
                  final order = orderList[index];
                  return _buildOrderCard(context, order, isActive: isCurrentTabActive);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Segmented pill tabs at top of screen
  Widget _buildSegmentedTabHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Obx(() {
          final current = _controller.selectedTab.value;
          return Row(
            children: [
              // Tab 0: Active Orders
              Expanded(
                child: _segmentButton(
                  title: 'Active Orders (${_controller.activeOrders.length})',
                  isSelected: current == 0,
                  onTap: () => _controller.switchTab(0),
                ),
              ),
              // Tab 1: Order History
              Expanded(
                child: _segmentButton(
                  title: 'Order History',
                  isSelected: current == 1,
                  onTap: () => _controller.switchTab(1),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _segmentButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  /// Order card with ID, status pill, items list, total, and actions
  Widget _buildOrderCard(BuildContext context, OrderModel order, {required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order ID & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryPeach,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.id,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              _buildStatusPill(order.status),
            ],
          ),
          const SizedBox(height: 10),

          // Date & Delivery Address
          Text(
            _formatOrderDate(order.orderDate),
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            order.deliveryAddress,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.divider, height: 1),
          ),

          // Items summary
          Column(
            children: order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPeach,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.product.name} (${item.selectedSize})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.divider, height: 1),
          ),

          // Footer: Total & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isActive) ...[
                    // Track Order CTA
                    ElevatedButton.icon(
                      onPressed: () => _showOrderTrackingBottomSheet(context, order),
                      icon: const Icon(Icons.local_shipping_rounded, size: 17, color: Colors.white),
                      label: const Text(
                        'Track Order',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Reorder CTA
                    OutlinedButton.icon(
                      onPressed: () => _controller.reorder(order),
                      icon: const Icon(Icons.replay_rounded, size: 16, color: AppColors.primary),
                      label: const Text(
                        'Reorder',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Status badge pill with custom colors matching prompt & screenshot
  Widget _buildStatusPill(OrderStatus status) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        bg = AppColors.primaryPeach;
        fg = AppColors.primary;
        label = 'Confirmed';
        icon = Icons.check_circle_outline_rounded;
        break;
      case OrderStatus.preparing:
        bg = AppColors.primary;
        fg = Colors.white;
        label = 'Preparing in Oven';
        icon = Icons.local_pizza_rounded;
        break;
      case OrderStatus.outForDelivery:
        bg = const Color(0xFFE8F1FF);
        fg = const Color(0xFF0D6EFD);
        label = 'Out for Delivery';
        icon = Icons.delivery_dining_rounded;
        break;
      case OrderStatus.delivered:
        bg = const Color(0xFFE8F8F0);
        fg = AppColors.success;
        label = 'Delivered';
        icon = Icons.check_circle_rounded;
        break;
      case OrderStatus.cancelled:
        bg = const Color(0xFFFFEEEE);
        fg = AppColors.error;
        label = 'Cancelled';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive Order Tracking Bottom Sheet
  void _showOrderTrackingBottomSheet(BuildContext context, OrderModel initialOrder) {
    _controller.setTrackingOrder(initialOrder);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            final order = _controller.selectedTrackingOrder.value ?? initialOrder;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Tracking',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Order ID: ${order.id}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Estimated Delivery Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPeach,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.timer_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimated Delivery Time',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              order.status == OrderStatus.delivered
                                  ? 'Delivered Successfully!'
                                  : '20 - 30 minutes',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4-Step Order Status Timeline
                _buildTimelineStepper(order.status),
                const SizedBox(height: 16),

                // Driver Contact Card
                if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled) ...[
                  _buildDriverCard(),
                  const SizedBox(height: 16),
                ],

                // Advance Status Demo button for quick review testing
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _controller.advanceOrderStatus(order.id),
                    icon: const Icon(Icons.fast_forward_rounded, size: 18),
                    label: Text(
                      order.status == OrderStatus.delivered
                          ? 'Order Completed'
                          : 'Advance Status (Demo)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  /// 4-step vertical timeline stepper
  Widget _buildTimelineStepper(OrderStatus status) {
    final steps = [
      {'title': 'Order Confirmed', 'subtitle': 'Your order has been received by the kitchen', 'icon': Icons.receipt_rounded},
      {'title': 'Preparing in Oven', 'subtitle': 'Crafting pizza with fresh ingredients', 'icon': Icons.local_pizza_rounded},
      {'title': 'Out for Delivery', 'subtitle': 'Driver is heading to your address', 'icon': Icons.delivery_dining_rounded},
      {'title': 'Delivered', 'subtitle': 'Order has arrived at your doorstep', 'icon': Icons.check_circle_rounded},
    ];

    int activeStepIndex = 0;
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        activeStepIndex = 0;
        break;
      case OrderStatus.preparing:
        activeStepIndex = 1;
        break;
      case OrderStatus.outForDelivery:
        activeStepIndex = 2;
        break;
      case OrderStatus.delivered:
        activeStepIndex = 3;
        break;
      case OrderStatus.cancelled:
        activeStepIndex = -1;
        break;
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= activeStepIndex;
        final isCurrent = index == activeStepIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primary : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    steps[index]['icon'] as IconData,
                    size: 18,
                    color: isCompleted ? Colors.white : Colors.grey.shade500,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2.5,
                    height: 32,
                    color: index < activeStepIndex ? AppColors.primary : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[index]['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCurrent
                            ? AppColors.primary
                            : (isCompleted ? AppColors.textPrimary : AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      steps[index]['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isCompleted ? AppColors.textSecondary : Colors.grey.shade400,
                      ),
                    ),
                    if (!isLast) const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Driver contact card
  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primaryPeach,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marco Rossi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Delivery Driver • 4.9 ★ (Vespa)',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
              onPressed: () {
                if (Get.context != null) {
                  Get.snackbar(
                    'Calling Driver',
                    'Dialing Marco Rossi at +1 (555) 432-8765...',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: const Color(0xFFF36C0A),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state illustration when no orders exist in current tab
  Widget _buildEmptyOrdersView({required bool isActiveTab}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.primaryPeach,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isActiveTab ? 'No Active Orders' : 'No Past Orders',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isActiveTab
                  ? 'You have no orders currently in the kitchen or on the road.'
                  : 'You haven\'t completed any orders yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (Get.isRegistered<MainNavController>()) {
                  Get.find<MainNavController>().changeTab(0); // Home
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Order Now', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatOrderDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

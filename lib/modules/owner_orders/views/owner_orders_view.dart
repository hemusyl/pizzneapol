import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../controllers/owner_orders_controller.dart';

/// Restaurant Owner & Kitchen Management view.
/// Allows the restaurant owner to monitor incoming orders in real time,
/// advance kitchen stages (In Oven, Out for Delivery, Delivered),
/// and trigger push notifications to customers.
class OwnerOrdersView extends GetView<OwnerOrdersController> {
  const OwnerOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Kitchen & Orders',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Restaurant Owner Dashboard',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Orders',
            onPressed: () => controller.loadOrders(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Dashboard Metrics Summary
          _buildMetricsOverview(),

          // 2. Filter Tabs
          _buildFilterTabs(),

          // 3. Orders List
          Expanded(
            child: Obx(() {
              final _ = controller.orders.length;
              final __ = controller.selectedFilterTab.value;
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final orders = controller.filteredOrders;
              if (orders.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.loadOrders,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (ctx, idx) => _buildOrderKitchenCard(ctx, orders[idx]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Top statistics overview for restaurant manager
  Widget _buildMetricsOverview() {
    return Obx(() {
      final _ = controller.orders.length;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _metricItem(
              title: 'Pending',
              value: '${controller.pendingCount}',
              color: const Color(0xFFF59E0B),
              icon: Icons.access_time_rounded,
            ),
            _divider(),
            _metricItem(
              title: 'In Oven',
              value: '${controller.preparingCount}',
              color: const Color(0xFFF36C0A),
              icon: Icons.local_fire_department_rounded,
            ),
            _divider(),
            _metricItem(
              title: 'Delivery',
              value: '${controller.deliveryCount}',
              color: const Color(0xFF3B82F6),
              icon: Icons.delivery_dining_rounded,
            ),
            _divider(),
            _metricItem(
              title: 'Sales',
              value: '\$${controller.todaySales.toStringAsFixed(0)}',
              color: const Color(0xFF10B981),
              icon: Icons.payments_outlined,
            ),
          ],
        ),
      );
    });
  }

  Widget _divider() => Container(
        height: 32,
        width: 1,
        color: AppColors.divider,
      );

  Widget _metricItem({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Segmented filter tabs
  Widget _buildFilterTabs() {
    final tabs = [
      'All',
      'New Orders',
      'In Oven',
      'Delivery',
      'Completed',
    ];

    return Obx(() {
      final selectedTab = controller.selectedFilterTab.value;
      return SizedBox(
        height: 44,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(tabs.length, (idx) {
              final isSelected = selectedTab == idx;
              return Padding(
                padding: EdgeInsets.only(right: idx < tabs.length - 1 ? 8 : 0),
                child: ChoiceChip(
                  label: Text(tabs[idx]),
                  selected: isSelected,
                  onSelected: (_) => controller.switchFilterTab(idx),
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  /// Individual order kitchen ticket card
  Widget _buildOrderKitchenCard(BuildContext context, OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header: ID + Status Badge + Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPeach,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(order.orderDate),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(order.status),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          // Items List
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.quantity}x',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black87,
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
                    '\$${(item.totalPrice).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Delivery details
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 15, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.deliveryAddress.isNotEmpty
                            ? order.deliveryAddress
                            : 'Pickup / Store delivery',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                if (order.deliveryNotes != null &&
                    order.deliveryNotes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.note_alt_outlined,
                          size: 15, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Note: ${order.deliveryNotes}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Total & Payment method
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${order.total.toStringAsFixed(2)} • ${order.paymentMethod}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // Custom Alert Icon Button
              TextButton.icon(
                icon: const Icon(Icons.send_rounded, size: 14),
                label: const Text('Push Alert', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _showCustomAlertDialog(context, order),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 4. Action Buttons (Kitchen Stages)
          _buildStageActionButtons(context, order),
        ],
      ),
    );
  }

  /// Status badge chip
  Widget _buildStatusBadge(OrderStatus status) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        icon = Icons.access_time_filled_rounded;
        break;
      case OrderStatus.confirmed:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4338CA);
        icon = Icons.check_circle_rounded;
        break;
      case OrderStatus.preparing:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFEA580C);
        icon = Icons.local_fire_department_rounded;
        break;
      case OrderStatus.outForDelivery:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF2563EB);
        icon = Icons.delivery_dining_rounded;
        break;
      case OrderStatus.delivered:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        icon = Icons.done_all_rounded;
        break;
      case OrderStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        icon = Icons.cancel_rounded;
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
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  /// Kitchen action buttons triggering stage progression & FCM notifications
  Widget _buildStageActionButtons(BuildContext context, OrderModel order) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Accept Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () =>
                    controller.updateOrderStatus(order, OrderStatus.confirmed),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Reject'),
              onPressed: () =>
                  controller.updateOrderStatus(order, OrderStatus.cancelled),
            ),
          ],
        );

      case OrderStatus.confirmed:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.local_fire_department_rounded, size: 16),
            label: const Text('🍕 Put in Stone Oven (Notify Customer)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () =>
                controller.updateOrderStatus(order, OrderStatus.preparing),
          ),
        );

      case OrderStatus.preparing:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delivery_dining_rounded, size: 18),
            label: const Text('🛵 Dispatch Rider (Notify Customer)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () =>
                controller.updateOrderStatus(order, OrderStatus.outForDelivery),
          ),
        );

      case OrderStatus.outForDelivery:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('✅ Mark as Delivered'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () =>
                controller.updateOrderStatus(order, OrderStatus.delivered),
          ),
        );

      case OrderStatus.delivered:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Order Complete & Delivered 🎉',
            style: TextStyle(
              color: Color(0xFF15803D),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        );

      case OrderStatus.cancelled:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Order Cancelled',
            style: TextStyle(
              color: Color(0xFFDC2626),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        );
    }
  }

  /// Dialog allowing restaurant owner to compose a custom push notification
  void _showCustomAlertDialog(BuildContext context, OrderModel order) {
    final titleCtrl = TextEditingController(text: 'Pizza Napoli Update');
    final messageCtrl =
        TextEditingController(text: 'Your order is being freshly baked with extra love!');

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Alert Order #${order.id}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send a custom push notification directly to this customer\'s device:',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: messageCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Message Body',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Push'),
            onPressed: () {
              Get.back();
              controller.sendCustomCustomerAlert(
                order: order,
                title: titleCtrl.text.trim(),
                message: messageCtrl.text.trim(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.kitchen_outlined, size: 64, color: Colors.black26),
          SizedBox(height: 12),
          Text(
            'No orders in this category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'New customer orders will appear here automatically',
            style: TextStyle(fontSize: 12, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.day}/${date.month}';
  }
}

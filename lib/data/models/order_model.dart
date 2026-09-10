import 'cart_item_model.dart';

/// Lifecycle statuses for customer orders.
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Completed customer order model.
class OrderModel {
  final String id;
  final List<CartItemModel> items;
  final String deliveryAddress;
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final DateTime orderDate;
  final OrderStatus status;
  final String? deliveryNotes;

  const OrderModel({
    required this.id,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.orderDate,
    this.status = OrderStatus.confirmed,
    this.deliveryNotes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      subtotal: (json['subtotal'] is num) ? (json['subtotal'] as num).toDouble() : 0.0,
      deliveryFee: (json['delivery_fee'] is num) ? (json['delivery_fee'] as num).toDouble() : 0.0,
      discount: (json['discount'] is num) ? (json['discount'] as num).toDouble() : 0.0,
      total: (json['total'] is num) ? (json['total'] as num).toDouble() : 0.0,
      orderDate: json['order_date'] != null
          ? DateTime.tryParse(json['order_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == (json['status']?.toString().toLowerCase() ?? 'confirmed'),
        orElse: () => OrderStatus.confirmed,
      ),
      deliveryNotes: json['delivery_notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((i) => i.toJson()).toList(),
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'discount': discount,
      'total': total,
      'order_date': orderDate.toIso8601String(),
      'status': status.name,
      'delivery_notes': deliveryNotes,
    };
  }

  OrderModel copyWith({
    String? id,
    List<CartItemModel>? items,
    String? deliveryAddress,
    String? paymentMethod,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? total,
    DateTime? orderDate,
    OrderStatus? status,
    String? deliveryNotes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
    );
  }
}

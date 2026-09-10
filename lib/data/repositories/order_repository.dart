import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../providers/api_provider.dart';

/// Abstract contract for Order repository operations.
abstract class IOrderRepository {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel?> getOrderById(String id);
  Future<OrderModel> createOrder(OrderModel order);
  Future<bool> updateOrderStatus(String id, OrderStatus status);
}

/// Repository managing customer orders.
/// Supports both local in-memory persistence and remote Laravel REST API synchronization.
class OrderRepository implements IOrderRepository {
  final ApiProvider? apiProvider;
  final List<OrderModel> _localOrders = [];

  OrderRepository({this.apiProvider}) {
    _initSampleOrders();
  }

  /// Whether the repository is connected to the remote Laravel API
  bool get isRemote => apiProvider != null;

  /// Synchronous local orders for immediate initialization
  List<OrderModel> get initialLocalOrders => List.unmodifiable(_localOrders);

  /// Populates initial realistic sample orders for demonstration/offline mode
  void _initSampleOrders() {
    final now = DateTime.now();

    const samplePizza = ProductModel(
      id: 1,
      name: 'Margarita',
      description: 'Cheese & Fresh Basil Tomato Sauce',
      price: 12.0,
      image: 'assets/images/pizza/margherita.png',
      categoryId: 1,
      categoryName: 'Pizza',
    );

    const samplePepperoni = ProductModel(
      id: 2,
      name: 'Classic Pepperoni',
      description: 'Pepperoni, Mozzarella & Herb Crust',
      price: 14.0,
      image: 'assets/images/pizza/pepperoni.png',
      categoryId: 1,
      categoryName: 'Pizza',
    );

    const sampleSalad = ProductModel(
      id: 6,
      name: 'Caesar Fresh Salad',
      description: 'Crisp Romaine, Parmesan, Croutons',
      price: 8.5,
      image: 'assets/images/salad/greek_salad.png',
      categoryId: 2,
      categoryName: 'Salad',
    );

    _localOrders.addAll([
      OrderModel(
        id: 'PZ-83921',
        items: [
          CartItemModel(
            product: samplePizza,
            selectedSize: 'Large',
            quantity: 1,
          ),
          CartItemModel(
            product: sampleSalad,
            selectedSize: 'Regular',
            quantity: 1,
          ),
        ],
        deliveryAddress: '29 Hola street, California, USA',
        paymentMethod: 'Credit / Debit Card',
        subtotal: 23.50,
        deliveryFee: 2.50,
        discount: 4.70,
        total: 21.30,
        orderDate: now.subtract(const Duration(minutes: 18)),
        status: OrderStatus.preparing,
        deliveryNotes: 'Please ring bell twice and leave at doorstep.',
      ),
      OrderModel(
        id: 'PZ-71249',
        items: [
          CartItemModel(
            product: samplePepperoni,
            selectedSize: 'Medium',
            quantity: 1,
          ),
        ],
        deliveryAddress: '42 Brooklyn Ave, Suite 4B, New York, USA',
        paymentMethod: 'Cash on Delivery',
        subtotal: 28.00,
        deliveryFee: 0.00,
        discount: 5.00,
        total: 23.00,
        orderDate: now.subtract(const Duration(days: 2, hours: 3)),
        status: OrderStatus.delivered,
      ),
    ]);
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final api = apiProvider;
    if (api != null) {
      try {
        final response = await api.getOrders();
        if (response.isOk && response.body != null) {
          final dynamic data =
              response.body is Map && response.body['data'] != null
                  ? response.body['data']
                  : response.body;

          if (data is List) {
            return data
                .map((item) =>
                    OrderModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {
        // Fallback to local data on connection failure
      }
    }
    return List.unmodifiable(_localOrders);
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    final api = apiProvider;
    if (api != null) {
      try {
        final response = await api.getOrderById(id);
        if (response.isOk && response.body != null) {
          final dynamic data =
              response.body is Map && response.body['data'] != null
                  ? response.body['data']
                  : response.body;

          if (data is Map<String, dynamic>) {
            return OrderModel.fromJson(data);
          }
        }
      } catch (_) {
        // Fallback to local search
      }
    }

    try {
      return _localOrders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    final api = apiProvider;
    if (api != null) {
      try {
        final response = await api.createOrder(order.toJson());
        if (response.isOk && response.body != null) {
          final dynamic data =
              response.body is Map && response.body['data'] != null
                  ? response.body['data']
                  : response.body;

          if (data is Map<String, dynamic>) {
            final created = OrderModel.fromJson(data);
            _localOrders.insert(0, created);
            return created;
          }
        }
      } catch (_) {
        // Continue with local save if backend is unreachable
      }
    }

    _localOrders.insert(0, order);
    return order;
  }

  @override
  Future<bool> updateOrderStatus(String id, OrderStatus status) async {
    final api = apiProvider;
    if (api != null) {
      try {
        final response =
            await api.updateOrderStatus(id, status.name);
        if (response.isOk) {
          _updateLocalStatus(id, status);
          return true;
        }
      } catch (_) {
        // Local fallback
      }
    }

    return _updateLocalStatus(id, status);
  }

  bool _updateLocalStatus(String id, OrderStatus status) {
    final index = _localOrders.indexWhere((o) => o.id == id);
    if (index != -1) {
      final old = _localOrders[index];
      _localOrders[index] = OrderModel(
        id: old.id,
        items: old.items,
        deliveryAddress: old.deliveryAddress,
        paymentMethod: old.paymentMethod,
        subtotal: old.subtotal,
        deliveryFee: old.deliveryFee,
        discount: old.discount,
        total: old.total,
        orderDate: old.orderDate,
        status: status,
        deliveryNotes: old.deliveryNotes,
      );
      return true;
    }
    return false;
  }
}

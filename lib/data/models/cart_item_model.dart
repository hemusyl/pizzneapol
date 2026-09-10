import 'product_model.dart';

/// Represents an item in the shopping cart with quantity and size selection.
class CartItemModel {
  final ProductModel product;
  final String selectedSize;
  int quantity;

  CartItemModel({
    required this.product,
    this.selectedSize = 'Medium',
    this.quantity = 1,
  });

  /// Total price for this cart item based on quantity
  double get totalPrice => product.price * quantity;

  /// Serialization to JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'selected_size': selectedSize,
      'quantity': quantity,
    };
  }

  /// Deserialization from JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      selectedSize: json['selected_size']?.toString() ?? 'Medium',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  CartItemModel copyWith({
    ProductModel? product,
    String? selectedSize,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      selectedSize: selectedSize ?? this.selectedSize,
      quantity: quantity ?? this.quantity,
    );
  }
}

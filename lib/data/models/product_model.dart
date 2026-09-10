/// Data model representing a Food/Pizza Product.
/// Supports both local JSON mock data and future Laravel REST API responses.
class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final int categoryId;
  final String categoryName;
  final bool available;
  final double rating;
  final List<String> sizes;
  final List<String> ingredients;
  final bool isPopular;
  final bool isFavorite;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.categoryId,
    required this.categoryName,
    this.available = true,
    this.rating = 4.8,
    this.sizes = const ['Small', 'Medium', 'Large'],
    this.ingredients = const [],
    this.isPopular = false,
    this.isFavorite = false,
  });

  /// Robust JSON parser supporting camelCase (client) and snake_case (Laravel API)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val, [double defaultVal = 0.0]) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? defaultVal;
      return defaultVal;
    }

    bool parseBool(dynamic val, [bool defaultVal = false]) {
      if (val is bool) return val;
      if (val is num) return val != 0;
      if (val is String) return val.toLowerCase() == 'true' || val == '1';
      return defaultVal;
    }

    return ProductModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: parseDouble(json['price']),
      image: json['image']?.toString() ?? '',
      categoryId: parseInt(json['category_id'] ?? json['categoryId']),
      categoryName: (json['category_name'] ?? json['categoryName'])?.toString() ?? '',
      available: parseBool(json['available'] ?? json['is_available'], true),
      rating: parseDouble(json['rating'], 4.8),
      sizes: json['sizes'] is List
          ? List<String>.from((json['sizes'] as List).map((e) => e.toString()))
          : const ['Small', 'Medium', 'Large'],
      ingredients: json['ingredients'] is List
          ? List<String>.from((json['ingredients'] as List).map((e) => e.toString()))
          : const [],
      isPopular: parseBool(json['is_popular'] ?? json['isPopular'], false),
      isFavorite: parseBool(json['is_favorite'] ?? json['isFavorite'], false),
    );
  }

  /// Serializes to JSON for caching or API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category_id': categoryId,
      'category_name': categoryName,
      'available': available,
      'rating': rating,
      'sizes': sizes,
      'ingredients': ingredients,
      'is_popular': isPopular,
      'is_favorite': isFavorite,
    };
  }

  /// Creates a modified copy of this ProductModel
  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? image,
    int? categoryId,
    String? categoryName,
    bool? available,
    double? rating,
    List<String>? sizes,
    List<String>? ingredients,
    bool? isPopular,
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      available: available ?? this.available,
      rating: rating ?? this.rating,
      sizes: sizes ?? this.sizes,
      ingredients: ingredients ?? this.ingredients,
      isPopular: isPopular ?? this.isPopular,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProductModel(id: $id, name: $name, price: \$$price)';
}

/// Data model representing a Food Category (e.g. Pizza, Salad, Dessert, Sides, Drinks).
class CategoryModel {
  final int id;
  final String name;
  final String image;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.isActive = true,
  });

  /// Factory constructor to parse JSON data from local files or Laravel REST API.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      isActive: json['is_active'] is bool
          ? json['is_active']
          : (json['isActive'] is bool ? json['isActive'] : true),
    );
  }

  /// Converts the CategoryModel instance to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'is_active': isActive,
    };
  }

  /// Creates a copy of this category with modified fields.
  CategoryModel copyWith({
    int? id,
    String? name,
    String? image,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoryModel(id: $id, name: $name)';
}

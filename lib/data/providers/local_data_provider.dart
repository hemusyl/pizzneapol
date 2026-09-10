import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Service provider responsible for reading and parsing mock JSON data from the assets folder.
/// Designed with standard methods that mirror future REST API endpoints.
class LocalDataProvider {
  static const String _categoriesPath = 'assets/data/categories.json';
  static const String _productsPath = 'assets/data/products.json';

  /// Loads all categories from local JSON
  Future<List<CategoryModel>> getCategories() async {
    try {
      final String jsonString = await rootBundle.loadString(_categoriesPath);
      final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;
      return data
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  /// Loads all products from local JSON
  Future<List<ProductModel>> getProducts() async {
    try {
      final String jsonString = await rootBundle.loadString(_productsPath);
      final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;
      return data
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  /// Filters products by category ID
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    final products = await getProducts();
    return products.where((item) => item.categoryId == categoryId).toList();
  }

  /// Finds a single product by its ID
  Future<ProductModel?> getProductById(int id) async {
    final products = await getProducts();
    try {
      return products.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Searches products by name, description, or category
  Future<List<ProductModel>> searchProducts(String query) async {
    final products = await getProducts();
    if (query.trim().isEmpty) return products;

    final lower = query.toLowerCase().trim();
    return products.where((item) {
      return item.name.toLowerCase().contains(lower) ||
          item.description.toLowerCase().contains(lower) ||
          item.categoryName.toLowerCase().contains(lower);
    }).toList();
  }
}

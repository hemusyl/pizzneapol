import '../models/product_model.dart';
import '../providers/api_provider.dart';
import '../providers/local_data_provider.dart';

/// Abstract contract for Product repository operations.
abstract class IProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getProductsByCategory(int categoryId);
  Future<ProductModel?> getProductById(int id);
  Future<List<ProductModel>> searchProducts(String query);
}

/// Repository for food products.
/// Insulates UI and controllers from whether data arrives from local JSON mock
/// or a live Laravel REST API backend.
class ProductRepository implements IProductRepository {
  final LocalDataProvider _localProvider;
  final ApiProvider? apiProvider;

  ProductRepository({
    LocalDataProvider? localProvider,
    this.apiProvider,
  }) : _localProvider = localProvider ?? LocalDataProvider();

  /// Whether the repository is communicating with remote Laravel API
  bool get isRemote => apiProvider != null;

  @override
  Future<List<ProductModel>> getProducts() async {
    if (apiProvider != null) {
      try {
        final response = await apiProvider!.getProducts();
        if (response.isOk && response.body != null) {
          final dynamic data =
              response.body is Map && response.body['data'] != null
                  ? response.body['data']
                  : response.body;

          if (data is List) {
            return data
                .map((item) =>
                    ProductModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {
        // Fallback to local data on connection error
      }
    }
    return await _localProvider.getProducts();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    if (apiProvider != null) {
      try {
        final response =
            await apiProvider!.getProducts(categoryId: categoryId);
        if (response.isOk && response.body != null) {
          final dynamic data =
              response.body is Map && response.body['data'] != null
                  ? response.body['data']
                  : response.body;

          if (data is List) {
            return data
                .map((item) =>
                    ProductModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {
        // Fallback to local data on connection error
      }
    }
    return await _localProvider.getProductsByCategory(categoryId);
  }

  @override
  Future<ProductModel?> getProductById(int id) async {
    if (apiProvider != null) {
      try {
        final response = await apiProvider!.getProductById(id);
        if (response.isOk && response.body != null) {
          final dynamic data =
              response.body is Map && response.body['data'] != null
                  ? response.body['data']
                  : response.body;

          if (data is Map<String, dynamic>) {
            return ProductModel.fromJson(data);
          }
        }
      } catch (_) {
        // Fallback to local data on connection error
      }
    }
    return await _localProvider.getProductById(id);
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    if (apiProvider != null) {
      try {
        final response = await apiProvider!.getProducts(search: query);
        if (response.isOk && response.body != null) {
          final dynamic data =
              response.body is Map && response.body['data'] != null
                  ? response.body['data']
                  : response.body;

          if (data is List) {
            return data
                .map((item) =>
                    ProductModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {
        // Fallback to local data on connection error
      }
    }
    return await _localProvider.searchProducts(query);
  }
}

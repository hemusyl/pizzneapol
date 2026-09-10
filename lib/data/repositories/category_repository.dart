import '../models/category_model.dart';
import '../providers/api_provider.dart';
import '../providers/local_data_provider.dart';

/// Abstract contract for Category repository operations.
abstract class ICategoryRepository {
  Future<List<CategoryModel>> getAllCategories();
}

/// Repository for food categories.
/// Insulates controllers from data origin, enabling instantaneous switching
/// between local mock JSON and remote Laravel REST API.
class CategoryRepository implements ICategoryRepository {
  final LocalDataProvider _localProvider;
  final ApiProvider? apiProvider;

  CategoryRepository({
    LocalDataProvider? localProvider,
    this.apiProvider,
  }) : _localProvider = localProvider ?? LocalDataProvider();

  /// Whether the repository is communicating with remote Laravel API
  bool get isRemote => apiProvider != null;

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    if (apiProvider != null) {
      try {
        final response = await apiProvider!.getCategories();
        if (response.isOk && response.body != null) {
          final dynamic data =
              response.body is Map && response.body['data'] != null
                  ? response.body['data']
                  : response.body;

          if (data is List) {
            return data
                .map((item) =>
                    CategoryModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {
        // Network fallback to local provider on failure
      }
    }
    return await _localProvider.getCategories();
  }
}

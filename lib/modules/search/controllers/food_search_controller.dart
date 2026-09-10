import 'package:get/get.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/product_repository.dart';

/// Controller managing real-time product search and category filtering.
class FoodSearchController extends GetxController {
  final CategoryRepository _categoryRepository;
  final ProductRepository _productRepository;

  FoodSearchController({
    CategoryRepository? categoryRepository,
    ProductRepository? productRepository,
  })  : _categoryRepository = categoryRepository ?? CategoryRepository(),
        _productRepository = productRepository ?? ProductRepository();

  /// Current search query string
  final RxString searchQuery = ''.obs;

  /// Selected filter category ID (0 means 'All')
  final RxInt selectedCategoryId = 0.obs;

  /// Loading state
  final RxBool isLoading = true.obs;

  /// Complete product catalog
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;

  /// Filtered search results
  final RxList<ProductModel> searchResults = <ProductModel>[].obs;

  /// Available categories for filter chips
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSearchData();
  }

  /// Loads products and categories for search
  Future<void> loadSearchData() async {
    try {
      isLoading.value = true;
      final loadedCategories = await _categoryRepository.getAllCategories();
      final loadedProducts = await _productRepository.getProducts();

      categories.assignAll(loadedCategories);
      allProducts.assignAll(loadedProducts);
      searchResults.assignAll(loadedProducts);
    } catch (e) {
      // Graceful fallback
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates search query text and immediately updates search results
  void onQueryChanged(String query) {
    searchQuery.value = query;
    filterResults();
  }

  /// Clears query input
  void clearQuery() {
    searchQuery.value = '';
    filterResults();
  }

  /// Sets category filter chip
  void selectCategoryFilter(int categoryId) {
    selectedCategoryId.value = categoryId;
    filterResults();
  }

  /// Recomputes searchResults based on query and category
  void filterResults() {
    final query = searchQuery.value.toLowerCase().trim();
    final catId = selectedCategoryId.value;

    final results = allProducts.where((product) {
      final matchesCategory = catId == 0 || product.categoryId == catId;
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;

      final matchesName = product.name.toLowerCase().contains(query);
      final matchesDesc = product.description.toLowerCase().contains(query);
      final matchesCatName = product.categoryName.toLowerCase().contains(query);
      final matchesIngredients = product.ingredients.any(
        (ing) => ing.toLowerCase().contains(query),
      );

      return matchesName || matchesDesc || matchesCatName || matchesIngredients;
    }).toList();

    searchResults.assignAll(results);
  }
}

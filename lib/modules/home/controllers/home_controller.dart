import 'package:get/get.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/product_repository.dart';

/// Main controller for the Home screen.
/// Manages category list, active category selection, product fetching, and filtering.
class HomeController extends GetxController {
  final CategoryRepository _categoryRepository;
  final ProductRepository _productRepository;

  HomeController({
    CategoryRepository? categoryRepository,
    ProductRepository? productRepository,
  })  : _categoryRepository = categoryRepository ?? CategoryRepository(),
        _productRepository = productRepository ?? ProductRepository();

  /// Loading state indicator
  final RxBool isLoading = true.obs;

  /// Error message if loading fails
  final RxString errorMessage = ''.obs;

  /// Observable list of categories for the horizontal category scrollbar
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  /// Full list of loaded products
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;

  /// Products currently displayed (filtered by selected category)
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  /// Currently active/selected category
  final Rxn<CategoryModel> selectedCategory = Rxn<CategoryModel>();

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  /// Loads categories and products from the repository
  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1. Fetch categories
      final loadedCategories = await _categoryRepository.getAllCategories();
      categories.assignAll(loadedCategories);

      // Select first category by default (e.g., Pizza) if available
      if (categories.isNotEmpty && selectedCategory.value == null) {
        selectedCategory.value = categories.first;
      }

      // 2. Fetch products
      final loadedProducts = await _productRepository.getProducts();
      allProducts.assignAll(loadedProducts);

      // 3. Filter products for the active category
      _applyCategoryFilter();
    } catch (e) {
      errorMessage.value = 'Failed to load menu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Selects a category and reactively filters the displayed products
  void selectCategory(CategoryModel category) {
    if (selectedCategory.value?.id == category.id) return;
    selectedCategory.value = category;
    _applyCategoryFilter();
  }

  /// Internal filter logic based on selectedCategory
  void _applyCategoryFilter() {
    if (selectedCategory.value == null) {
      filteredProducts.assignAll(allProducts);
    } else {
      final selectedId = selectedCategory.value!.id;
      final filtered = allProducts.where((p) => p.categoryId == selectedId).toList();
      filteredProducts.assignAll(filtered);
    }
  }

  /// Pull-to-refresh handler
  Future<void> refreshHomeData() async {
    await loadHomeData();
  }
}

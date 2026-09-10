import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../home/widgets/product_card.dart';
import '../controllers/food_search_controller.dart';

/// SearchScreen allowing users to find products in real-time by keyword,
/// description, ingredients, or category.
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final TextEditingController _textController;
  late final FoodSearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<FoodSearchController>()
        ? Get.find<FoodSearchController>()
        : Get.put(FoodSearchController());
    _textController = TextEditingController(text: _controller.searchQuery.value);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Food'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                return TextField(
                  controller: _textController,
                  onChanged: (val) => _controller.onQueryChanged(val),
                  decoration: InputDecoration(
                    hintText: 'Search pizza, salad, drinks, ingredients...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    suffixIcon: _controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              _textController.clear();
                              _controller.clearQuery();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                );
              }),
            ),
          ),

          // 2. Horizontal Filter Chips: All, Pizza, Salad, Dessert, Sides, Drinks
          SizedBox(
            height: 44,
            child: Obx(() {
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filterChip(
                    label: 'All',
                    categoryId: 0,
                    isSelected: _controller.selectedCategoryId.value == 0,
                    onTap: () => _controller.selectCategoryFilter(0),
                  ),
                  ..._controller.categories.map((cat) {
                    final isSelected = _controller.selectedCategoryId.value == cat.id;
                    return _filterChip(
                      label: cat.name,
                      categoryId: cat.id,
                      isSelected: isSelected,
                      onTap: () => _controller.selectCategoryFilter(cat.id),
                    );
                  }),
                ],
              );
            }),
          ),
          const SizedBox(height: 8),

          // 3. Search Results or Empty State
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value && _controller.allProducts.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (_controller.searchResults.isEmpty) {
                return _buildEmptySearchState(_controller);
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: _controller.searchResults.length,
                itemBuilder: (context, index) {
                  final product = _controller.searchResults[index];
                  return ProductCard(product: product);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required int categoryId,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildEmptySearchState(FoodSearchController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.primaryPeach,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Products Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'No results matching "${controller.searchQuery.value}".\nTry searching for something else.'
                  : 'No products available in this category.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

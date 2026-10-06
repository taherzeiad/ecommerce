import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/product_filter.dart';
import '../../categories/view_model/categories_view_model.dart';

/// Opens the filter screen and shows the matching products in search.
Future<void> openFilterThenSearch(BuildContext context) async {
  final filter = await Navigator.pushNamed(context, AppRoutes.filterSort);
  if (filter is ProductFilter && context.mounted) {
    Navigator.pushNamed(context, AppRoutes.search, arguments: filter);
  }
}

/// Sort order, price range and category. Pops with the chosen
/// [ProductFilter] when the user taps Apply.
class FilterSortView extends StatefulWidget {
  const FilterSortView({super.key, this.initialFilter = const ProductFilter()});

  final ProductFilter initialFilter;

  @override
  State<FilterSortView> createState() => _FilterSortViewState();
}

class _FilterSortViewState extends State<FilterSortView> {
  late ProductSort _sort;
  late RangeValues _priceRange;
  String? _category;

  @override
  void initState() {
    super.initState();
    _sort = widget.initialFilter.sort;
    _priceRange = RangeValues(
      widget.initialFilter.minPrice,
      widget.initialFilter.maxPrice,
    );
    _category = widget.initialFilter.category;
  }

  void _reset() {
    setState(() {
      _sort = ProductSort.popular;
      _priceRange = const RangeValues(0, ProductFilter.maxPriceLimit);
      _category = null;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      widget.initialFilter.copyWith(
        sort: _sort,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        category: _category,
        clearCategory: _category == null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('filter_sort'),
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: Text(
              context.tr('reset'),
              style: const TextStyle(color: AppColors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context.tr('sort_by')),
                  const SizedBox(height: 12),
                  _buildSortOptions(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context.tr('price_range')),
                  const SizedBox(height: 12),
                  _buildPriceSlider(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context.tr('categories')),
                  const SizedBox(height: 12),
                  _buildCategoryOptions(),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _apply,
                child: Text(context.tr('apply')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _box(Widget child) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      // Lets the tiles' ripples show above the coloured Container.
      child: Material(type: MaterialType.transparency, child: child),
    );
  }

  Widget _buildSortOptions() {
    return _box(
      RadioGroup<ProductSort>(
        groupValue: _sort,
        onChanged: (value) => setState(() => _sort = value ?? _sort),
        child: Column(
          children: [
            for (final option in ProductSort.values) ...[
              RadioListTile<ProductSort>(
                value: option,
                title: Text(context.tr(option.labelKey)),
                activeColor: AppColors.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              if (option != ProductSort.values.last)
                Divider(height: 1, color: Theme.of(context).dividerColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSlider() {
    return _box(
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatPrice(_priceRange.start),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _priceRange.end >= ProductFilter.maxPriceLimit
                      ? '${formatPrice(_priceRange.end)}+'
                      : formatPrice(_priceRange.end),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: ProductFilter.maxPriceLimit,
              divisions: 100,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.borderLight,
              onChanged: (val) => setState(() => _priceRange = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOptions() {
    final viewModel = context.watch<CategoriesViewModel>();
    if (viewModel.isLoading && viewModel.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final options = <String?>[null, ...viewModel.categories];
    return _box(
      RadioGroup<String?>(
        groupValue: _category,
        onChanged: (value) => setState(() => _category = value),
        child: Column(
          children: [
            for (final category in options) ...[
              RadioListTile<String?>(
                value: category,
                title: Text(
                  category == null
                      ? context.tr('all')
                      : context.tr(category.toLowerCase()),
                ),
                activeColor: AppColors.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              if (category != options.last)
                Divider(height: 1, color: Theme.of(context).dividerColor),
            ],
          ],
        ),
      ),
    );
  }
}

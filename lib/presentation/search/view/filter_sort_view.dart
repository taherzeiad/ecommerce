import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';

class FilterSortView extends StatefulWidget {
  const FilterSortView({super.key});

  @override
  State<FilterSortView> createState() => _FilterSortViewState();
}

class _FilterSortViewState extends State<FilterSortView> {
  String _selectedSort = 'Popular';
  RangeValues _priceRange = const RangeValues(25, 250);
  String _selectedCategory = 'Phone';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('filter_sort'), // Should add 'filter_sort' key
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedSort = 'Popular';
                _priceRange = const RangeValues(25, 250);
                _selectedCategory = 'Phone';
              });
            },
            child: Text(
              context.tr('reset'), // Should add 'reset' key
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
                  _buildSectionTitle(context.tr('sort_by')), // Should add 'sort_by' key
                  const SizedBox(height: 12),
                  _buildSortOptions(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context.tr('price_range')), // Should add 'price_range' key
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
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('apply')),
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

  Widget _buildSortOptions() {
    final options = ['Popular', 'Newest', 'Price : Low To High', 'Price : High To Low'];
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: options.map((option) {
          final isLast = options.last == option;
          return Column(
            children: [
              RadioListTile<String>(
                value: option,
                groupValue: _selectedSort,
                onChanged: (val) => setState(() => _selectedSort = val!),
                title: Text(context.tr(option.toLowerCase().replaceAll(' ', '_').replaceAll(':', '').replaceAll('__', '_'))),
                activeColor: AppColors.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              if (!isLast) Divider(height: 1, color: Theme.of(context).dividerColor),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${_priceRange.start.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('\$${_priceRange.end.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 500,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.borderLight,
            onChanged: (val) => setState(() => _priceRange = val),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryOptions() {
    final categories = ['Phone', 'Audio', 'Fashion', 'Camera'];
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: categories.map((cat) {
          final isLast = categories.last == cat;
          final isSelected = _selectedCategory == cat;
          return Column(
            children: [
              CheckboxListTile(
                value: isSelected,
                onChanged: (val) => setState(() => _selectedCategory = cat),
                title: Text(context.tr(cat.toLowerCase())),
                activeColor: AppColors.primary,
                checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              if (!isLast) Divider(height: 1, color: Theme.of(context).dividerColor),
            ],
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

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
        title: const Text(
          'Filter & Sort',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.white, fontSize: 16),
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
                  _buildSectionTitle('Sort By'),
                  const SizedBox(height: 12),
                  _buildSortOptions(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Price Range'),
                  const SizedBox(height: 12),
                  _buildPriceSlider(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Categories'),
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
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B1B29),
      ),
    );
  }

  Widget _buildSortOptions() {
    final options = ['Popular', 'Newest', 'Price : Low To High', 'Price : High To Low'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F1F1)),
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
                title: Text(option),
                activeColor: AppColors.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              if (!isLast) const Divider(height: 1, color: Color(0xFFF1F1F1)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F1F1)),
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
            inactiveColor: const Color(0xFFE0E0E0),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F1F1)),
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
                title: Text(cat),
                activeColor: AppColors.primary,
                checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              if (!isLast) const Divider(height: 1, color: Color(0xFFF1F1F1)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

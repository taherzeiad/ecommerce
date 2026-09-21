import 'package:flutter/material.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';

class CategoriesViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  CategoriesViewModel({required ProductRepository productRepository})
      : _productRepository = productRepository;

  List<ProductEntity> _categoryProducts = [];
  List<ProductEntity> get categoryProducts => _categoryProducts;

  List<String> _categories = [];
  List<String> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedCategory = '';
  String get selectedCategory => _selectedCategory;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _productRepository.getCategories();
      if (_categories.isNotEmpty && _selectedCategory.isEmpty) {
        await fetchProductsByCategory(_categories.first);
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    _selectedCategory = category;
    _isLoading = true;
    notifyListeners();

    try {
      _categoryProducts = await _productRepository.getProductsByCategory(category);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

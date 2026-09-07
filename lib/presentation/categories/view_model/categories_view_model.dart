import 'package:flutter/material.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';

class CategoriesViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  CategoriesViewModel({required ProductRepository productRepository})
      : _productRepository = productRepository;

  List<ProductEntity> _categoryProducts = [];
  List<ProductEntity> get categoryProducts => _categoryProducts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedCategory = 'Smartphones';
  String get selectedCategory => _selectedCategory;

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

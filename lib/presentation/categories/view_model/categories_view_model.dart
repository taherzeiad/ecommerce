import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';

/// Which products the "All products" screen lists.
enum ProductCollection { category, flashDeals, all }

class CategoriesViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  CategoriesViewModel({required ProductRepository productRepository})
      : _productRepository = productRepository;

  List<ProductEntity> _categoryProducts = [];
  List<ProductEntity> get categoryProducts => _categoryProducts;

  List<String> _categories = [];
  List<String> get categories => _categories;

  Map<String, int> _categoryCounts = {};
  Map<String, int> get categoryCounts => _categoryCounts;

  bool _isLoadingCategories = false;
  bool _isLoadingProducts = false;
  bool get isLoading => _isLoadingCategories || _isLoadingProducts;
  bool get isLoadingProducts => _isLoadingProducts;

  String? _errorMessage;

  /// Translation key of the last failed load.
  String? get errorMessage => _errorMessage;

  String _selectedCategory = '';
  String get selectedCategory => _selectedCategory;

  ProductCollection _collection = ProductCollection.category;
  ProductCollection get collection => _collection;

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _productRepository.getCategories(),
        _productRepository.getCategoryProductCounts(),
      ]);
      _categories = results[0] as List<String>;
      _categoryCounts = results[1] as Map<String, int>;

      if (_categories.isNotEmpty &&
          _selectedCategory.isEmpty &&
          _collection == ProductCollection.category) {
        await fetchProductsByCategory(_categories.first);
      }
    } catch (e) {
      _errorMessage = errorKeyFor(e);
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsByCategory(String category) {
    _collection = ProductCollection.category;
    _selectedCategory = category;
    return _loadProducts(
      () => _productRepository.getProductsByCategory(category),
    );
  }

  Future<void> showFlashDeals() {
    _collection = ProductCollection.flashDeals;
    _selectedCategory = '';
    return _loadProducts(_productRepository.getFlashDeals);
  }

  Future<void> showAllProducts() {
    _collection = ProductCollection.all;
    _selectedCategory = '';
    return _loadProducts(_productRepository.getPopularProducts);
  }

  /// Reloads whatever failed or is currently shown.
  Future<void> retry() async {
    if (_categories.isEmpty) await fetchCategories();
    switch (_collection) {
      case ProductCollection.flashDeals:
        await showFlashDeals();
      case ProductCollection.all:
        await showAllProducts();
      case ProductCollection.category:
        if (_selectedCategory.isNotEmpty) {
          await fetchProductsByCategory(_selectedCategory);
        }
    }
  }

  Future<void> _loadProducts(
    Future<List<ProductEntity>> Function() load,
  ) async {
    _isLoadingProducts = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categoryProducts = await load();
    } catch (e) {
      _errorMessage = errorKeyFor(e);
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }
}

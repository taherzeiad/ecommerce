import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  HomeViewModel({required ProductRepository productRepository})
      : _productRepository = productRepository;

  List<ProductEntity> _popularProducts = [];

  List<ProductEntity> get popularProducts => _popularProducts;

  List<ProductEntity> _flashDeals = [];
  List<ProductEntity> get flashDeals => _flashDeals;

  List<String> _categories = [];
  List<String> get categories => _categories;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  /// Translation key of the last failed load, `null` when it worked.
  String? get errorMessage => _errorMessage;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _productRepository.getPopularProducts(),
        _productRepository.getFlashDeals(),
        _productRepository.getCategories(),
      ]);
      _popularProducts = results[0] as List<ProductEntity>;
      _flashDeals = results[1] as List<ProductEntity>;
      _categories = results[2] as List<String>;
    } catch (e) {
      _errorMessage = errorKeyFor(e);
      _popularProducts = [];
      _flashDeals = [];
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

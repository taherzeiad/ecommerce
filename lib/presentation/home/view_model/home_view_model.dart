import 'package:flutter/material.dart';
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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _productRepository.getPopularProducts(),
        _productRepository.getFlashDeals(),
      ]);
      _popularProducts = results[0];
      _flashDeals = results[1];
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

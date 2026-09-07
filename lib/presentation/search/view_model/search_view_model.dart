import 'package:flutter/material.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  SearchViewModel({required ProductRepository productRepository})
      : _productRepository = productRepository;

  List<ProductEntity> _results = [];
  List<ProductEntity> get results => _results;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _query = '';
  String get query => _query;

  Future<void> search(String query) async {
    _query = query;
    if (query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _results = await _productRepository.searchProducts(query);
    } catch (e) {
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

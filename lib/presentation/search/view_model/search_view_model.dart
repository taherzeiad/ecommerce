import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/product_filter.dart';
import '../../../domain/repositories/product_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  SearchViewModel({
    required ProductRepository productRepository,
    ProductFilter? initialFilter,
  }) : _productRepository = productRepository {
    if (initialFilter != null) applyFilter(initialFilter);
  }

  List<ProductEntity> _results = [];
  List<ProductEntity> get results => _results;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProductFilter _filter = const ProductFilter();
  ProductFilter get filter => _filter;

  String get query => _filter.query;

  List<String> _suggestions = [];

  /// Categories offered as one-tap searches before anything is typed.
  List<String> get suggestions => _suggestions;

  Future<void> loadSuggestions() async {
    try {
      _suggestions = await _productRepository.getCategories();
      notifyListeners();
    } catch (e) {
      // Suggestions are optional.
    }
  }

  /// True once a search or filter was run, so the screen shows results
  /// (or "no results") instead of the suggestions.
  bool get hasSearched => _filter.query.trim().isNotEmpty || _filter.hasOptions;

  Future<void> search(String query) => _run(_filter.copyWith(query: query));

  /// Keeps the current search text and replaces the filter options.
  Future<void> applyFilter(ProductFilter filter) =>
      _run(filter.copyWith(query: _filter.query));

  Future<void> retry() => _run(_filter);

  Future<void> _run(ProductFilter filter) async {
    _filter = filter;
    _errorMessage = null;
    if (!hasSearched) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _results = await _productRepository.getProducts(filter);
    } catch (e) {
      _results = [];
      _errorMessage = errorKeyFor(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

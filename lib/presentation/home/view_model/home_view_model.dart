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

  bool _hasNewNotifications = false; // Hidden by default
  bool get hasNewNotifications => _hasNewNotifications;

  void markNotificationsAsRead() {
    if (_hasNewNotifications) {
      _hasNewNotifications = false;
      notifyListeners();
    }
  }

  // Use this method to trigger the badge (for testing or real push)
  void simulateNewNotification() {
    _hasNewNotifications = true;
    notifyListeners();
  }

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

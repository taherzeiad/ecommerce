import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/wishlist_repository.dart';

class WishlistViewModel extends ChangeNotifier {
  final WishlistRepository _wishlistRepository;

  WishlistViewModel({required WishlistRepository wishlistRepository})
      : _wishlistRepository = wishlistRepository;

  List<ProductEntity> _items = [];
  List<ProductEntity> get items => List.unmodifiable(_items);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;

  /// Translation key of the last failed load, `null` when it worked.
  String? get errorMessage => _errorMessage;

  Future<void> fetchWishlist() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _wishlistRepository.getWishlist();
    } catch (e) {
      _errorMessage = errorKeyFor(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds or removes [product]. Returns `false` when the change failed.
  Future<bool> toggleWishlist(ProductEntity product) async {
    try {
      await _wishlistRepository.toggleWishlist(product.id);
    } catch (e) {
      return false;
    }
    await fetchWishlist();
    return true;
  }

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }
}

import 'package:flutter/material.dart';
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

  Future<void> fetchWishlist() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _wishlistRepository.getWishlist();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(ProductEntity product) async {
    try {
      await _wishlistRepository.toggleWishlist(product.id);
      await fetchWishlist();
    } catch (e) {
      // Handle error
    }
  }

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }
}

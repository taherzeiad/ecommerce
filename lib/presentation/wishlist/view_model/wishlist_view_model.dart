import 'package:flutter/material.dart';
import '../../../domain/entities/product_entity.dart';

class WishlistViewModel extends ChangeNotifier {
  final List<ProductEntity> _items = [];

  List<ProductEntity> get items => List.unmodifiable(_items);

  void toggleWishlist(ProductEntity product) {
    final index = _items.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _items.removeAt(index);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }
}

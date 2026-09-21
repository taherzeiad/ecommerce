import '../entities/product_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCartItems();
  Future<void> addToCart(String productId, int quantity);
  Future<void> removeFromCart(dynamic cartItemId);
  Future<void> updateQuantity(dynamic cartItemId, int quantity);
  Future<void> clearCart();
}

class CartItemEntity {
  final dynamic id;
  final ProductEntity product;
  final int quantity;

  CartItemEntity({
    required this.id,
    required this.product,
    required this.quantity,
  });
}

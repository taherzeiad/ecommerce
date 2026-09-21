import '../entities/product_entity.dart';

abstract class WishlistRepository {
  Future<List<ProductEntity>> getWishlist();
  Future<void> toggleWishlist(String productId);
  Future<bool> isInWishlist(String productId);
}

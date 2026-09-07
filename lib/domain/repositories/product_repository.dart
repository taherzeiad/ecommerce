import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getPopularProducts();
  Future<List<ProductEntity>> getFlashDeals();
  Future<List<ProductEntity>> getProductsByCategory(String category);
  Future<List<ProductEntity>> searchProducts(String query);
}

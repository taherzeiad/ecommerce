import '../entities/product_entity.dart';
import '../entities/product_filter.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getPopularProducts();

  Future<List<ProductEntity>> getFlashDeals();

  Future<List<ProductEntity>> getProductsByCategory(String category);

  Future<List<ProductEntity>> searchProducts(String query);

  /// Products matching the search text and filter options, in filter order.
  Future<List<ProductEntity>> getProducts(ProductFilter filter);

  Future<List<String>> getCategories();

  Future<Map<String, int>> getCategoryProductCounts();
}

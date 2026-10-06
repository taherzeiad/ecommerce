import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class SupabaseProductRepository implements ProductRepository {
  final SupabaseClient _supabaseClient;

  SupabaseProductRepository(this._supabaseClient);

  List<ProductEntity> _toProducts(List<Map<String, dynamic>> rows) =>
      rows.map(ProductModel.fromJson).toList();

  @override
  Future<List<ProductEntity>> getPopularProducts() async {
    final response = await _supabaseClient
        .from('products')
        .select()
        .order('rating', ascending: false);
    return _toProducts(response);
  }

  @override
  Future<List<ProductEntity>> getFlashDeals() async {
    final response = await _supabaseClient
        .from('products')
        .select()
        .eq('is_flash_deal', true);
    return _toProducts(response);
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    final response = await _supabaseClient
        .from('products')
        .select()
        .eq('category_name', category);
    return _toProducts(response);
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) =>
      getProducts(ProductFilter(query: query));

  @override
  Future<List<ProductEntity>> getProducts(ProductFilter filter) async {
    var query = _supabaseClient.from('products').select();
    final text = filter.query.trim();
    if (text.isNotEmpty) query = query.ilike('name', '%$text%');
    if (filter.category != null) {
      query = query.eq('category_name', filter.category!);
    }
    if (filter.minPrice > 0) query = query.gte('price', filter.minPrice);
    if (filter.maxPrice < ProductFilter.maxPriceLimit) {
      query = query.lte('price', filter.maxPrice);
    }

    final response = await switch (filter.sort) {
      ProductSort.popular => query.order('rating', ascending: false),
      ProductSort.newest => query.order('created_at', ascending: false),
      ProductSort.priceLowToHigh => query.order('price', ascending: true),
      ProductSort.priceHighToLow => query.order('price', ascending: false),
    };
    return _toProducts(response);
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await _supabaseClient.from('categories').select('name');
    final names = response.map((json) => json['name'] as String).toList();
    if (names.isNotEmpty) return names;

    // The categories table can be empty or unreadable; the products still
    // say which categories exist.
    final counts = await getCategoryProductCounts();
    return counts.keys.toList();
  }

  @override
  Future<Map<String, int>> getCategoryProductCounts() async {
    final response = await _supabaseClient
        .from('products')
        .select('category_name');

    final Map<String, int> counts = {};
    for (final item in response) {
      final category = item['category_name'] as String?;
      if (category == null) continue;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }
}

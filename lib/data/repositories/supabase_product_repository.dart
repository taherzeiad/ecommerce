import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class SupabaseProductRepository implements ProductRepository {
  final SupabaseClient _supabaseClient;

  SupabaseProductRepository(this._supabaseClient);

  @override
  Future<List<ProductEntity>> getPopularProducts() async {
    final response = await _supabaseClient
        .from('products')
        .select()
        .order('rating', ascending: false);
    
    return (response as List<dynamic>)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductEntity>> getFlashDeals() async {
    final response = await _supabaseClient
        .from('products')
        .select()
        .eq('is_flash_deal', true);

    return (response as List<dynamic>)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    final response = await _supabaseClient
        .from('products')
        .select()
        .eq('category_name', category);

    return (response as List<dynamic>)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    final response = await _supabaseClient
        .from('products')
        .select()
        .ilike('name', '%$query%');

    return (response as List<dynamic>)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

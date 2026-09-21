import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../models/product_model.dart';

class SupabaseWishlistRepository implements WishlistRepository {
  final SupabaseClient _supabaseClient;

  SupabaseWishlistRepository(this._supabaseClient);

  @override
  Future<List<ProductEntity>> getWishlist() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return [];

    final response = await _supabaseClient
        .from('wishlist')
        .select('*, products(*)')
        .eq('user_id', user.id);

    return (response as List<dynamic>).map((item) {
      return ProductModel.fromJson(item['products'] as Map<String, dynamic>);
    }).toList();
  }

  @override
  Future<void> toggleWishlist(String productId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    final existing = await _supabaseClient
        .from('wishlist')
        .select()
        .eq('user_id', user.id)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      await _supabaseClient
          .from('wishlist')
          .delete()
          .eq('user_id', user.id)
          .eq('product_id', productId);
    } else {
      await _supabaseClient.from('wishlist').insert({
        'user_id': user.id,
        'product_id': productId,
      });
    }
  }

  @override
  Future<bool> isInWishlist(String productId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return false;

    final response = await _supabaseClient
        .from('wishlist')
        .select()
        .eq('user_id', user.id)
        .eq('product_id', productId)
        .maybeSingle();
    
    return response != null;
  }
}

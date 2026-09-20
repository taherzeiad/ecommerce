import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseWishlistRepository {
  final SupabaseClient _supabaseClient;

  SupabaseWishlistRepository(this._supabaseClient);

  Future<List<Map<String, dynamic>>> fetchWishlist() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return [];

    return await _supabaseClient
        .from('wishlist')
        .select('*, products(*)')
        .eq('user_id', user.id);
  }

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
}

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCartRepository {
  final SupabaseClient _supabaseClient;

  SupabaseCartRepository(this._supabaseClient);

  Future<List<Map<String, dynamic>>> fetchCartItems() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return [];
    
    return await _supabaseClient
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', user.id);
  }

  Future<void> addToCart(String productId, int quantity) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    await _supabaseClient.from('cart_items').upsert({
      'user_id': user.id,
      'product_id': productId,
      'quantity': quantity,
    });
  }

  Future<void> removeFromCart(int cartItemId) async {
    await _supabaseClient.from('cart_items').delete().eq('id', cartItemId);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/product_model.dart';

class SupabaseCartRepository implements CartRepository {
  final SupabaseClient _supabaseClient;

  SupabaseCartRepository(this._supabaseClient);

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return [];
    
    final response = await _supabaseClient
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', user.id);

    return (response as List<dynamic>).map((item) {
      return CartItemEntity(
        id: item['id'],
        product: ProductModel.fromJson(item['products'] as Map<String, dynamic>),
        quantity: item['quantity'] as int,
      );
    }).toList();
  }

  @override
  Future<void> addToCart(String productId, int quantity) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    await _supabaseClient.from('cart_items').upsert({
      'user_id': user.id,
      'product_id': productId,
      'quantity': quantity,
    });
  }

  @override
  Future<void> removeFromCart(dynamic cartItemId) async {
    await _supabaseClient.from('cart_items').delete().eq('id', cartItemId);
  }

  @override
  Future<void> updateQuantity(dynamic cartItemId, int quantity) async {
    await _supabaseClient
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', cartItemId);
  }

  @override
  Future<void> clearCart() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;
    await _supabaseClient.from('cart_items').delete().eq('user_id', user.id);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient _supabaseClient;

  SupabaseOrderRepository(this._supabaseClient);

  @override
  Future<List<OrderEntity>> getOrders() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return [];

    final response = await _supabaseClient
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return response.map(OrderModel.fromJson).toList();
  }

  @override
  Future<OrderEntity?> getOrder(String orderId) async {
    final response = await _supabaseClient
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .maybeSingle();
    return response == null ? null : OrderModel.fromJson(response);
  }

  @override
  Future<String> placeOrder({
    required String addressId,
    required PaymentMethod paymentMethod,
    String? cardLast4,
    String? couponCode,
  }) async {
    // See supabase/migrations: place_order() prices the cart on the server.
    final orderId = await _supabaseClient.rpc(
      'place_order',
      params: {
        'p_address_id': int.parse(addressId),
        'p_payment_method': paymentMethod.name,
        'p_card_last4': cardLast4,
        'p_coupon_code': couponCode,
      },
    );
    return orderId as String;
  }
}

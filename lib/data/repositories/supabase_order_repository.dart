import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient _supabaseClient;

  SupabaseOrderRepository(this._supabaseClient);

  @override
  Future<List<OrderEntity>> getOrders() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return [];

    final response = await _supabaseClient
        .from('orders')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((json) {
      return OrderEntity(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        totalAmount: (json['total_amount'] as num).toDouble(),
        status: json['status'] as String,
        addressId: json['address_id'],
        createdAt: DateTime.parse(json['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<void> createOrder(double totalAmount, dynamic addressId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    await _supabaseClient.from('orders').insert({
      'user_id': user.id,
      'total_amount': totalAmount,
      'address_id': addressId,
      'status': 'pending',
    });
  }
}

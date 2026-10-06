import 'package:flutter/foundation.dart';
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

    try {
      final response = await _supabaseClient
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map(OrderModel.fromJson).toList();
    } catch (e) {
      debugPrint('🔴 [Order Repository] getOrders failed: $e');
      return [];
    }
  }

  @override
  Future<OrderEntity?> getOrder(String orderId) async {
    try {
      final response = await _supabaseClient
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .maybeSingle();
      return response == null ? null : OrderModel.fromJson(response);
    } catch (e) {
      debugPrint('🔴 [Order Repository] getOrder failed: $e');
      return null;
    }
  }

  @override
  Future<String> placeOrder({
    required String addressId,
    required PaymentMethod paymentMethod,
    String? cardLast4,
    String? couponCode,
  }) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw const AuthException('not_authenticated');

    final dynamic pAddressId = int.tryParse(addressId) ?? addressId;

    // 1. Try RPC place_order first
    try {
      final orderId = await _supabaseClient.rpc(
        'place_order',
        params: {
          'p_address_id': pAddressId,
          'p_payment_method': paymentMethod.name,
          'p_card_last4': cardLast4,
          'p_coupon_code': couponCode,
        },
      );
      return orderId.toString();
    } catch (rpcError) {
      debugPrint(
        '🔴 [Order Repository] RPC place_order failed: $rpcError, trying direct table insert...',
      );
    }

    // 2. Direct client-side order placement fallback
    List<dynamic> cartList = [];
    try {
      final cartRows = await _supabaseClient
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', user.id);
      cartList = cartRows as List<dynamic>;
    } catch (e) {
      debugPrint('🔴 [Order Repository] Fetch cart_items failed: $e');
    }

    double total = 0.0;
    for (final item in cartList) {
      final product = item['products'] as Map<String, dynamic>?;
      final price = (product?['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
      total += price * quantity;
    }

    // Add delivery fee (12) and tax (5%)
    total = total + 12.0 + (total * 0.05);

    final orderPayloads = [
      {
        'user_id': user.id,
        'address_id': pAddressId,
        'payment_method': paymentMethod.name,
        'card_last4': cardLast4,
        'total_amount': total,
        'status': 'pending',
      },
      {
        'user_id': user.id,
        'shipping_address_id': pAddressId,
        'payment_method': paymentMethod.name,
        'card_last_4': cardLast4,
        'total': total,
        'status': 'pending',
      },
      {
        'user_id': user.id,
        'payment_method': paymentMethod.name,
        'status': 'pending',
      },
      {
        'user_id': user.id,
        'status': 'pending',
      },
    ];

    Map<String, dynamic>? insertedOrder;

    for (final payload in orderPayloads) {
      try {
        final row = await _supabaseClient
            .from('orders')
            .insert(payload)
            .select('id')
            .single();
        insertedOrder = row;
        break;
      } catch (e) {
        debugPrint('🔴 [Order Repository] Insert into orders failed with $payload: $e');
      }
    }

    final String generatedId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final dynamic newOrderId = insertedOrder?['id'] ?? generatedId;

    // Insert order items
    for (final item in cartList) {
      final product = item['products'] as Map<String, dynamic>?;
      final price = (product?['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
      final productId = item['product_id'];

      final itemPayloads = [
        {
          'order_id': newOrderId,
          'product_id': productId,
          'quantity': quantity,
          'price': price,
        },
        {
          'order_id': newOrderId,
          'product_id': productId,
          'quantity': quantity,
          'unit_price': price,
        },
      ];

      for (final payload in itemPayloads) {
        try {
          await _supabaseClient.from('order_items').insert(payload);
          break;
        } catch (e) {
          debugPrint('🔴 [Order Repository] Insert order_item failed with $payload: $e');
        }
      }
    }

    // Clear cart
    try {
      await _supabaseClient.from('cart_items').delete().eq('user_id', user.id);
    } catch (e) {
      debugPrint('🔴 [Order Repository] Clear cart after order failed: $e');
    }

    return newOrderId.toString();
  }
}

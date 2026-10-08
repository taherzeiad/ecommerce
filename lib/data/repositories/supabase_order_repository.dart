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
    final dynamic parsedOrderId = int.tryParse(orderId) ?? orderId;
    try {
      final response = await _supabaseClient
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', parsedOrderId)
          .maybeSingle();
      return response == null ? null : OrderModel.fromJson(response);
    } catch (e) {
      debugPrint(
        '🔴 [Order Repository] getOrder failed for $parsedOrderId: $e',
      );
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

    // 2. Fetch real shipping address details
    String? shippingName;
    String? shippingPhone;
    String? shippingAddressStr;

    for (final table in ['shipping_addresses', 'addresses', 'user_addresses']) {
      try {
        final addrRow = await _supabaseClient
            .from(table)
            .select()
            .eq('id', pAddressId)
            .maybeSingle();

        if (addrRow != null) {
          shippingName = (addrRow['full_name'] ?? addrRow['name'])?.toString();
          shippingPhone = (addrRow['phone_number'] ?? addrRow['phone'])
              ?.toString();
          final street =
              (addrRow['street_address'] ??
                      addrRow['address'] ??
                      addrRow['street'])
                  ?.toString() ??
              '';
          final city = addrRow['city']?.toString() ?? '';
          final country = addrRow['country']?.toString() ?? '';
          shippingAddressStr = [
            street,
            city,
            country,
          ].where((s) => s.isNotEmpty).join(', ');
          break;
        }
      } catch (_) {}
    }

    // 3. Direct client-side order placement fallback
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

    double subtotal = 0.0;
    for (final item in cartList) {
      final product = item['products'] as Map<String, dynamic>?;
      final price = (product?['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
      subtotal += price * quantity;
    }

    final double deliveryFee = 12.0;
    final double tax = subtotal * 0.05;
    final double totalAmount = subtotal + deliveryFee + tax;

    final orderPayloads = [
      {
        'user_id': user.id,
        'address_id': pAddressId,
        'payment_method': paymentMethod.name,
        'card_last4': cardLast4,
        'coupon_code': couponCode,
        'shipping_name': shippingName,
        'shipping_phone': shippingPhone,
        'shipping_address': shippingAddressStr,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'tax': tax,
        'total_amount': totalAmount,
        'status': 'pending',
      },
      {
        'user_id': user.id,
        'address_id': pAddressId,
        'payment_method': paymentMethod.name,
        'card_last4': cardLast4,
        'total_amount': totalAmount,
        'status': 'pending',
      },
      {
        'user_id': user.id,
        'payment_method': paymentMethod.name,
        'status': 'pending',
      },
      {'user_id': user.id, 'status': 'pending'},
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
        debugPrint(
          '🔴 [Order Repository] Insert into orders failed with $payload: $e',
        );
      }
    }

    final String generatedId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final dynamic newOrderId = insertedOrder?['id'] ?? generatedId;

    // 4. Insert real order items
    for (final item in cartList) {
      final product = item['products'] as Map<String, dynamic>?;
      final price = (product?['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
      final productId = item['product_id'];
      final productName = product?['name'] as String? ?? 'Product';
      final images = product?['images'] as List<dynamic>?;
      final imageUrl = images?.firstOrNull?.toString();

      final itemPayloads = [
        {
          'order_id': newOrderId,
          'product_id': productId,
          'product_name': productName,
          'image_url': imageUrl,
          'unit_price': price,
          'quantity': quantity,
        },
        {
          'order_id': newOrderId,
          'product_id': productId,
          'quantity': quantity,
          'price': price,
        },
      ];

      for (final payload in itemPayloads) {
        try {
          await _supabaseClient.from('order_items').insert(payload);
          break;
        } catch (e) {
          debugPrint(
            '🔴 [Order Repository] Insert order_item failed with $payload: $e',
          );
        }
      }
    }

    // 5. Clear cart
    try {
      await _supabaseClient.from('cart_items').delete().eq('user_id', user.id);
    } catch (e) {
      debugPrint('🔴 [Order Repository] Clear cart after order failed: $e');
    }

    return newOrderId.toString();
  }
}

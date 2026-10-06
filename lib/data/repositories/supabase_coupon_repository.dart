import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/coupon_repository.dart';

class SupabaseCouponRepository implements CouponRepository {
  final SupabaseClient _supabaseClient;

  SupabaseCouponRepository(this._supabaseClient);

  @override
  Future<CouponEntity?> findCoupon(String code) async {
    final row = await _supabaseClient
        .from('coupons')
        .select('code, discount_percent, min_order, expires_at')
        .eq('code', code.trim().toUpperCase())
        .eq('active', true)
        .maybeSingle();
    if (row == null) return null;

    final expiresAt = row['expires_at'] as String?;
    return CouponEntity(
      code: row['code'] as String,
      discountPercent: row['discount_percent'] as int,
      minOrder: (row['min_order'] as num?)?.toDouble() ?? 0,
      expiresAt: expiresAt == null ? null : DateTime.parse(expiresAt),
    );
  }
}

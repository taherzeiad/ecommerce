class CouponEntity {
  final String code;
  final int discountPercent;
  final double minOrder;
  final DateTime? expiresAt;

  const CouponEntity({
    required this.code,
    required this.discountPercent,
    this.minOrder = 0,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
}

abstract class CouponRepository {
  /// The active coupon with this code, or `null` if there is none.
  Future<CouponEntity?> findCoupon(String code);
}

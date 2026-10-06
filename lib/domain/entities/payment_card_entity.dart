enum CardBrand {
  visa,
  mastercard,
  amex,
  other;

  static CardBrand fromNumber(String digits) {
    if (digits.startsWith('4')) return CardBrand.visa;
    if (RegExp(r'^3[47]').hasMatch(digits)) return CardBrand.amex;
    final two = int.tryParse(digits.length >= 2 ? digits.substring(0, 2) : '');
    final four = int.tryParse(digits.length >= 4 ? digits.substring(0, 4) : '');
    if ((two != null && two >= 51 && two <= 55) ||
        (four != null && four >= 2221 && four <= 2720)) {
      return CardBrand.mastercard;
    }
    return CardBrand.other;
  }

  static CardBrand fromName(String? name) => CardBrand.values.firstWhere(
    (b) => b.name == name,
    orElse: () => CardBrand.other,
  );

  String get label => switch (this) {
    CardBrand.visa => 'Visa',
    CardBrand.mastercard => 'Mastercard',
    CardBrand.amex => 'American Express',
    CardBrand.other => 'Card',
  };
}

/// A saved card. Only what is needed to recognise the card is kept: never
/// the full number or the CVV.
class PaymentCardEntity {
  final String id;
  final String holderName;
  final String last4;
  final CardBrand brand;
  final int expiryMonth;
  final int expiryYear;
  final bool isDefault;

  const PaymentCardEntity({
    required this.id,
    required this.holderName,
    required this.last4,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
  });

  String get maskedNumber => '**** **** **** $last4';

  String get expiry =>
      '${expiryMonth.toString().padLeft(2, '0')}/${(expiryYear % 100).toString().padLeft(2, '0')}';

  PaymentCardEntity copyWith({bool? isDefault}) => PaymentCardEntity(
    id: id,
    holderName: holderName,
    last4: last4,
    brand: brand,
    expiryMonth: expiryMonth,
    expiryYear: expiryYear,
    isDefault: isDefault ?? this.isDefault,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'holder_name': holderName,
    'last4': last4,
    'brand': brand.name,
    'expiry_month': expiryMonth,
    'expiry_year': expiryYear,
    'is_default': isDefault,
  };

  factory PaymentCardEntity.fromJson(Map<String, dynamic> json) =>
      PaymentCardEntity(
        id: json['id'] as String,
        holderName: json['holder_name'] as String? ?? '',
        last4: json['last4'] as String? ?? '',
        brand: CardBrand.fromName(json['brand'] as String?),
        expiryMonth: json['expiry_month'] as int? ?? 1,
        expiryYear: json['expiry_year'] as int? ?? 2000,
        isDefault: json['is_default'] as bool? ?? false,
      );
}

/// Card checks used by the add-card form. Each returns a translation key
/// for the problem, or `null` when the value is fine.
class CardValidator {
  CardValidator._();

  static String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

  static String? holderName(String value) =>
      value.trim().length < 2 ? 'error_card_name' : null;

  static String? number(String value) {
    final digits = digitsOnly(value);
    if (digits.length < 13 || digits.length > 19 || !passesLuhn(digits)) {
      return 'error_card_number';
    }
    return null;
  }

  /// Accepts `MM/YY`. The card is valid until the end of that month.
  static String? expiry(String value, {DateTime? now}) {
    final match = RegExp(r'^(\d{2})\s*/\s*(\d{2})$').firstMatch(value.trim());
    if (match == null) return 'error_card_expiry';
    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    if (month < 1 || month > 12) return 'error_card_expiry';
    final today = now ?? DateTime.now();
    final firstDayAfterExpiry = DateTime(year, month + 1);
    if (!today.isBefore(firstDayAfterExpiry)) return 'error_card_expired';
    return null;
  }

  static String? cvv(String value) =>
      RegExp(r'^\d{3,4}$').hasMatch(value.trim()) ? null : 'error_card_cvv';

  /// Standard checksum every real card number satisfies.
  static bool passesLuhn(String digits) {
    var sum = 0;
    var doubleIt = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var d = int.parse(digits[i]);
      if (doubleIt) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      doubleIt = !doubleIt;
    }
    return sum % 10 == 0;
  }
}

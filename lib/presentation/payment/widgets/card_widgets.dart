import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../domain/entities/payment_card_entity.dart';

/// Coloured card picture with brand, masked number, holder and expiry.
class CardPreview extends StatelessWidget {
  const CardPreview({
    super.key,
    required this.holderName,
    required this.number,
    required this.expiry,
    required this.brand,
  });

  final String holderName;
  final String number;
  final String expiry;
  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bannerTeal, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, color: AppColors.white),
              const Spacer(),
              CardBrandLogo(brand: brand, onDark: true),
            ],
          ),
          const Spacer(),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  holderName.isEmpty
                      ? context.tr('cardholder_name')
                      : holderName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                expiry.isEmpty ? 'MM/YY' : expiry,
                style: const TextStyle(color: AppColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CardBrandLogo extends StatelessWidget {
  const CardBrandLogo({super.key, required this.brand, this.onDark = false});

  final CardBrand brand;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    if (brand == CardBrand.mastercard) {
      return Image.asset(
        'lib/assets/icons/mastercard.png',
        width: 40,
        height: 26,
        fit: BoxFit.contain,
      );
    }
    return Text(
      brand.label,
      style: TextStyle(
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        color: onDark ? AppColors.white : AppColors.primary,
      ),
    );
  }
}

/// Groups card digits in fours: `4242 4242 4242 4242`.
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 19 ? digits.substring(0, 19) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formats the expiry as `MM/YY` while typing.
class ExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    final deleting = newValue.text.length < oldValue.text.length;
    final text = digits.length > 2 || (digits.length == 2 && !deleting)
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

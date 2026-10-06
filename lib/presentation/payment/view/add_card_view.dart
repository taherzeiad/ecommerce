import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../domain/entities/payment_card_entity.dart';
import '../view_model/payment_cards_view_model.dart';
import '../widgets/card_widgets.dart';

/// Adds a card. Pops with the saved [PaymentCardEntity] so checkout can
/// select it right away.
class AddCardView extends StatefulWidget {
  const AddCardView({super.key});

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  Map<String, String> _errors = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _number, _expiry]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _errors = {};
    });
    try {
      final card = await context.read<PaymentCardsViewModel>().addCard(
        holderName: _name.text,
        number: _number.text,
        expiry: _expiry.text,
        cvv: _cvv.text,
      );
      if (mounted) Navigator.pop(context, card);
    } on CardFormException catch (e) {
      if (!mounted) return;
      setState(() => _errors = e.errors);
      if (e.errors['save'] case final key?) showMessage(context, key);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final digits = CardValidator.digitsOnly(_number.text);
    final masked = digits.isEmpty
        ? '**** **** **** ****'
        : '**** **** **** ${digits.length >= 4 ? digits.substring(digits.length - 4) : digits}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('add_new_card'),
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardPreview(
              holderName: _name.text,
              number: masked,
              expiry: _expiry.text,
              brand: CardBrand.fromNumber(digits),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('card_storage_note'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _buildFieldLabel(context.tr('cardholder_name')),
            _buildTextField(
              controller: _name,
              hintText: context.tr('enter_card_name'),
              error: _errors['name'],
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 24),
            _buildFieldLabel(context.tr('card_number')),
            _buildTextField(
              controller: _number,
              hintText: '0000 0000 0000 0000',
              error: _errors['number'],
              keyboardType: TextInputType.number,
              formatters: [CardNumberInputFormatter()],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(context.tr('expiration_date')),
                      _buildTextField(
                        controller: _expiry,
                        hintText: 'MM/YY',
                        error: _errors['expiry'],
                        keyboardType: TextInputType.number,
                        formatters: [ExpiryInputFormatter()],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel(context.tr('cvv')),
                      _buildTextField(
                        controller: _cvv,
                        hintText: '123',
                        error: _errors['cvv'],
                        keyboardType: TextInputType.number,
                        obscure: true,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(context.tr('add_card')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    String? error,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    bool obscure = false,
  }) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: theme.dividerColor),
    );
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: theme.hintColor),
        errorText: error == null ? null : context.tr(error),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border,
        enabledBorder: border,
      ),
    );
  }
}

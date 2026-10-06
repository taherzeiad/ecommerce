import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../domain/entities/address_entity.dart';

/// Address fields with validation, shared by the add and edit screens.
/// Calls [onSubmit] with the filled-in address (keeping [initial]'s id).
class AddressForm extends StatefulWidget {
  const AddressForm({
    super.key,
    this.initial,
    required this.submitLabel,
    required this.isSaving,
    required this.onSubmit,
  });

  final AddressEntity? initial;
  final String submitLabel;
  final bool isSaving;
  final ValueChanged<AddressEntity> onSubmit;

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _street;
  late final TextEditingController _city;
  late final TextEditingController _postalCode;
  late String? _country;
  late bool _isDefault;
  bool _showCountryError = false;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _name = TextEditingController(text: a?.fullName);
    _phone = TextEditingController(text: a?.phoneNumber);
    _street = TextEditingController(text: a?.streetAddress);
    _city = TextEditingController(text: a?.city);
    _postalCode = TextEditingController(text: a?.postalCode);
    _country = (a?.country.isEmpty ?? true) ? null : a!.country;
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _street.dispose();
    _city.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  String? _required(String? value) => (value == null || value.trim().isEmpty)
      ? context.tr('error_required')
      : null;

  String? _phoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return context.tr('error_required');
    if (!RegExp(r'^\+?[0-9 ]{7,15}$').hasMatch(text)) {
      return context.tr('error_invalid_phone');
    }
    return null;
  }

  void _submit() {
    final fieldsOk = _formKey.currentState!.validate();
    setState(() => _showCountryError = _country == null);
    if (!fieldsOk || _country == null) return;
    final a = widget.initial;
    widget.onSubmit(
      AddressEntity(
        id: a?.id,
        userId: a?.userId ?? '',
        fullName: _name.text.trim(),
        phoneNumber: _phone.text.trim(),
        streetAddress: _street.text.trim(),
        city: _city.text.trim(),
        postalCode: _postalCode.text.trim(),
        country: _country!,
        isDefault: _isDefault,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('full_name'),
          _field(_name, 'full_name', _required, TextInputType.name),
          const SizedBox(height: 16),
          _label('phone_number'),
          _field(_phone, 'phone_number', _phoneValidator, TextInputType.phone),
          const SizedBox(height: 16),
          _label('street_address'),
          _field(
            _street,
            'street_address',
            _required,
            TextInputType.streetAddress,
          ),
          const SizedBox(height: 16),
          _label('city'),
          _field(_city, 'city', _required, TextInputType.text),
          const SizedBox(height: 16),
          _label('postal_code'),
          // Optional: not every country uses postal codes.
          _field(_postalCode, 'postal_code', null, TextInputType.text),
          const SizedBox(height: 16),
          _label('select_country'),
          _countryPicker(),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('set_as_default')),
            value: _isDefault,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _isDefault = v),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.isSaving ? null : _submit,
            child: widget.isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }

  Widget _label(String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        context.tr(key),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  InputDecoration _decoration(String hintKey) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: theme.dividerColor),
    );
    return InputDecoration(
      hintText: context.tr(hintKey),
      hintStyle: TextStyle(color: theme.hintColor),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border,
      enabledBorder: border,
    );
  }

  Widget _field(
    TextEditingController controller,
    String hintKey,
    FormFieldValidator<String>? validator,
    TextInputType keyboard,
  ) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboard,
      textInputAction: TextInputAction.next,
      decoration: _decoration(hintKey),
    );
  }

  Widget _countryPicker() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: false,
              onSelect: (Country country) {
                setState(() {
                  _country = country.name;
                  _showCountryError = false;
                });
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(
                color: _showCountryError
                    ? theme.colorScheme.error
                    : theme.dividerColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _country ?? context.tr('select_country'),
                    style: TextStyle(
                      color: _country == null
                          ? theme.hintColor
                          : theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: theme.hintColor),
              ],
            ),
          ),
        ),
        if (_showCountryError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12, right: 12),
            child: Text(
              context.tr('error_required'),
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

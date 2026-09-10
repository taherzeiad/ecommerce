import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';

class AddAddressView extends StatefulWidget {
  const AddAddressView({super.key});

  @override
  State<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  Country? _selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('add_new_address'),
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.location_on,
                size: 120,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Enter your address to receive your orders easily.', // This should also be translated if added to translations
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            _buildFieldLabel(context.tr('full_name')),
            _buildTextField(hintText: context.tr('full_name')),
            const SizedBox(height: 16),
            _buildFieldLabel(context.tr('phone_number')),
            _buildTextField(hintText: context.tr('phone_number')),
            const SizedBox(height: 16),
            _buildFieldLabel(context.tr('street_address')),
            _buildTextField(hintText: context.tr('street_address')),
            const SizedBox(height: 16),
            _buildFieldLabel(context.tr('city')),
            _buildTextField(hintText: context.tr('city')),
            const SizedBox(height: 16),
            _buildFieldLabel(context.tr('postal_code')),
            _buildTextField(hintText: context.tr('postal_code')),
            const SizedBox(height: 16),
            _buildFieldLabel(context.tr('select_country')),
            _buildCountryPickerField(context.tr('select_country')),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('add')),
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
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildTextField({String? initialValue, String? hintText}) {
    final theme = Theme.of(context);
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: theme.hintColor),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
      ),
    );
  }

  Widget _buildCountryPickerField(String hintText) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          onSelect: (Country country) {
            setState(() {
              _selectedCountry = country;
            });
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedCountry?.name ?? hintText,
              style: TextStyle(
                color: _selectedCountry == null
                    ? theme.hintColor
                    : theme.textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: theme.hintColor,
            ),
          ],
        ),
      ),
    );
  }
}

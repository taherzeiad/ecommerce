import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

import '../../../core/constants/app_colors.dart';

class EditAddressView extends StatefulWidget {
  const EditAddressView({super.key});

  @override
  State<EditAddressView> createState() => _EditAddressViewState();
}

class _EditAddressViewState extends State<EditAddressView> {
  Country? _selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Address',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
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
                'Update your address details.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            _buildFieldLabel('Full Name'),
            _buildTextField(initialValue: 'RamizA'),
            const SizedBox(height: 16),
            _buildFieldLabel('Phone Number'),
            _buildTextField(initialValue: '1029846567'),
            const SizedBox(height: 16),
            _buildFieldLabel('Street Address'),
            _buildTextField(initialValue: '5 streetA'),
            const SizedBox(height: 16),
            _buildFieldLabel('City/Town'),
            _buildTextField(initialValue: 'Los Angelou\'s'),
            const SizedBox(height: 16),
            _buildFieldLabel('Postal Code'),
            _buildTextField(hintText: 'ZIP / Postal code'),
            const SizedBox(height: 16),
            _buildFieldLabel('Country'),
            _buildCountryPickerField('Select Country'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Save'),
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
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({String? initialValue, String? hintText}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textLight),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
      ),
    );
  }

  Widget _buildCountryPickerField(String hintText) {
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
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedCountry?.name ?? hintText,
              style: TextStyle(
                color: _selectedCountry == null
                    ? AppColors.textLight
                    : AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

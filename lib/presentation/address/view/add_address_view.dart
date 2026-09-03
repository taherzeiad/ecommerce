import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AddAddressView extends StatelessWidget {
  const AddAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Add New Address',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.location_on, size: 120, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Enter your address to receive your orders easily.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            _buildFieldLabel('Full Name'),
            _buildTextField(hintText: 'Enter Your Name'),
            const SizedBox(height: 16),
            _buildFieldLabel('Phone Number'),
            _buildTextField(hintText: 'Enter Your Phone Number'),
            const SizedBox(height: 16),
            _buildFieldLabel('Street Address'),
            _buildTextField(hintText: 'Enter Your Address'),
            const SizedBox(height: 16),
            _buildFieldLabel('City/Town'),
            _buildTextField(hintText: 'Enter Your City'),
            const SizedBox(height: 16),
            _buildFieldLabel('Postal Code'),
            _buildTextField(hintText: 'ZIP / Postal code'),
            const SizedBox(height: 16),
            _buildFieldLabel('Country'),
            _buildDropdownField('Select Country'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Add'),
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1B1B29)),
      ),
    );
  }

  Widget _buildTextField({String? initialValue, String? hintText}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      ),
    );
  }

  Widget _buildDropdownField(String hintText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hintText, style: const TextStyle(color: Color(0xFFBDBDBD))),
          items: const [],
          onChanged: (val) {},
        ),
      ),
    );
  }
}

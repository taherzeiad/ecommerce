import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                'https://cdn-icons-png.flaticon.com/512/6195/6195699.png', // Dummy unlock icon
                height: 150,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Change your password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF616161),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildFieldLabel('Current Password'),
            _buildPasswordField(hintText: 'Enter Your Password'),
            const SizedBox(height: 24),
            _buildFieldLabel('New Password'),
            _buildPasswordField(hintText: 'Password'),
            const SizedBox(height: 24),
            _buildFieldLabel('Confirm Password'),
            _buildPasswordField(hintText: 'Confirm Password'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Save Change'),
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

  Widget _buildPasswordField({required String hintText}) {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFBDBDBD)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    );
  }
}

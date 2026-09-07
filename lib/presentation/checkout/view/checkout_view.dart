import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

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
        title: const Text(
          'Check Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          _buildStepHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildAddressStep(),
                _buildPaymentStep(),
                _buildConfirmStep(),
              ],
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildStepHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Row(
          children: [
            _buildStepTab('Address', 0),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color(0xFFEEEEEE),
            ),
            _buildStepTab('Payment', 1),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color(0xFFEEEEEE),
            ),
            _buildStepTab('Confirm', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTab(String label, int index) {
    final isActive = _currentStep == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentStep = index;
            _pageController.jumpToPage(index);
          });
        },
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          color: isActive ? AppColors.primary : Colors.white,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildAddressCard(),
          const SizedBox(height: 24),
          _buildAddAddressBtn(),
          const SizedBox(height: 32),
          _buildOrderSummary(orderNumber: '#135792'),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E6E3)),
      ),
      child: Column(
        children: [
          _buildAddressRow(
            Icons.person,
            'Name',
            'Ramiz Majed Alashqar',
            showEdit: true,
          ),
          const Divider(height: 24),
          _buildAddressRow(
            Icons.location_on,
            'Address',
            '742 Maple Street, Apt 5B\nBrooklyn, NY 11221\nUnited States',
          ),
          const Divider(height: 24),
          _buildAddressRow(
            Icons.phone,
            'Phone Number',
            '+ 1 555 742 8391',
            showCheck: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(
    IconData icon,
    String label,
    String value, {
    bool showEdit = false,
    bool showCheck = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.grey, height: 1.4),
              ),
            ],
          ),
        ),
        if (showEdit)
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.editAddress),
            icon: const Icon(Icons.edit, color: AppColors.primary),
          ),
        if (showCheck)
          const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
      ],
    );
  }

  Widget _buildAddAddressBtn() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD8E6E3)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextButton.icon(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addAddress),
        icon: const Icon(Icons.add_circle, color: AppColors.primary),
        label: const Text(
          'Add New Address',
          style: TextStyle(color: AppColors.primary, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Option',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPaymentIcons(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select your card',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.addCard),
                child: const Text('Add New Card'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCardOption(
            'Mastercard – **** 4956',
            'lib/assets/icons/mastercard.png',
            isSelected: true,
          ),
          const SizedBox(height: 12),
          _buildCardOption(
            'Axis Bank **** 1453',
            'lib/assets/icons/paypal.png',
          ),
          const SizedBox(height: 16),
          _buildOrderSummary(orderNumber: '#135792'),
        ],
      ),
    );
  }

  Widget _buildPaymentIcons() {
    final icons = [
      'lib/assets/icons/mastercard.png',
      'lib/assets/icons/paypal.png',
      'lib/assets/icons/apple.png',
      'lib/assets/icons/google.png',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: icons
          .map(
            (path) => Container(
              padding: const EdgeInsets.all(8),
              width: 60,
              height: 45,
              child: Image.asset(
                path,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCardOption(
    String title,
    String logoPath, {
    bool isSelected = false,
  }) {
    return Container(
      width: 361,
      height: 51,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFF1F1F1),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (val) {},
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Image.asset(
            logoPath,
            width: 40,
            height: 24,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCreditCardPreview(),
          const SizedBox(height: 32),
          _buildConfirmField('Cardholder Name', 'Gabriele Persola'),
          const SizedBox(height: 24),
          _buildConfirmField('Card Number', '3761 5902 7458 4956'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildConfirmField('Expiration Date', '01/27')),
              const SizedBox(width: 16),
              Expanded(child: _buildConfirmField('CVV', '123')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5AB4A6), Color(0xFF0E7A69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gabriele Persola',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Text(
            'Credit Card:',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const Text(
            '3761 **** **** 4956',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expiration:',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '01/27',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              Image.asset(
                'lib/assets/icons/mastercard.png',
                width: 50,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary({required String orderNumber}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Your Order $orderNumber',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Total Items', '3 Items'),
          _buildSummaryRow('Subtotal', '13,00\$'),
          _buildSummaryRow('Delivery Fees', '12.00\$'),
          const Divider(height: 24),
          _buildSummaryRow('Total Price', '1312.00\$', isBold: true),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'All prices displayed are inclusive of all applicable Tax.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    String text = 'Go To Payment';
    IconData? icon = Icons.arrow_forward;
    VoidCallback? onTap;

    if (_currentStep == 0) {
      onTap = () => _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else if (_currentStep == 1) {
      text = 'Continue';
      onTap = () => _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      text = 'Confirm';
      icon = null;
      onTap = () => Navigator.pushNamed(context, AppRoutes.orderSuccess);
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ElevatedButton(
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            if (icon != null) ...[const SizedBox(width: 8), Icon(icon)],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/extensions/context_extension.dart';
import '../../cart/view_model/cart_view_model.dart';

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
    final cartViewModel = context.watch<CartViewModel>();

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
          context.tr('checkout'),
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
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
                _buildAddressStep(cartViewModel),
                _buildPaymentStep(cartViewModel),
                _buildConfirmStep(),
              ],
            ),
          ),
          _buildBottomAction(cartViewModel),
        ],
      ),
    );
  }

  Widget _buildStepHeader() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 50,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Row(
          children: [
            _buildStepTab(context, context.tr('address'), 0),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: theme.dividerColor,
            ),
            _buildStepTab(context, context.tr('payment'), 1),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: theme.dividerColor,
            ),
            _buildStepTab(context, context.tr('confirm'), 2),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTab(BuildContext context, String label, int index) {
    final isActive = _currentStep == index;
    final theme = Theme.of(context);
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
          color: isActive ? AppColors.primary : theme.cardColor,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.white : theme.textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressStep(CartViewModel cartViewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildAddressCard(),
          const SizedBox(height: 24),
          _buildAddAddressBtn(),
          const SizedBox(height: 32),
          _buildOrderSummary(cartViewModel: cartViewModel, orderNumber: '#135792'),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderTeal),
      ),
      child: Column(
        children: [
          _buildAddressRow(
            Icons.person,
            context.tr('full_name'),
            'Ramiz Majed Alashqar',
            showEdit: true,
          ),
          Divider(height: 24, color: theme.dividerColor),
          _buildAddressRow(
            Icons.location_on,
            context.tr('address'),
            '742 Maple Street, Apt 5B\nBrooklyn, NY 11221\nUnited States',
          ),
          Divider(height: 24, color: theme.dividerColor),
          _buildAddressRow(
            Icons.phone,
            context.tr('phone_number'),
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
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  height: 1.4,
                ),
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
        border: Border.all(color: AppColors.borderTeal),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextButton.icon(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addAddress),
        icon: const Icon(Icons.add_circle, color: AppColors.primary),
        label: Text(
          context.tr('add_new_address'),
          style: const TextStyle(color: AppColors.primary, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPaymentStep(CartViewModel cartViewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('payment_option'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPaymentIcons(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('select_your_card'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.addCard),
                child: Text(context.tr('add_new_card')),
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
          _buildOrderSummary(cartViewModel: cartViewModel, orderNumber: '#135792'),
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
    final theme = Theme.of(context);
    return Container(
      width: 361,
      height: 51,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : theme.dividerColor,
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
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodySmall?.color,
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
          _buildConfirmField(context.tr('cardholder_name'), 'Gabriele Persola'),
          const SizedBox(height: 24),
          _buildConfirmField(context.tr('card_number'), '3761 5902 7458 4956'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildConfirmField(context.tr('expiration_date'), '01/27')),
              const SizedBox(width: 16),
              Expanded(child: _buildConfirmField(context.tr('cvv'), '123')),
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
          colors: [AppColors.bannerTeal, AppColors.primaryDark],
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
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            context.tr('payment_option'),
            style: TextStyle(color: AppColors.white.withValues(alpha: 0.7), fontSize: 14),
          ),
          const Text(
            '3761 **** **** 4956',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('expiration_date'),
                    style: TextStyle(color: AppColors.white.withValues(alpha: 0.7), fontSize: 12),
                  ),
                  const Text(
                    '01/27',
                    style: TextStyle(color: AppColors.white, fontSize: 16),
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
    final theme = Theme.of(context);
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary({
    required CartViewModel cartViewModel,
    required String orderNumber,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${context.tr('my_order')} $orderNumber',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(context.tr('total_items'), '${cartViewModel.totalItems} ${context.tr('items_count')}'),
          _buildSummaryRow(
            context.tr('sub_total'),
            '${cartViewModel.subtotal.toStringAsFixed(2)}\$',
          ),
          _buildSummaryRow(
            context.tr('delivery_fees'),
            '${cartViewModel.deliveryFees.toStringAsFixed(2)}\$',
          ),
          Divider(height: 24, color: theme.dividerColor),
          _buildSummaryRow(
            context.tr('total'),
            '${cartViewModel.totalPrice.toStringAsFixed(2)}\$',
            isBold: true,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'All prices displayed are inclusive of all applicable Tax.', // Should be translated
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color,
              ),
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

  Widget _buildBottomAction(CartViewModel cartViewModel) {
    String text = context.tr('go_to_payment');
    IconData? icon = Icons.arrow_forward;
    VoidCallback? onTap;

    if (_currentStep == 0) {
      onTap = () => _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else if (_currentStep == 1) {
      text = context.tr('continue_label');
      onTap = () => _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      text = context.tr('confirm');
      icon = null;
      onTap = () {
        cartViewModel.clearCart();
        Navigator.pushNamed(context, AppRoutes.orderSuccess);
      };
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

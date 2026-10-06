import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/payment_card_entity.dart';
import '../../address/view_model/address_view_model.dart';
import '../../address/widgets/address_card.dart';
import '../../cart/view_model/cart_view_model.dart';
import '../../notifications/view_model/notifications_view_model.dart';
import '../../payment/view_model/payment_cards_view_model.dart';
import '../../payment/widgets/card_widgets.dart';

/// Three steps: delivery address, payment method, review & confirm.
class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

/// Radio value used for cash on delivery among the saved card ids.
const _cashOption = 'cash';

class _CheckoutViewState extends State<CheckoutView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String? _selectedAddressId;

  /// A saved card id, or [_cashOption].
  String? _paymentOption;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // A message from the cart would cover the checkout button.
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      context.read<AddressViewModel>().fetchAddresses();
      context.read<CartViewModel>().fetchCartItems();
      context.read<PaymentCardsViewModel>().fetchCards();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  AddressEntity? _selectedAddress(AddressViewModel vm) {
    return vm.addresses.where((a) => a.id == _selectedAddressId).firstOrNull ??
        vm.defaultAddress;
  }

  String? _selectedPayment(PaymentCardsViewModel vm) {
    if (_paymentOption == _cashOption) return _cashOption;
    final card = vm.cards.where((c) => c.id == _paymentOption).firstOrNull ??
        vm.defaultCard;
    return card?.id ?? _paymentOption;
  }

  PaymentCardEntity? _selectedCard(PaymentCardsViewModel vm) {
    final option = _selectedPayment(vm);
    return vm.cards.where((c) => c.id == option).firstOrNull;
  }

  void _goTo(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  /// The first step that is not complete yet, or `null` when all are.
  int? _firstIncompleteStep() {
    if (_selectedAddress(context.read<AddressViewModel>()) == null) return 0;
    if (_selectedPayment(context.read<PaymentCardsViewModel>()) == null) {
      return 1;
    }
    return null;
  }

  Future<void> _next() async {
    if (_currentStep == 0) {
      if (_selectedAddress(context.read<AddressViewModel>()) == null) {
        showMessage(context, 'no_address_msg');
        return;
      }
      _goTo(1);
    } else if (_currentStep == 1) {
      if (_selectedPayment(context.read<PaymentCardsViewModel>()) == null) {
        showMessage(context, 'error_select_payment');
        return;
      }
      _goTo(2);
    } else {
      await _placeOrder();
    }
  }

  Future<void> _placeOrder() async {
    final incomplete = _firstIncompleteStep();
    if (incomplete != null) {
      showMessage(
        context,
        incomplete == 0 ? 'no_address_msg' : 'error_select_payment',
      );
      _goTo(incomplete);
      return;
    }
    final cart = context.read<CartViewModel>();
    final cards = context.read<PaymentCardsViewModel>();
    final address = _selectedAddress(context.read<AddressViewModel>())!;
    final card = _selectedCard(cards);

    final orderId = await cart.placeOrder(
      addressId: address.id,
      paymentMethod: card == null ? PaymentMethod.cash : PaymentMethod.card,
      cardLast4: card?.last4,
    );
    if (!mounted) return;
    if (orderId == null) {
      showMessage(context, cart.orderError ?? 'error_unexpected');
      return;
    }
    context.read<NotificationsViewModel>().fetchNotifications();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.orderSuccess,
      (route) => route.isFirst,
      arguments: orderId,
    );
  }

  Future<void> _addCard() async {
    final card = await Navigator.pushNamed(context, AppRoutes.addCard);
    if (card is PaymentCardEntity && mounted) {
      setState(() => _paymentOption = card.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();

    Widget body;
    if (cart.isInitialLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (cart.errorMessage != null && cart.items.isEmpty) {
      body = ErrorStateView(
        messageKey: cart.errorMessage!,
        onRetry: cart.fetchCartItems,
      );
    } else if (cart.items.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 96,
              color: AppColors.borderLight,
            ),
            const SizedBox(height: 16),
            Text(context.tr('cart_empty')),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('go_shopping')),
            ),
          ],
        ),
      );
    } else {
      body = Column(
        children: [
          const SizedBox(height: 24),
          _buildStepHeader(),
          const SizedBox(height: 16),
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
          _buildBottomAction(cart),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentStep > 0) {
              _goTo(_currentStep - 1);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          context.tr('checkout'),
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: body,
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
            _buildStepTab(context.tr('address'), 0),
            VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),
            _buildStepTab(context.tr('payment'), 1),
            VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),
            _buildStepTab(context.tr('confirm'), 2),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTab(String label, int index) {
    final isActive = _currentStep == index;
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        // Later steps open only once the earlier ones are filled in.
        onTap: () {
          final incomplete = _firstIncompleteStep();
          if (incomplete != null && index > incomplete) {
            _goTo(incomplete);
          } else {
            _goTo(index);
          }
        },
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          color: isActive ? AppColors.primary : theme.cardColor,
          child: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? AppColors.white
                  : theme.textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    final addressViewModel = context.watch<AddressViewModel>();
    final selected = _selectedAddress(addressViewModel);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (addressViewModel.isLoading && addressViewModel.addresses.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (addressViewModel.addresses.isEmpty)
          Text(
            context.tr('no_address_msg'),
            textAlign: TextAlign.center,
          )
        else
          ...addressViewModel.addresses.map(
            (addr) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AddressCard(
                address: addr,
                isSelected: selected?.id == addr.id,
                onTap: () => setState(() => _selectedAddressId = addr.id),
                trailing: IconButton(
                  tooltip: context.tr('edit_address'),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.editAddress,
                    arguments: addr,
                  ),
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addAddress),
          icon: const Icon(Icons.add_circle, color: AppColors.primary),
          label: Text(
            context.tr('add_new_address'),
            style: const TextStyle(color: AppColors.primary, fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: AppColors.borderTeal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildPaymentStep() {
    final cards = context.watch<PaymentCardsViewModel>();
    final selected = _selectedPayment(cards);
    final theme = Theme.of(context);

    Widget option({
      required String value,
      required Widget title,
      Widget? subtitle,
      Widget? trailing,
    }) {
      final isSelected = selected == value;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.dividerColor,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: RadioListTile<String>(
            value: value,
            activeColor: AppColors.primary,
            title: title,
            subtitle: subtitle,
            secondary: trailing,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('payment_option'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _addCard,
              child: Text(context.tr('add_new_card')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RadioGroup<String>(
          groupValue: selected,
          onChanged: (value) => setState(() => _paymentOption = value),
          child: Column(
            children: [
              for (final card in cards.cards)
                option(
                  value: card.id,
                  title: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(card.maskedNumber),
                    ),
                  ),
                  subtitle: Text('${card.holderName} • ${card.expiry}'),
                  trailing: CardBrandLogo(brand: card.brand),
                ),
              option(
                value: _cashOption,
                title: Text(context.tr('cash_on_delivery')),
                subtitle: Text(context.tr('cash_on_delivery_desc')),
                trailing: const Icon(
                  Icons.payments_outlined,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('payment_simulated_note'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildConfirmStep() {
    final cart = context.watch<CartViewModel>();
    final cards = context.watch<PaymentCardsViewModel>();
    final address = _selectedAddress(context.watch<AddressViewModel>());
    final card = _selectedCard(cards);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _sectionTitle(context.tr('order_summary')),
        for (final item in cart.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.product.name} × ${item.quantity}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(formatPrice(item.product.price * item.quantity)),
              ],
            ),
          ),
        const SizedBox(height: 24),
        _sectionTitle(context.tr('delivery_address')),
        if (address != null)
          AddressCard(address: address, onTap: () => _goTo(0))
        else
          Text(context.tr('no_address_msg')),
        const SizedBox(height: 24),
        _sectionTitle(context.tr('payment')),
        if (card != null)
          CardPreview(
            holderName: card.holderName,
            number: card.maskedNumber,
            expiry: card.expiry,
            brand: card.brand,
          )
        else
          ListTile(
            tileColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor),
            ),
            leading: const Icon(Icons.payments_outlined, color: AppColors.primary),
            title: Text(context.tr('cash_on_delivery')),
            onTap: () => _goTo(1),
          ),
        const SizedBox(height: 24),
        _buildOrderSummary(),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final cart = context.watch<CartViewModel>();
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
                context.tr('my_order'),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            context.tr('total_items'),
            '${cart.totalItems} ${context.tr('items_count')}',
          ),
          _buildSummaryRow(context.tr('sub_total'), formatPrice(cart.subtotal)),
          if (cart.coupon != null)
            _buildSummaryRow(
              '${context.tr('discount')} (${cart.coupon!.code})',
              '-${formatPrice(cart.discount)}',
            ),
          _buildSummaryRow(
            context.tr('delivery_fees'),
            formatPrice(cart.deliveryFees),
          ),
          _buildSummaryRow(context.tr('taxes'), formatPrice(cart.taxes)),
          Divider(height: 24, color: theme.dividerColor),
          _buildSummaryRow(
            context.tr('total'),
            formatPrice(cart.totalPrice),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildBottomAction(CartViewModel cart) {
    final (text, icon) = switch (_currentStep) {
      0 => (context.tr('go_to_payment'), Icons.arrow_forward),
      1 => (context.tr('continue_label'), Icons.arrow_forward),
      _ => (
        '${context.tr('place_order')} • ${formatPrice(cart.totalPrice)}',
        null,
      ),
    };

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: cart.isPlacingOrder ? null : _next,
          child: cart.isPlacingOrder
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
                    if (icon != null) ...[const SizedBox(width: 8), Icon(icon)],
                  ],
                ),
        ),
      ),
    );
  }
}

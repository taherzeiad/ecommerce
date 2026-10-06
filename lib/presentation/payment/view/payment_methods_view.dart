import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/error_state_view.dart';
import '../view_model/payment_cards_view_model.dart';
import '../widgets/card_widgets.dart';

/// Saved cards: choose the default one, remove or add cards.
class PaymentMethodsView extends StatefulWidget {
  const PaymentMethodsView({super.key});

  @override
  State<PaymentMethodsView> createState() => _PaymentMethodsViewState();
}

class _PaymentMethodsViewState extends State<PaymentMethodsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentCardsViewModel>().fetchCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PaymentCardsViewModel>();
    final theme = Theme.of(context);

    Widget body;
    if (viewModel.isLoading && viewModel.cards.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (viewModel.errorMessage != null && viewModel.cards.isEmpty) {
      body = ErrorStateView(
        messageKey: viewModel.errorMessage!,
        onRetry: viewModel.fetchCards,
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (viewModel.cards.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const Icon(
                    Icons.credit_card_off_outlined,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('no_saved_cards'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          RadioGroup<String>(
            groupValue: viewModel.defaultCard?.id,
            onChanged: (id) {
              if (id != null) viewModel.setDefaultCard(id);
            },
            child: Column(
              children: [
                for (final card in viewModel.cards)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: RadioListTile<String>(
                      value: card.id,
                      activeColor: AppColors.primary,
                      title: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          card.maskedNumber,
                          textAlign:
                              Directionality.of(context) == TextDirection.rtl
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                      ),
                      subtitle: Text(
                        '${card.holderName} • ${card.expiry}'
                        '${card.isDefault ? ' • ${context.tr('default_label')}' : ''}',
                      ),
                      secondary: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CardBrandLogo(brand: card.brand),
                          IconButton(
                            tooltip: context.tr('delete'),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                            ),
                            onPressed: () => viewModel.deleteCard(card.id),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('card_storage_note'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('payment_methods'),
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: body,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addCard),
            icon: const Icon(Icons.add_card),
            label: Text(context.tr('add_new_card')),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../domain/entities/address_entity.dart';
import '../view_model/address_view_model.dart';
import '../widgets/address_form.dart';

class AddAddressView extends StatelessWidget {
  const AddAddressView({super.key});

  Future<void> _save(BuildContext context, AddressEntity address) async {
    final ok = await context.read<AddressViewModel>().addAddress(address);
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      showMessage(
        context,
        context.read<AddressViewModel>().errorMessage ?? 'error_unexpected',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddressViewModel>();
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
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
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
            Center(
              child: Text(
                context.tr('enter_address_msg'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            AddressForm(
              submitLabel: context.tr('add'),
              isSaving: viewModel.isLoading,
              onSubmit: (address) => _save(context, address),
            ),
          ],
        ),
      ),
    );
  }
}

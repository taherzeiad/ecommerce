import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../domain/entities/address_entity.dart';
import '../view_model/address_view_model.dart';
import '../widgets/address_card.dart';

/// Saved shipping addresses: add, edit, delete and choose the default.
class AddressesView extends StatefulWidget {
  const AddressesView({super.key});

  @override
  State<AddressesView> createState() => _AddressesViewState();
}

enum _AddressAction { edit, makeDefault, delete }

class _AddressesViewState extends State<AddressesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressViewModel>().fetchAddresses();
    });
  }

  Future<void> _onAction(_AddressAction action, AddressEntity address) async {
    final viewModel = context.read<AddressViewModel>();
    switch (action) {
      case _AddressAction.edit:
        Navigator.pushNamed(context, AppRoutes.editAddress, arguments: address);
      case _AddressAction.makeDefault:
        final ok = await viewModel.setDefaultAddress(address.id!);
        if (!ok && mounted) {
          showMessage(context, viewModel.errorMessage ?? 'error_unexpected');
        }
      case _AddressAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            content: Text(context.tr('delete_address_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(context.tr('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(context.tr('delete')),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        final ok = await viewModel.deleteAddress(address.id!);
        if (!ok && mounted) {
          showMessage(context, viewModel.errorMessage ?? 'error_unexpected');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddressViewModel>();
    final addresses = viewModel.addresses;

    Widget body;
    if (viewModel.isLoading && addresses.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (viewModel.errorMessage != null && addresses.isEmpty) {
      body = ErrorStateView(
        messageKey: viewModel.errorMessage!,
        onRetry: viewModel.fetchAddresses,
      );
    } else if (addresses.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_off_outlined,
                size: 96,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('no_address_msg'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: viewModel.fetchAddresses,
        child: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: addresses.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final address = addresses[index];
            return AddressCard(
              address: address,
              trailing: PopupMenuButton<_AddressAction>(
                onSelected: (action) => _onAction(action, address),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _AddressAction.edit,
                    child: Text(context.tr('edit_address')),
                  ),
                  if (!address.isDefault)
                    PopupMenuItem(
                      value: _AddressAction.makeDefault,
                      child: Text(context.tr('set_as_default')),
                    ),
                  PopupMenuItem(
                    value: _AddressAction.delete,
                    child: Text(context.tr('delete')),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

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
          context.tr('shipping_address'),
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
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addAddress),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(context.tr('add_new_address')),
          ),
        ),
      ),
    );
  }
}

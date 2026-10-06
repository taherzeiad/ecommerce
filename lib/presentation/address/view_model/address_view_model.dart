import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../domain/entities/address_entity.dart';

class AddressViewModel extends ChangeNotifier {
  final AddressRepository _addressRepository;

  AddressViewModel({required this._addressRepository});

  List<AddressEntity> _addresses = [];

  List<AddressEntity> get addresses => _addresses;

  AddressEntity? get defaultAddress =>
      _addresses.where((a) => a.isDefault).firstOrNull ??
      _addresses.firstOrNull;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  /// Translation key of the last failure, `null` when it worked.
  String? get errorMessage => _errorMessage;

  Future<void> fetchAddresses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _addresses = await _addressRepository.getAddresses();
    } catch (e) {
      _errorMessage = errorKeyFor(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Runs a change, then reloads the list. Returns `false` on failure.
  Future<bool> _change(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      _errorMessage = errorKeyFor(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
    await fetchAddresses();
    return true;
  }

  Future<bool> addAddress(AddressEntity address) => _change(() async {
    final id = await _addressRepository.addAddress(address);
    // The first address is always the default one.
    if (address.isDefault || _addresses.isEmpty) {
      await _addressRepository.setDefaultAddress(id);
    }
  });

  Future<bool> updateAddress(AddressEntity address) => _change(() async {
    await _addressRepository.updateAddress(address);
    if (address.isDefault && address.id != null) {
      await _addressRepository.setDefaultAddress(address.id!);
    }
  });

  Future<bool> deleteAddress(String addressId) =>
      _change(() => _addressRepository.deleteAddress(addressId));

  Future<bool> setDefaultAddress(String addressId) =>
      _change(() => _addressRepository.setDefaultAddress(addressId));
}

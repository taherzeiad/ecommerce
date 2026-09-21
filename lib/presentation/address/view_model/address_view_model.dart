import 'package:flutter/material.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../domain/entities/address_entity.dart';

class AddressViewModel extends ChangeNotifier {
  final AddressRepository _addressRepository;

  AddressViewModel({required AddressRepository addressRepository})
      : _addressRepository = addressRepository;

  List<AddressEntity> _addresses = [];
  List<AddressEntity> get addresses => _addresses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchAddresses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _addresses = await _addressRepository.getAddresses();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(AddressEntity address) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _addressRepository.addAddress(address);
      await fetchAddresses();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAddress(AddressEntity address) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _addressRepository.updateAddress(address);
      await fetchAddresses();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String addressId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _addressRepository.deleteAddress(addressId);
      await fetchAddresses();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _addressRepository.setDefaultAddress(addressId);
      await fetchAddresses();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import '../../domain/entities/address_entity.dart';

abstract class AddressRepository {
  Future<List<AddressEntity>> getAddresses();

  /// Saves a new address and returns its id.
  Future<String> addAddress(AddressEntity address);
  Future<void> updateAddress(AddressEntity address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String addressId);
}

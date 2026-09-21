import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/address_entity.dart';
import '../models/address_model.dart';
import 'address_repository.dart';

class SupabaseAddressRepository implements AddressRepository {
  final SupabaseClient _supabaseClient;

  SupabaseAddressRepository(this._supabaseClient);

  @override
  Future<List<AddressEntity>> getAddresses() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return [];

    final response = await _supabaseClient
        .from('shipping_addresses')
        .select()
        .eq('user_id', user.id);

    return (response as List<dynamic>)
        .map((json) => AddressModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addAddress(AddressEntity address) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    final model = AddressModel(
      userId: user.id,
      fullName: address.fullName,
      phoneNumber: address.phoneNumber,
      streetAddress: address.streetAddress,
      city: address.city,
      postalCode: address.postalCode,
      country: address.country,
      isDefault: address.isDefault,
    );

    await _supabaseClient.from('shipping_addresses').insert(model.toJson());
  }

  @override
  Future<void> updateAddress(AddressEntity address) async {
    if (address.id == null) return;

    final model = AddressModel(
      userId: address.userId,
      fullName: address.fullName,
      phoneNumber: address.phoneNumber,
      streetAddress: address.streetAddress,
      city: address.city,
      postalCode: address.postalCode,
      country: address.country,
      isDefault: address.isDefault,
    );

    await _supabaseClient
        .from('shipping_addresses')
        .update(model.toJson())
        .eq('id', address.id!);
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await _supabaseClient
        .from('shipping_addresses')
        .delete()
        .eq('id', addressId);
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    // First, set all user's addresses to not default
    await _supabaseClient
        .from('shipping_addresses')
        .update({'is_default': false})
        .eq('user_id', user.id);

    // Then set the specific one to default
    await _supabaseClient
        .from('shipping_addresses')
        .update({'is_default': true})
        .eq('id', addressId);
  }
}

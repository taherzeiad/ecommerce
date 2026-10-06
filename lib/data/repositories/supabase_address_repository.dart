import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/address_entity.dart';
import 'address_repository.dart';

class SupabaseAddressRepository implements AddressRepository {
  final SupabaseClient _supabaseClient;

  SupabaseAddressRepository(this._supabaseClient);

  static const List<String> _tables = [
    'shipping_addresses',
    'addresses',
    'user_addresses',
  ];

  @override
  Future<List<AddressEntity>> getAddresses() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return [];

    for (final table in _tables) {
      try {
        final response = await _supabaseClient
            .from(table)
            .select()
            .eq('user_id', user.id);

        return (response as List<dynamic>).map((json) {
          final map = json as Map<String, dynamic>;
          return AddressEntity(
            id: map['id']?.toString(),
            userId: map['user_id']?.toString() ?? user.id,
            fullName:
                (map['full_name'] ?? map['name'] ?? map['recipient_name'] ?? '')
                    as String,
            phoneNumber:
                (map['phone_number'] ?? map['phone'] ?? map['mobile'] ?? '')
                    as String,
            streetAddress:
                (map['street_address'] ?? map['address'] ?? map['street'] ?? '')
                    as String,
            city: (map['city'] ?? '') as String,
            postalCode:
                (map['postal_code'] ?? map['zip_code'] ?? map['zip'] ?? '')
                    as String,
            country: (map['country'] ?? '') as String,
            isDefault: (map['is_default'] ?? map['default'] ?? false) as bool,
          );
        }).toList();
      } catch (e) {
        debugPrint(
          '🔴 [Address Repository] getAddresses from $table failed: $e',
        );
      }
    }
    return [];
  }

  @override
  Future<String> addAddress(AddressEntity address) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw const AuthException('not_authenticated');

    final String fullName = address.fullName.trim();
    final String phone = address.phoneNumber.trim();
    final String street = address.streetAddress.trim();
    final String city = address.city.trim().isEmpty
        ? 'City'
        : address.city.trim();
    final String postalCode = address.postalCode.trim().isEmpty
        ? '00000'
        : address.postalCode.trim();
    final String country = address.country.trim().isEmpty
        ? 'Country'
        : address.country.trim();
    final bool isDefault = address.isDefault;

    final payloads = [
      {
        'user_id': user.id,
        'full_name': fullName,
        'phone_number': phone,
        'street_address': street,
        'city': city,
        'postal_code': postalCode,
        'country': country,
        'is_default': isDefault,
      },
      {
        'user_id': user.id,
        'name': fullName,
        'phone': phone,
        'address': street,
        'city': city,
        'postal_code': postalCode,
        'country': country,
        'is_default': isDefault,
      },
      {
        'user_id': user.id,
        'full_name': fullName,
        'phone': phone,
        'street': street,
        'city': city,
        'zip_code': postalCode,
        'country': country,
        'is_default': isDefault,
      },
    ];

    Object? lastError;

    for (final table in _tables) {
      for (final payload in payloads) {
        try {
          final row = await _supabaseClient
              .from(table)
              .insert(payload)
              .select('id')
              .single();
          return row['id'].toString();
        } catch (e) {
          lastError = e;
          debugPrint('🔴 [Address Repository] Insert into $table failed: $e');
        }
      }
    }

    if (lastError != null) throw lastError;
    throw Exception('Failed to add address');
  }

  @override
  Future<void> updateAddress(AddressEntity address) async {
    if (address.id == null) return;
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    final String fullName = address.fullName.trim();
    final String phone = address.phoneNumber.trim();
    final String street = address.streetAddress.trim();
    final String city = address.city.trim();
    final String postalCode = address.postalCode.trim();
    final String country = address.country.trim();
    final bool isDefault = address.isDefault;

    final payloads = [
      {
        'full_name': fullName,
        'phone_number': phone,
        'street_address': street,
        'city': city,
        'postal_code': postalCode,
        'country': country,
        'is_default': isDefault,
      },
      {
        'name': fullName,
        'phone': phone,
        'address': street,
        'city': city,
        'postal_code': postalCode,
        'country': country,
        'is_default': isDefault,
      },
    ];

    for (final table in _tables) {
      for (final payload in payloads) {
        try {
          await _supabaseClient
              .from(table)
              .update(payload)
              .eq('id', address.id!);
          return;
        } catch (_) {}
      }
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    for (final table in _tables) {
      try {
        await _supabaseClient.from(table).delete().eq('id', addressId);
        return;
      } catch (_) {}
    }
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    for (final table in _tables) {
      try {
        await _supabaseClient
            .from(table)
            .update({'is_default': false})
            .eq('user_id', user.id);

        await _supabaseClient
            .from(table)
            .update({'is_default': true})
            .eq('id', addressId);
        return;
      } catch (_) {}
    }
  }
}

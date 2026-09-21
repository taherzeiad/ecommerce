import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    super.id,
    required super.userId,
    required super.fullName,
    required super.phoneNumber,
    required super.streetAddress,
    required super.city,
    required super.postalCode,
    required super.country,
    super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString(),
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      streetAddress: json['street_address'] as String,
      city: json['city'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'street_address': streetAddress,
      'city': city,
      'postal_code': postalCode,
      'country': country,
      'is_default': isDefault,
    };
  }
}

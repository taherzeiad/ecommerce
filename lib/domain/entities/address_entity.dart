class AddressEntity {
  final String? id;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String streetAddress;
  final String city;
  final String postalCode;
  final String country;
  final bool isDefault;

  const AddressEntity({
    this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.streetAddress,
    required this.city,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
  });
}

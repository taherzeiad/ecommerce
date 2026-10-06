class ProfileEntity {
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;

  const ProfileEntity({
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
  });

  /// Up to two letters for the avatar placeholder, e.g. "Omar Adam" -> "OA".
  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts
        .take(2)
        .map((p) => String.fromCharCode(p.runes.first))
        .join()
        .toUpperCase();
  }
}

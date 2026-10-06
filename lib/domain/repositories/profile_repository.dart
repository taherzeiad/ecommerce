import 'dart:typed_data';

import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  /// The signed-in user's profile, or `null` when nobody is signed in.
  Future<ProfileEntity?> getProfile();

  Future<void> updateProfile({required String name, String? phone});

  /// Stores a new profile photo and returns its public URL.
  Future<String> uploadAvatar(Uint8List bytes, String fileExtension);
}

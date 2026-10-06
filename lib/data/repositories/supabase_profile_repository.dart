import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _supabaseClient;

  SupabaseProfileRepository(this._supabaseClient);

  static const _bucket = 'avatars';

  @override
  Future<ProfileEntity?> getProfile() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return null;

    final row = await _supabaseClient
        .from('profiles')
        .select('name, email, phone, avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    final metadataName =
        user.userMetadata?['name'] as String? ??
        user.userMetadata?['full_name'] as String?;
    return ProfileEntity(
      name: row?['name'] as String? ?? metadataName ?? '',
      email: row?['email'] as String? ?? user.email ?? '',
      phone: row?['phone'] as String?,
      avatarUrl: row?['avatar_url'] as String?,
    );
  }

  @override
  Future<void> updateProfile({required String name, String? phone}) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw const AuthException('not_authenticated');

    await _supabaseClient.auth.updateUser(UserAttributes(data: {'name': name}));
    await _supabaseClient.from('profiles').upsert({
      'id': user.id,
      'name': name,
      'email': user.email,
      'phone': phone,
    });
  }

  @override
  Future<String> uploadAvatar(Uint8List bytes, String fileExtension) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw const AuthException('not_authenticated');

    final ext = fileExtension.toLowerCase().replaceAll('jpg', 'jpeg');
    // Storage policies only allow writing inside the user's own folder.
    final path = '${user.id}/avatar.$ext';
    final storage = _supabaseClient.storage.from(_bucket);
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
    );
    // The query string makes image caches load the new photo.
    final url =
        '${storage.getPublicUrl(path)}?v=${DateTime.now().millisecondsSinceEpoch}';
    await _supabaseClient
        .from('profiles')
        .update({'avatar_url': url})
        .eq('id', user.id);
    return url;
  }
}

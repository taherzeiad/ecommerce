import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient _supabaseClient;

  SupabaseNotificationRepository(this._supabaseClient);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return [];

    final response = await _supabaseClient
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((json) {
      return NotificationEntity(
        id: json['id'],
        titleKey: json['title_key'] as String,
        descriptionKey: json['description_key'] as String,
        type: json['type'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
    }).toList();
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';

class SupabaseReviewRepository implements ReviewRepository {
  final SupabaseClient _supabaseClient;

  SupabaseReviewRepository(this._supabaseClient);

  @override
  Future<List<ReviewEntity>> getProductReviews(String productId) async {
    // In a real app, you might join with profiles table to get the name
    final response = await _supabaseClient
        .from('product_reviews')
        .select('*, profiles(name)')
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((json) {
      final profile = json['profiles'] as Map<String, dynamic>?;
      return ReviewEntity(
        id: json['id'],
        productId: json['product_id'] as String,
        userName: profile?['name'] as String? ?? 'User',
        rating: (json['rating'] as num).toDouble(),
        comment: json['comment'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<void> addReview(String productId, double rating, String comment) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    await _supabaseClient.from('product_reviews').insert({
      'product_id': productId,
      'user_id': user.id,
      'rating': rating,
      'comment': comment,
    });
  }
}

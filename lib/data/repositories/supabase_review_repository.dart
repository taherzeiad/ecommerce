import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';

class SupabaseReviewRepository implements ReviewRepository {
  final SupabaseClient _supabaseClient;

  SupabaseReviewRepository(this._supabaseClient);

  @override
  Future<List<ReviewEntity>> getProductReviews(String productId) async {
    // user_name is copied from the profile by a database trigger, so other
    // users' profiles (and emails) never have to be readable.
    final response = await _supabaseClient
        .from('product_reviews')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return response.map((json) {
      return ReviewEntity(
        id: json['id'],
        productId: json['product_id'] as String,
        userName: json['user_name'] as String? ?? 'User',
        rating: (json['rating'] as num).toDouble(),
        comment: json['comment'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );
    }).toList();
  }

  @override
  Future<void> addReview(String productId, double rating, String comment) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw const AuthException('not_authenticated');

    // One review per user and product: a second one replaces the first.
    await _supabaseClient.from('product_reviews').upsert({
      'product_id': productId,
      'user_id': user.id,
      'rating': rating.round(),
      'comment': comment,
    }, onConflict: 'product_id,user_id');
  }
}

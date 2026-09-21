import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<List<ReviewEntity>> getProductReviews(String productId);
  Future<void> addReview(String productId, double rating, String comment);
}

import 'package:flutter/material.dart';
import '../../../domain/entities/review_entity.dart';
import '../../../domain/repositories/review_repository.dart';

class ReviewsViewModel extends ChangeNotifier {
  final ReviewRepository _reviewRepository;

  ReviewsViewModel({required ReviewRepository reviewRepository})
      : _reviewRepository = reviewRepository;

  List<ReviewEntity> _reviews = [];
  List<ReviewEntity> get reviews => _reviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews(String productId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _reviews = await _reviewRepository.getProductReviews(productId);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReview(String productId, double rating, String comment) async {
    try {
      await _reviewRepository.addReview(productId, rating, comment);
      await fetchReviews(productId);
    } catch (e) {
      // Handle error
    }
  }
}

import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../domain/entities/review_entity.dart';
import '../../../domain/repositories/review_repository.dart';

class ReviewsViewModel extends ChangeNotifier {
  final ReviewRepository _reviewRepository;

  ReviewsViewModel({required ReviewRepository reviewRepository})
      : _reviewRepository = reviewRepository;

  List<ReviewEntity> _reviews = [];
  List<ReviewEntity> get reviews => _reviews;

  double get averageRating => _reviews.isEmpty
      ? 0
      : _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;

  /// How many reviews gave each star value (1..5).
  Map<int, int> get ratingBreakdown => {
    for (var star = 5; star >= 1; star--)
      star: _reviews.where((r) => r.rating.round() == star).length,
  };

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReviews(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _reviews = await _reviewRepository.getProductReviews(productId);
    } catch (e) {
      _errorMessage = errorKeyFor(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReview(String productId, double rating, String comment) async {
    try {
      await _reviewRepository.addReview(productId, rating, comment);
    } catch (e) {
      _errorMessage = errorKeyFor(e);
      notifyListeners();
      return false;
    }
    await fetchReviews(productId);
    return true;
  }
}

/// State of the "write a review" form.
class AddReviewViewModel extends ChangeNotifier {
  AddReviewViewModel({required ReviewRepository reviewRepository})
    : _reviewRepository = reviewRepository;

  static const int maxLength = 500;

  final ReviewRepository _reviewRepository;
  final TextEditingController commentController = TextEditingController();

  int _rating = 0;
  int get rating => _rating;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setRating(int value) {
    _rating = value.clamp(1, 5);
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submit(String productId) async {
    if (_rating == 0) {
      _errorMessage = 'error_select_rating';
      notifyListeners();
      return false;
    }
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _reviewRepository.addReview(
        productId,
        _rating.toDouble(),
        commentController.text.trim(),
      );
      return true;
    } catch (e) {
      _errorMessage = errorKeyFor(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}

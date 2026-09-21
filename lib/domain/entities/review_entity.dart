class ReviewEntity {
  final dynamic id;
  final String productId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.productId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> images;
  final bool isFlashDeal;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.description,
    required this.images,
    this.isFlashDeal = false,
  });
}

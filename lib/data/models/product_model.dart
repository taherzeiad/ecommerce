import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.category,
    required super.price,
    super.oldPrice,
    super.rating,
    super.reviewCount,
    required super.description,
    required super.images,
    super.isFlashDeal,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      category: (json['category'] ?? json['category_name']) as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: json['oldPrice'] != null 
          ? (json['oldPrice'] as num).toDouble() 
          : (json['old_price'] != null ? (json['old_price'] as num).toDouble() : null),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] ?? json['review_count']) as int? ?? 0,
      description: json['description'] as String? ?? '',
      images: json['images'] != null 
          ? (json['images'] as List<dynamic>).map((e) => e as String).toList() 
          : [],
      isFlashDeal: (json['isFlashDeal'] ?? json['is_flash_deal']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'oldPrice': oldPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'description': description,
      'images': images,
      'isFlashDeal': isFlashDeal,
    };
  }
}

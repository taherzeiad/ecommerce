enum ProductSort {
  popular,
  newest,
  priceLowToHigh,
  priceHighToLow;

  String get labelKey => switch (this) {
    ProductSort.popular => 'popular',
    ProductSort.newest => 'newest',
    ProductSort.priceLowToHigh => 'price_low_to_high',
    ProductSort.priceHighToLow => 'price_high_to_low',
  };
}

/// Search text plus the options chosen on the Filter & Sort screen.
class ProductFilter {
  static const double maxPriceLimit = 10000;

  final String query;
  final String? category;
  final double minPrice;
  final double maxPrice;
  final ProductSort sort;

  const ProductFilter({
    this.query = '',
    this.category,
    this.minPrice = 0,
    this.maxPrice = maxPriceLimit,
    this.sort = ProductSort.popular,
  });

  /// True when anything other than the search text narrows the results.
  bool get hasOptions =>
      category != null ||
      minPrice > 0 ||
      maxPrice < maxPriceLimit ||
      sort != ProductSort.popular;

  ProductFilter copyWith({
    String? query,
    String? category,
    bool clearCategory = false,
    double? minPrice,
    double? maxPrice,
    ProductSort? sort,
  }) {
    return ProductFilter(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sort: sort ?? this.sort,
    );
  }
}

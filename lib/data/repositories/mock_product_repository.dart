import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class MockProductRepository implements ProductRepository {
  final List<ProductEntity> _dummyProducts = [
    const ProductModel(
      id: '1',
      name: 'Apple MacBook Air M2',
      category: 'Laptop',
      price: 3300.0,
      oldPrice: 3500.0,
      rating: 4.8,
      reviewCount: 120,
      description: 'The latest MacBook Air with M2 chip.',
      images: ['https://m.media-amazon.com/images/I/71TPda7cwUL._AC_SL1500_.jpg'],
      isFlashDeal: true,
    ),
    const ProductModel(
      id: '2',
      name: 'Samsung Galaxy S23',
      category: 'Smartphones',
      price: 900.0,
      oldPrice: 1000.0,
      rating: 4.7,
      reviewCount: 85,
      description: 'Powerful Samsung flagship.',
      images: ['https://m.media-amazon.com/images/I/817WWpa7xIL._AC_SL1500_.jpg'],
      isFlashDeal: true,
    ),
    const ProductModel(
      id: '3',
      name: 'Sony WH-1000XM5',
      category: 'Audio',
      price: 350.0,
      rating: 4.9,
      reviewCount: 200,
      description: 'Industry-leading noise canceling headphones.',
      images: ['https://m.media-amazon.com/images/I/61iVusLwA4L._AC_SL1500_.jpg'],
    ),
    const ProductModel(
      id: '4',
      name: 'Gaming Chair',
      category: 'Gaming',
      price: 250.0,
      oldPrice: 300.0,
      rating: 4.5,
      reviewCount: 50,
      description: 'Comfortable ergonomic gaming chair.',
      images: ['https://m.media-amazon.com/images/I/61M-c19nQdL._AC_SL1001_.jpg'],
    ),
  ];

  @override
  Future<List<ProductEntity>> getFlashDeals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyProducts.where((p) => p.isFlashDeal).toList();
  }

  @override
  Future<List<ProductEntity>> getPopularProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyProducts;
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyProducts.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyProducts.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
}

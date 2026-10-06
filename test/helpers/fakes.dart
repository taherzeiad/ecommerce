import 'dart:async';
import 'dart:typed_data';

import 'package:ecommerce/data/repositories/address_repository.dart';
import 'package:ecommerce/data/repositories/auth_repository.dart';
import 'package:ecommerce/data/repositories/local_payment_card_repository.dart';
import 'package:ecommerce/data/repositories/onboarding_repository.dart';
import 'package:ecommerce/domain/entities/address_entity.dart';
import 'package:ecommerce/domain/entities/notification_entity.dart';
import 'package:ecommerce/domain/entities/order_entity.dart';
import 'package:ecommerce/domain/entities/product_entity.dart';
import 'package:ecommerce/domain/entities/product_filter.dart';
import 'package:ecommerce/domain/entities/profile_entity.dart';
import 'package:ecommerce/domain/entities/review_entity.dart';
import 'package:ecommerce/domain/repositories/cart_repository.dart';
import 'package:ecommerce/domain/repositories/coupon_repository.dart';
import 'package:ecommerce/domain/repositories/notification_repository.dart';
import 'package:ecommerce/domain/repositories/order_repository.dart';
import 'package:ecommerce/domain/repositories/product_repository.dart';
import 'package:ecommerce/domain/repositories/profile_repository.dart';
import 'package:ecommerce/domain/repositories/review_repository.dart';
import 'package:ecommerce/domain/repositories/wishlist_repository.dart';

/// In-memory stand-ins for the Supabase repositories. Every fake can be told
/// to fail (`error = ...`) so tests can check how the UI copes with backend
/// errors, and records what was called so tests can assert on side effects.

ProductEntity makeProduct({
  String id = 'p1',
  String name = 'Galaxy S24',
  String category = 'Smartphones',
  double price = 100,
  double? oldPrice,
  double rating = 4.5,
  List<String> images = const [],
  bool isFlashDeal = false,
}) {
  return ProductEntity(
    id: id,
    name: name,
    category: category,
    price: price,
    oldPrice: oldPrice,
    rating: rating,
    description: '$name description',
    images: images,
    isFlashDeal: isFlashDeal,
  );
}

/// A catalog that covers the awkward cases: a product with no images, a
/// flash deal that is also a popular product, and more categories than the
/// home screen has icons for.
List<ProductEntity> sampleCatalog() => [
  makeProduct(
    id: 'p1',
    name: 'Galaxy S24',
    price: 799.5,
    oldPrice: 899,
    rating: 4.8,
    isFlashDeal: true,
    images: const ['https://example.com/s24.png'],
  ),
  makeProduct(id: 'p2', name: 'iPhone 15', price: 999, rating: 4.7),
  makeProduct(
    id: 'p3',
    name: 'MacBook Air',
    category: 'Laptop',
    price: 1299,
    rating: 4.9,
    isFlashDeal: true,
  ),
  makeProduct(id: 'p4', name: 'AirPods', category: 'Audio', price: 199),
  makeProduct(id: 'p5', name: 'PS5', category: 'Gaming', price: 499),
];

const sampleCategories = [
  'Smartphones',
  'Laptop',
  'Audio',
  'Gaming',
  'Games',
  'Watches',
];

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({
    List<ProductEntity>? products,
    List<String>? categories,
  }) : products = products ?? sampleCatalog(),
       categories = categories ?? List.of(sampleCategories);

  List<ProductEntity> products;
  List<String> categories;
  Object? error;
  final List<String> requestedCategories = [];
  final List<String> searches = [];
  final List<ProductFilter> filters = [];

  void _maybeThrow() {
    if (error != null) throw error!;
  }

  @override
  Future<List<ProductEntity>> getPopularProducts() async {
    _maybeThrow();
    return List.of(products)..sort((a, b) => b.rating.compareTo(a.rating));
  }

  @override
  Future<List<ProductEntity>> getFlashDeals() async {
    _maybeThrow();
    return products.where((p) => p.isFlashDeal).toList();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    _maybeThrow();
    requestedCategories.add(category);
    return products.where((p) => p.category == category).toList();
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) =>
      getProducts(ProductFilter(query: query));

  @override
  Future<List<ProductEntity>> getProducts(ProductFilter filter) async {
    _maybeThrow();
    filters.add(filter);
    if (filter.query.isNotEmpty) searches.add(filter.query);
    final q = filter.query.toLowerCase();
    final result = products.where((p) {
      return p.name.toLowerCase().contains(q) &&
          (filter.category == null || p.category == filter.category) &&
          p.price >= filter.minPrice &&
          (filter.maxPrice >= ProductFilter.maxPriceLimit ||
              p.price <= filter.maxPrice);
    }).toList();
    switch (filter.sort) {
      case ProductSort.popular:
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case ProductSort.newest:
        break;
      case ProductSort.priceLowToHigh:
        result.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHighToLow:
        result.sort((a, b) => b.price.compareTo(a.price));
    }
    return result;
  }

  @override
  Future<List<String>> getCategories() async {
    _maybeThrow();
    return List.of(categories);
  }

  @override
  Future<Map<String, int>> getCategoryProductCounts() async {
    _maybeThrow();
    final counts = <String, int>{};
    for (final p in products) {
      counts[p.category] = (counts[p.category] ?? 0) + 1;
    }
    return counts;
  }
}

class FakeCartRepository implements CartRepository {
  FakeCartRepository(this.catalog);

  final List<ProductEntity> catalog;
  final List<CartItemEntity> rows = [];
  Object? error;
  int _nextId = 1;
  int fetchCount = 0;

  void _maybeThrow() {
    if (error != null) throw error!;
  }

  void seed(ProductEntity product, int quantity) {
    rows.add(
      CartItemEntity(id: _nextId++, product: product, quantity: quantity),
    );
  }

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    _maybeThrow();
    fetchCount++;
    return List.of(rows);
  }

  @override
  Future<void> addToCart(String productId, int quantity) async {
    _maybeThrow();
    final index = rows.indexWhere((r) => r.product.id == productId);
    if (index >= 0) {
      final row = rows[index];
      rows[index] = CartItemEntity(
        id: row.id,
        product: row.product,
        quantity: row.quantity + quantity,
      );
      return;
    }
    final product = catalog.firstWhere((p) => p.id == productId);
    rows.add(
      CartItemEntity(id: _nextId++, product: product, quantity: quantity),
    );
  }

  @override
  Future<void> removeFromCart(dynamic cartItemId) async {
    _maybeThrow();
    rows.removeWhere((r) => r.id == cartItemId);
  }

  @override
  Future<void> updateQuantity(dynamic cartItemId, int quantity) async {
    _maybeThrow();
    final index = rows.indexWhere((r) => r.id == cartItemId);
    final row = rows[index];
    rows[index] = CartItemEntity(
      id: row.id,
      product: row.product,
      quantity: quantity,
    );
  }

  @override
  Future<void> clearCart() async {
    _maybeThrow();
    rows.clear();
  }
}

class FakeCouponRepository implements CouponRepository {
  final Map<String, CouponEntity> coupons = {
    'WELCOME10': const CouponEntity(code: 'WELCOME10', discountPercent: 10),
    'BIG50': const CouponEntity(
      code: 'BIG50',
      discountPercent: 50,
      minOrder: 5000,
    ),
    'OLD20': CouponEntity(
      code: 'OLD20',
      discountPercent: 20,
      expiresAt: DateTime(2020),
    ),
  };
  Object? error;

  @override
  Future<CouponEntity?> findCoupon(String code) async {
    if (error != null) throw error!;
    return coupons[code.trim().toUpperCase()];
  }
}

/// Behaves like the `place_order` database function: prices the cart,
/// applies the coupon, records the order and empties the cart.
class FakeOrderRepository implements OrderRepository {
  FakeOrderRepository({
    this.cart,
    this.addresses,
    FakeCouponRepository? coupons,
  }) : coupons = coupons ?? FakeCouponRepository();

  final FakeCartRepository? cart;
  final FakeAddressRepository? addresses;
  final FakeCouponRepository coupons;
  final List<OrderEntity> orders = [];
  Object? error;

  @override
  Future<List<OrderEntity>> getOrders() async {
    if (error != null) throw error!;
    return List.of(orders.reversed);
  }

  @override
  Future<OrderEntity?> getOrder(String orderId) async {
    if (error != null) throw error!;
    return orders.where((o) => o.id == orderId).firstOrNull;
  }

  @override
  Future<String> placeOrder({
    required String addressId,
    required PaymentMethod paymentMethod,
    String? cardLast4,
    String? couponCode,
  }) async {
    if (error != null) throw error!;
    final rows = cart?.rows ?? const <CartItemEntity>[];
    if (rows.isEmpty) throw Exception('cart_empty');
    double round2(double v) => (v * 100).roundToDouble() / 100;
    final subtotal = rows.fold<double>(
      0,
      (sum, r) => sum + r.product.price * r.quantity,
    );
    var discount = 0.0;
    if (couponCode != null) {
      final coupon = coupons.coupons[couponCode];
      if (coupon == null) throw Exception('invalid_coupon');
      discount = round2(subtotal * coupon.discountPercent / 100);
    }
    final tax = round2((subtotal - discount) * 0.05);
    final address = addresses?.addresses
        .where((a) => a.id == addressId)
        .firstOrNull;
    final order = OrderEntity(
      id: 'order-${(orders.length + 1).toString().padLeft(4, '0')}-abcdef',
      status: OrderStatus.pending,
      subtotal: subtotal,
      discount: discount,
      deliveryFee: 12,
      tax: tax,
      totalAmount: subtotal - discount + 12 + tax,
      couponCode: couponCode,
      paymentMethod: paymentMethod,
      cardLast4: cardLast4,
      shippingName: address?.fullName,
      shippingAddress: address?.streetAddress,
      shippingPhone: address?.phoneNumber,
      createdAt: DateTime(2026, 1, 1, 10, 30),
      items: [
        for (final r in rows)
          OrderItemEntity(
            productId: r.product.id,
            productName: r.product.name,
            unitPrice: r.product.price,
            quantity: r.quantity,
          ),
      ],
    );
    orders.add(order);
    lastAddressId = addressId;
    rows.clear();
    return order.id;
  }

  String? lastAddressId;
}

class FakeWishlistRepository implements WishlistRepository {
  FakeWishlistRepository(this.catalog);

  final List<ProductEntity> catalog;
  final Set<String> ids = {};
  Object? error;

  @override
  Future<List<ProductEntity>> getWishlist() async {
    if (error != null) throw error!;
    return catalog.where((p) => ids.contains(p.id)).toList();
  }

  @override
  Future<void> toggleWishlist(String productId) async {
    if (error != null) throw error!;
    if (!ids.remove(productId)) ids.add(productId);
  }

  @override
  Future<bool> isInWishlist(String productId) async => ids.contains(productId);
}

AddressEntity makeAddress({
  String? id = 'a1',
  String fullName = 'Omar Adam',
  bool isDefault = false,
}) {
  return AddressEntity(
    id: id,
    userId: 'u1',
    fullName: fullName,
    phoneNumber: '0590000000',
    streetAddress: '5 Main St',
    city: 'Gaza',
    postalCode: '00970',
    country: 'Palestine',
    isDefault: isDefault,
  );
}

class FakeAddressRepository implements AddressRepository {
  final List<AddressEntity> addresses = [];
  Object? error;
  int _nextId = 100;

  AddressEntity _copy(AddressEntity a, {String? id, bool? isDefault}) =>
      AddressEntity(
        id: id ?? a.id,
        userId: a.userId,
        fullName: a.fullName,
        phoneNumber: a.phoneNumber,
        streetAddress: a.streetAddress,
        city: a.city,
        postalCode: a.postalCode,
        country: a.country,
        isDefault: isDefault ?? a.isDefault,
      );

  @override
  Future<List<AddressEntity>> getAddresses() async {
    if (error != null) throw error!;
    return List.of(addresses);
  }

  @override
  Future<String> addAddress(AddressEntity address) async {
    if (error != null) throw error!;
    final id = '${_nextId++}';
    addresses.add(_copy(address, id: id));
    return id;
  }

  @override
  Future<void> updateAddress(AddressEntity address) async {
    if (error != null) throw error!;
    final i = addresses.indexWhere((a) => a.id == address.id);
    if (i >= 0) addresses[i] = address;
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    if (error != null) throw error!;
    addresses.removeWhere((a) => a.id == addressId);
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    if (error != null) throw error!;
    for (var i = 0; i < addresses.length; i++) {
      addresses[i] = _copy(
        addresses[i],
        isDefault: addresses[i].id == addressId,
      );
    }
  }
}

class FakeNotificationRepository implements NotificationRepository {
  List<NotificationEntity> notifications = [
    NotificationEntity(
      id: 1,
      titleKey: 'notif_order_shipped_title',
      descriptionKey: 'notif_order_shipped_desc',
      type: 'orders',
      orderId: 'order-0001-abcdef',
      createdAt: DateTime(2026, 1, 3, 9, 5),
    ),
    NotificationEntity(
      id: 2,
      titleKey: 'unknown_key_from_backend',
      descriptionKey: 'unknown_desc_from_backend',
      type: 'system',
      isRead: true,
      createdAt: DateTime(2026, 1, 3, 14, 30),
    ),
  ];
  Object? error;
  final List<dynamic> markedRead = [];
  int markAllCount = 0;

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    if (error != null) throw error!;
    return List.of(notifications);
  }

  @override
  Future<void> markAsRead(dynamic notificationId) async {
    markedRead.add(notificationId);
    notifications = [
      for (final n in notifications)
        n.id == notificationId ? n.markedRead() : n,
    ];
  }

  @override
  Future<void> markAllAsRead() async {
    markAllCount++;
    notifications = [for (final n in notifications) n.markedRead()];
  }
}

class FakeReviewRepository implements ReviewRepository {
  final List<ReviewEntity> reviews = [
    ReviewEntity(
      id: 1,
      productId: 'p1',
      userName: 'Sara',
      rating: 4,
      comment: 'Great phone',
      createdAt: DateTime(2026, 1, 1),
    ),
    ReviewEntity(
      id: 2,
      productId: 'p1',
      userName: 'Ali',
      rating: 5,
      comment: 'Excellent',
      createdAt: DateTime(2026, 1, 2),
    ),
  ];
  Object? error;

  @override
  Future<List<ReviewEntity>> getProductReviews(String productId) async {
    if (error != null) throw error!;
    return reviews.where((r) => r.productId == productId).toList();
  }

  @override
  Future<void> addReview(
    String productId,
    double rating,
    String comment,
  ) async {
    if (error != null) throw error!;
    reviews.removeWhere((r) => r.productId == productId && r.userName == 'Me');
    reviews.insert(
      0,
      ReviewEntity(
        id: reviews.length + 10,
        productId: productId,
        userName: 'Me',
        rating: rating,
        comment: comment,
        createdAt: DateTime(2026, 2, 1),
      ),
    );
  }
}

class FakeAuthRepository implements AuthRepository {
  bool loggedIn = false;
  String? name = 'Omar Adam';
  String? email = 'omar@example.com';
  String password = 'secret1';
  Object? loginError;
  Object? signupError;
  Object? resetLinkError;
  Object? otpError;
  Object? resetPasswordError;
  Object? providerError;

  /// When true, sign-up behaves like a project with email confirmation on.
  bool signupNeedsConfirmation = false;

  /// When true, a provider sign-in "comes back" signed in right away.
  bool providerSucceeds = true;
  int logoutCount = 0;

  /// Simulated network time for sign-out.
  Duration logoutDelay = Duration.zero;
  final List<String> calls = [];
  final _authChanges = StreamController<bool>.broadcast();

  @override
  Future<void> login(String email, String password) async {
    calls.add('login:$email');
    if (loginError != null) throw loginError!;
    loggedIn = true;
    this.email = email;
  }

  @override
  Future<bool> signup(String name, String email, String password) async {
    calls.add('signup:$email');
    if (signupError != null) throw signupError!;
    this.name = name;
    this.email = email;
    loggedIn = !signupNeedsConfirmation;
    return loggedIn;
  }

  @override
  Future<void> sendResetLink(String email) async {
    calls.add('sendResetLink:$email');
    if (resetLinkError != null) throw resetLinkError!;
  }

  @override
  Future<void> verifyOtp(String email, String otp) async {
    calls.add('verifyOtp:$email:$otp');
    if (otpError != null) throw otpError!;
    loggedIn = true;
  }

  @override
  Future<void> resetPassword(String password) async {
    calls.add('resetPassword');
    if (resetPasswordError != null) throw resetPasswordError!;
    this.password = password;
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    calls.add('changePassword');
    if (currentPassword != password) {
      throw Exception('Invalid login credentials');
    }
    password = newPassword;
  }

  @override
  Future<void> signInWithProvider(SocialProvider provider) async {
    calls.add('provider:${provider.name}');
    if (providerError != null) throw providerError!;
    if (providerSucceeds) {
      // The browser round-trip finishes a moment later.
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        loggedIn = true;
        _authChanges.add(true);
      });
    }
  }

  @override
  Stream<bool> get authStateChanges => _authChanges.stream;

  @override
  Future<void> logout() async {
    await Future<void>.delayed(logoutDelay);
    logoutCount++;
    loggedIn = false;
  }

  @override
  String? getCurrentUserId() => loggedIn ? 'u1' : null;

  @override
  String? getCurrentUserEmail() => loggedIn ? email : null;

  @override
  String? getCurrentUserName() => loggedIn ? name : null;

  @override
  bool isUserLoggedIn() => loggedIn;
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository(this.auth);

  final FakeAuthRepository auth;
  String? phone;
  String? avatarUrl;
  Object? error;
  final List<String> updates = [];
  final List<Uint8List> uploads = [];

  @override
  Future<ProfileEntity?> getProfile() async {
    if (error != null) throw error!;
    if (!auth.loggedIn) return null;
    return ProfileEntity(
      name: auth.name ?? '',
      email: auth.email ?? '',
      phone: phone,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<void> updateProfile({required String name, String? phone}) async {
    if (error != null) throw error!;
    updates.add('$name|${phone ?? ''}');
    auth.name = name;
    this.phone = phone;
  }

  @override
  Future<String> uploadAvatar(Uint8List bytes, String fileExtension) async {
    if (error != null) throw error!;
    uploads.add(bytes);
    avatarUrl = 'https://example.com/avatar.$fileExtension';
    return avatarUrl!;
  }
}

/// In-memory replacement for the device keychain.
class InMemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({this.completed = false});

  bool completed;

  @override
  Future<bool> hasCompletedOnboarding() async => completed;

  @override
  Future<void> setOnboardingCompleted() async => completed = true;
}

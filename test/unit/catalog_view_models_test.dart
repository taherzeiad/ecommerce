import 'package:ecommerce/domain/entities/order_entity.dart';
import 'package:ecommerce/domain/entities/product_filter.dart';
import 'package:ecommerce/presentation/categories/view_model/categories_view_model.dart';
import 'package:ecommerce/presentation/home/view_model/home_view_model.dart';
import 'package:ecommerce/presentation/notifications/view_model/notifications_view_model.dart';
import 'package:ecommerce/presentation/orders/view_model/orders_view_model.dart';
import 'package:ecommerce/presentation/reviews/view_model/reviews_view_model.dart';
import 'package:ecommerce/presentation/search/view_model/search_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeProductRepository repo;

  setUp(() => repo = FakeProductRepository());

  group('HomeViewModel', () {
    test(
      'loads popular products, flash deals and categories together',
      () async {
        final vm = HomeViewModel(productRepository: repo);

        await vm.fetchHomeData();

        expect(vm.isLoading, isFalse);
        expect(vm.popularProducts.first.rating, 4.9);
        expect(vm.flashDeals.map((p) => p.id), ['p1', 'p3']);
        expect(vm.categories, sampleCategories);
        expect(vm.errorMessage, isNull);
      },
    );

    test('a backend error ends loading and says why', () async {
      repo.error = Exception('Failed host lookup');
      final vm = HomeViewModel(productRepository: repo);

      await vm.fetchHomeData();

      expect(vm.isLoading, isFalse);
      expect(vm.popularProducts, isEmpty);
      expect(vm.errorMessage, 'error_network');
    });
  });

  group('CategoriesViewModel', () {
    test(
      'fetchCategories loads counts and the first category products',
      () async {
        final vm = CategoriesViewModel(productRepository: repo);

        await vm.fetchCategories();

        expect(vm.categories, sampleCategories);
        expect(vm.categoryCounts['Smartphones'], 2);
        expect(vm.selectedCategory, 'Smartphones');
        expect(vm.categoryProducts.map((p) => p.id), ['p1', 'p2']);
        expect(vm.isLoading, isFalse);
      },
    );

    test('fetchCategories keeps an already selected category', () async {
      final vm = CategoriesViewModel(productRepository: repo);
      await vm.fetchProductsByCategory('Audio');

      await vm.fetchCategories();

      expect(vm.selectedCategory, 'Audio');
      expect(vm.categoryProducts.single.name, 'AirPods');
    });

    test('flash deals and "all" are collections of their own', () async {
      final vm = CategoriesViewModel(productRepository: repo);

      await vm.showFlashDeals();
      expect(vm.collection, ProductCollection.flashDeals);
      expect(vm.categoryProducts.map((p) => p.id), ['p1', 'p3']);

      await vm.fetchCategories();
      expect(
        vm.collection,
        ProductCollection.flashDeals,
        reason: 'loading the chips must not switch to a category',
      );

      await vm.showAllProducts();
      expect(vm.categoryProducts, hasLength(5));
    });

    test('retry reloads what failed', () async {
      repo.error = Exception('offline');
      final vm = CategoriesViewModel(productRepository: repo);
      await vm.fetchProductsByCategory('Gaming');
      expect(vm.errorMessage, isNotNull);

      repo.error = null;
      await vm.retry();

      expect(vm.errorMessage, isNull);
      expect(vm.categoryProducts.single.id, 'p5');
    });
  });

  group('SearchViewModel', () {
    test('finds products by name, case-insensitively', () async {
      final vm = SearchViewModel(productRepository: repo);

      await vm.search('galaxy');

      expect(vm.query, 'galaxy');
      expect(vm.results.single.id, 'p1');
    });

    test('an empty query clears results without calling the backend', () async {
      final vm = SearchViewModel(productRepository: repo);
      await vm.search('iphone');

      await vm.search('');

      expect(vm.results, isEmpty);
      expect(vm.hasSearched, isFalse);
      expect(repo.searches, ['iphone']);
    });

    test(
      'filters work without any text and keep the text when given',
      () async {
        final vm = SearchViewModel(productRepository: repo);

        await vm.applyFilter(
          const ProductFilter(maxPrice: 1000, sort: ProductSort.priceLowToHigh),
        );
        expect(vm.results.map((p) => p.price), [199, 499, 799.5, 999]);

        await vm.search('i');
        expect(vm.filter.sort, ProductSort.priceLowToHigh);
        await vm.applyFilter(const ProductFilter(category: 'Smartphones'));
        expect(vm.query, 'i');
        expect(vm.results.map((p) => p.id), ['p2']);
      },
    );

    test('an initial filter (from the filter screen) runs at once', () async {
      final vm = SearchViewModel(
        productRepository: repo,
        initialFilter: const ProductFilter(category: 'Audio'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(vm.results.single.name, 'AirPods');
    });

    test('a backend error shows an error instead of crashing', () async {
      repo.error = Exception('offline');
      final vm = SearchViewModel(productRepository: repo);

      await vm.search('x');

      expect(vm.results, isEmpty);
      expect(vm.errorMessage, isNotNull);
      expect(vm.isLoading, isFalse);
    });
  });

  group('ReviewsViewModel', () {
    test('loads reviews, averages them and adds new ones', () async {
      final reviews = FakeReviewRepository();
      final vm = ReviewsViewModel(reviewRepository: reviews);

      await vm.fetchReviews('p1');
      expect(vm.reviews, hasLength(2));
      expect(vm.averageRating, 4.5);
      expect(vm.ratingBreakdown[5], 1);
      expect(vm.ratingBreakdown[4], 1);

      expect(await vm.addReview('p1', 3, 'ok'), isTrue);
      expect(vm.reviews, hasLength(3));
    });

    test('AddReviewViewModel needs a star rating', () async {
      final reviews = FakeReviewRepository();
      final vm = AddReviewViewModel(reviewRepository: reviews);

      expect(await vm.submit('p1'), isFalse);
      expect(vm.errorMessage, 'error_select_rating');

      vm.setRating(4);
      vm.commentController.text = '  Nice  ';
      expect(await vm.submit('p1'), isTrue);
      expect(reviews.reviews.first.comment, 'Nice');
      expect(reviews.reviews.first.rating, 4);
      vm.dispose();
    });
  });

  group('NotificationsViewModel', () {
    test('counts unread and marks them read', () async {
      final repo = FakeNotificationRepository();
      final vm = NotificationsViewModel(notificationRepository: repo);

      await vm.fetchNotifications();
      expect(vm.unreadCount, 1);

      await vm.markAsRead(vm.notifications.first);
      expect(vm.unreadCount, 0);
      expect(repo.markedRead, [1]);
    });

    test('mark all as read', () async {
      final repo = FakeNotificationRepository();
      final vm = NotificationsViewModel(notificationRepository: repo);
      await vm.fetchNotifications();

      await vm.markAllAsRead();

      expect(vm.unreadCount, 0);
      expect(repo.markAllCount, 1);
    });

    test('survives errors', () async {
      final repo = FakeNotificationRepository()..error = Exception('offline');
      final vm = NotificationsViewModel(notificationRepository: repo);

      await vm.fetchNotifications();

      expect(vm.isLoading, isFalse);
      expect(vm.errorMessage, isNotNull);
    });
  });

  group('OrdersViewModel', () {
    test('lists orders and loads one by id', () async {
      final cart = FakeCartRepository(sampleCatalog())
        ..seed(sampleCatalog().first, 2);
      final orders = FakeOrderRepository(cart: cart);
      final id = await orders.placeOrder(
        addressId: 'a1',
        paymentMethod: PaymentMethod.cash,
      );
      final vm = OrdersViewModel(orderRepository: orders);

      await vm.fetchOrders();
      expect(vm.orders.single.itemCount, 2);

      final order = await vm.loadOrder(id);
      expect(order!.status, OrderStatus.pending);
      expect(vm.orderById(id), isNotNull);
    });

    test('reports errors', () async {
      final orders = FakeOrderRepository()..error = Exception('offline');
      final vm = OrdersViewModel(orderRepository: orders);

      await vm.fetchOrders();

      expect(vm.errorMessage, isNotNull);
    });
  });
}

import 'package:ecommerce/domain/entities/order_entity.dart';
import 'package:ecommerce/domain/entities/product_entity.dart';
import 'package:ecommerce/presentation/cart/view_model/cart_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late List<ProductEntity> catalog;
  late FakeCartRepository cartRepo;
  late FakeCouponRepository couponRepo;
  late FakeOrderRepository orderRepo;
  late CartViewModel vm;

  setUp(() {
    catalog = sampleCatalog();
    cartRepo = FakeCartRepository(sampleCatalog());
    couponRepo = FakeCouponRepository();
    orderRepo = FakeOrderRepository(cart: cartRepo, coupons: couponRepo);
    vm = CartViewModel(
      cartRepository: cartRepo,
      orderRepository: orderRepo,
      couponRepository: couponRepo,
    );
  });

  group('totals', () {
    test('empty cart costs nothing (no delivery fee)', () {
      expect(vm.totalItems, 0);
      expect(vm.subtotal, 0);
      expect(vm.deliveryFees, 0);
      expect(vm.taxes, 0);
      expect(vm.totalPrice, 0);
    });

    test('subtotal, 5% tax and flat 12 delivery fee', () async {
      cartRepo.seed(makeProduct(id: 'a', price: 100), 2);
      cartRepo.seed(makeProduct(id: 'b', price: 50), 1);
      await vm.fetchCartItems();

      expect(vm.totalItems, 3);
      expect(vm.subtotal, 250);
      expect(vm.deliveryFees, 12);
      expect(vm.taxes, closeTo(12.5, 1e-9));
      expect(vm.totalPrice, closeTo(274.5, 1e-9));
    });
  });

  test('fetchCartItems toggles isLoading and notifies', () async {
    cartRepo.seed(catalog.first, 1);
    final loadingStates = <bool>[];
    vm.addListener(() => loadingStates.add(vm.isLoading));

    await vm.fetchCartItems();

    expect(loadingStates, [true, false]);
    expect(vm.items, hasLength(1));
  });

  test('only the first load counts as "initial" (no spinner on +/-)', () async {
    expect(vm.isInitialLoading, isFalse);
    final states = <bool>[];
    vm.addListener(() => states.add(vm.isInitialLoading));

    await vm.fetchCartItems();
    await vm.fetchCartItems();

    expect(states, [true, false, false, false]);
  });

  test(
    'a failing fetch keeps the old items, stops loading, reports why',
    () async {
      cartRepo.seed(catalog.first, 1);
      await vm.fetchCartItems();
      cartRepo.error = Exception('SocketException: offline');

      await vm.fetchCartItems();

      expect(vm.isLoading, isFalse);
      expect(vm.items, hasLength(1));
      expect(vm.errorMessage, 'error_network');
    },
  );

  test('adding the same product twice merges into one line', () async {
    final p = catalog.first;
    await vm.addToCart(p);
    await vm.addToCart(p, quantity: 2);

    expect(vm.items, hasLength(1));
    expect(vm.items.single.quantity, 3);
  });

  test('addToCart reports failure', () async {
    cartRepo.error = Exception('500');

    expect(await vm.addToCart(catalog.first), isFalse);
  });

  test('increment and decrement change the quantity', () async {
    await vm.addToCart(catalog.first, quantity: 2);

    await vm.incrementQuantity(vm.items.single);
    expect(vm.items.single.quantity, 3);

    await vm.decrementQuantity(vm.items.single);
    expect(vm.items.single.quantity, 2);
  });

  test('decrement never goes below 1', () async {
    await vm.addToCart(catalog.first);

    await vm.decrementQuantity(vm.items.single);

    expect(vm.items.single.quantity, 1);
  });

  test(
    'removeFromCart drops the line immediately (needed by Dismissible)',
    () async {
      await vm.addToCart(catalog[0]);
      await vm.addToCart(catalog[1]);
      final id = vm.items.first.id;

      final pending = vm.removeFromCart(id);
      expect(vm.items.map((i) => i.id), isNot(contains(id)));
      await pending;

      expect(vm.items, hasLength(1));
      expect(cartRepo.rows, hasLength(1));
    },
  );

  test('a failed remove puts the item back', () async {
    await vm.addToCart(catalog[0]);
    final id = vm.items.single.id;
    cartRepo.error = Exception('offline');

    await vm.removeFromCart(id);

    cartRepo.error = null;
    await vm.fetchCartItems();
    expect(vm.items, hasLength(1));
  });

  test('items list cannot be modified from outside', () {
    expect(() => vm.items.clear(), throwsUnsupportedError);
  });

  group('coupons', () {
    setUp(() async {
      cartRepo.seed(makeProduct(id: 'a', price: 200), 1);
      await vm.fetchCartItems();
    });

    test('a valid code takes its percentage off before tax', () async {
      expect(await vm.applyCoupon(' welcome10 '), isNull);

      expect(vm.coupon!.code, 'WELCOME10');
      expect(vm.discount, 20);
      expect(vm.taxes, closeTo(9, 1e-9)); // 5% of 180
      expect(vm.totalPrice, closeTo(200 - 20 + 12 + 9, 1e-9));
    });

    test('unknown, expired and too-small orders are refused', () async {
      expect(await vm.applyCoupon('NOPE'), 'error_invalid_coupon');
      expect(await vm.applyCoupon('OLD20'), 'error_invalid_coupon');
      expect(await vm.applyCoupon('BIG50'), 'error_coupon_min_order');
      expect(await vm.applyCoupon(''), 'error_invalid_coupon');
      expect(vm.coupon, isNull);
    });

    test('removeCoupon restores the full price', () async {
      await vm.applyCoupon('WELCOME10');
      vm.removeCoupon();

      expect(vm.discount, 0);
    });
  });

  group('placeOrder', () {
    test('creates the order with the same total the screen showed', () async {
      await vm.addToCart(makeProduct(id: 'p1', price: 100));
      await vm.addToCart(makeProduct(id: 'p1'));
      await vm.applyCoupon('WELCOME10');
      final shownTotal = vm.totalPrice;

      final id = await vm.placeOrder(
        addressId: 'a1',
        paymentMethod: PaymentMethod.card,
        cardLast4: '4242',
      );

      expect(id, isNotNull);
      final order = orderRepo.orders.single;
      expect(order.totalAmount, closeTo(shownTotal, 1e-9));
      expect(order.couponCode, 'WELCOME10');
      expect(order.cardLast4, '4242');
      expect(orderRepo.lastAddressId, 'a1');
      expect(vm.items, isEmpty);
      expect(vm.coupon, isNull);
      expect(cartRepo.rows, isEmpty);
    });

    test('refuses to order without a delivery address', () async {
      await vm.addToCart(catalog.first);

      final id = await vm.placeOrder(
        addressId: null,
        paymentMethod: PaymentMethod.cash,
      );

      expect(id, isNull);
      expect(vm.orderError, 'no_address_msg');
      expect(orderRepo.orders, isEmpty);
      expect(vm.items, hasLength(1));
    });

    test('refuses an empty cart and a card payment without a card', () async {
      expect(
        await vm.placeOrder(addressId: 'a1', paymentMethod: PaymentMethod.cash),
        isNull,
      );
      expect(vm.orderError, 'cart_empty');

      await vm.addToCart(catalog.first);
      expect(
        await vm.placeOrder(addressId: 'a1', paymentMethod: PaymentMethod.card),
        isNull,
      );
      expect(vm.orderError, 'error_select_card');
      expect(orderRepo.orders, isEmpty);
    });

    test('reports failure and keeps the cart when the backend fails', () async {
      await vm.addToCart(catalog.first);
      orderRepo.error = Exception('500');

      final id = await vm.placeOrder(
        addressId: 'a1',
        paymentMethod: PaymentMethod.cash,
      );

      expect(id, isNull);
      expect(vm.orderError, 'error_unexpected');
      expect(vm.isPlacingOrder, isFalse);
      expect(vm.items, hasLength(1));
    });
  });
}

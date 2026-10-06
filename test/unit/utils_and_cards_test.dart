import 'dart:convert';

import 'package:ecommerce/core/utils/error_mapper.dart';
import 'package:ecommerce/core/utils/formatters.dart';
import 'package:ecommerce/core/widgets/category_icon.dart';
import 'package:ecommerce/data/models/order_model.dart';
import 'package:ecommerce/data/repositories/local_payment_card_repository.dart';
import 'package:ecommerce/domain/entities/order_entity.dart';
import 'package:ecommerce/domain/entities/payment_card_entity.dart';
import 'package:ecommerce/domain/entities/profile_entity.dart';
import 'package:ecommerce/presentation/payment/view_model/payment_cards_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('formatters', () {
    test('prices have two decimals and thousands separators', () {
      expect(formatPrice(0), r'$0.00');
      expect(formatPrice(799.5), r'$799.50');
      expect(formatPrice(4500), r'$4,500.00');
      expect(formatPrice(1234567.891), r'$1,234,567.89');
      expect(formatPrice(-12), r'-$12.00');
    });

    test('dates and times are zero-padded', () {
      final t = DateTime(2026, 1, 3, 9, 5);
      expect(formatTime(t), '09:05');
      expect(formatDate(t), '03/01/2026');
    });
  });

  test('errorKeyFor turns exceptions into translation keys', () {
    expect(
      errorKeyFor(Exception('SocketException: Failed host lookup')),
      'error_network',
    );
    expect(
      errorKeyFor(Exception('PostgrestException(message: invalid_coupon)')),
      'error_invalid_coupon',
    );
    expect(errorKeyFor(Exception('address_not_found')), 'no_address_msg');
    expect(errorKeyFor(Exception('JWT expired')), 'error_session_expired');
    expect(errorKeyFor(Exception('weird')), 'error_unexpected');
  });

  test('category icons follow the name in English and Arabic', () {
    expect(CategoryIcon.assetFor('Smartphones'), contains('phone'));
    expect(CategoryIcon.assetFor('هواتف ذكية'), contains('phone'));
    expect(CategoryIcon.assetFor('أجهزة كمبيوتر'), contains('laptop'));
    expect(CategoryIcon.assetFor('إلكترونيات'), contains('sound'));
    expect(CategoryIcon.assetFor('Gaming'), contains('play'));
    expect(CategoryIcon.assetFor('ساعات ذكية'), isNull);
  });

  test('profile initials', () {
    expect(ProfileEntity.initialsOf('Omar Adam Khaled'), 'OA');
    expect(ProfileEntity.initialsOf('  عمر  '), 'ع');
    expect(ProfileEntity.initialsOf(''), '');
  });

  test('OrderModel parses an order with its items', () {
    final order = OrderModel.fromJson({
      'id': 'abcdef12-3456',
      'status': 'shipped',
      'subtotal': 100,
      'discount': 10,
      'delivery_fee': 12,
      'tax': 4.5,
      'total_amount': 106.5,
      'coupon_code': 'WELCOME10',
      'payment_method': 'card',
      'card_last4': '4242',
      'created_at': '2026-01-01T10:00:00Z',
      'order_items': [
        {'product_name': 'A', 'unit_price': 50, 'quantity': 2},
      ],
    });

    expect(order.number, 'ABCDEF12');
    expect(order.status, OrderStatus.shipped);
    expect(order.paymentMethod, PaymentMethod.card);
    expect(order.itemCount, 2);
    expect(order.items.single.lineTotal, 100);
  });

  group('CardValidator', () {
    test('accepts real test card numbers and rejects typos', () {
      expect(CardValidator.number('4242 4242 4242 4242'), isNull);
      expect(CardValidator.number('5555555555554444'), isNull);
      expect(CardValidator.number('4242 4242 4242 4241'), 'error_card_number');
      expect(CardValidator.number('1234'), 'error_card_number');
    });

    test('detects the brand', () {
      expect(CardBrand.fromNumber('4242424242424242'), CardBrand.visa);
      expect(CardBrand.fromNumber('5555555555554444'), CardBrand.mastercard);
      expect(CardBrand.fromNumber('2223003122003222'), CardBrand.mastercard);
      expect(CardBrand.fromNumber('378282246310005'), CardBrand.amex);
      expect(CardBrand.fromNumber('6011111111111117'), CardBrand.other);
    });

    test('expiry must be MM/YY and not in the past', () {
      final now = DateTime(2026, 10, 6);
      expect(CardValidator.expiry('10/26', now: now), isNull);
      expect(CardValidator.expiry('09/26', now: now), 'error_card_expired');
      expect(CardValidator.expiry('13/27', now: now), 'error_card_expiry');
      expect(CardValidator.expiry('1027', now: now), 'error_card_expiry');
    });

    test('CVV is 3 or 4 digits', () {
      expect(CardValidator.cvv('123'), isNull);
      expect(CardValidator.cvv('1234'), isNull);
      expect(CardValidator.cvv('12'), 'error_card_cvv');
      expect(CardValidator.cvv('12a'), 'error_card_cvv');
    });
  });

  group('saved cards', () {
    late InMemorySecureStore store;
    late String? userId;
    late PaymentCardsViewModel vm;

    setUp(() {
      store = InMemorySecureStore();
      userId = 'u1';
      vm = PaymentCardsViewModel(
        cardRepository: LocalPaymentCardRepository(store, userId: () => userId),
      );
    });

    test('only the masked card is stored, never the number or CVV', () async {
      final card = await vm.addCard(
        holderName: 'Omar Adam',
        number: '4242 4242 4242 4242',
        expiry: '12/30',
        cvv: '987',
        now: DateTime(2026, 10, 6),
      );

      expect(card.last4, '4242');
      expect(card.brand, CardBrand.visa);
      expect(card.maskedNumber, '**** **** **** 4242');
      expect(card.isDefault, isTrue, reason: 'first card is the default');
      final raw = store.values.values.join();
      expect(raw, isNot(contains('4242424242424242')));
      expect(raw, isNot(contains('987')));
      expect(jsonDecode(raw), isA<List<dynamic>>());
    });

    test('invalid fields are reported per field', () async {
      expect(
        () => vm.addCard(holderName: '', number: '1', expiry: 'x', cvv: ''),
        throwsA(
          isA<CardFormException>().having(
            (e) => e.errors.keys,
            'fields',
            containsAll(['name', 'number', 'expiry', 'cvv']),
          ),
        ),
      );
    });

    test(
      'default card moves when it is deleted, and lists are per user',
      () async {
        final now = DateTime(2026, 10, 6);
        final first = await vm.addCard(
          holderName: 'Ali',
          number: '4242424242424242',
          expiry: '12/30',
          cvv: '123',
          now: now,
        );
        final second = await vm.addCard(
          holderName: 'Bob',
          number: '5555555555554444',
          expiry: '12/30',
          cvv: '123',
          now: now,
        );
        await vm.setDefaultCard(second.id);
        expect(vm.defaultCard!.id, second.id);

        await vm.deleteCard(second.id);
        expect(vm.cards.single.id, first.id);
        expect(vm.defaultCard!.isDefault, isTrue);

        userId = 'someone-else';
        await vm.fetchCards();
        expect(vm.cards, isEmpty);
      },
    );
  });
}

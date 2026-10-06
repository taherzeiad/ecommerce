import 'package:flutter/material.dart';

import '../../../core/utils/error_mapper.dart';
import '../../../domain/entities/payment_card_entity.dart';
import '../../../domain/repositories/payment_card_repository.dart';

class PaymentCardsViewModel extends ChangeNotifier {
  PaymentCardsViewModel({required PaymentCardRepository cardRepository})
    : _cardRepository = cardRepository;

  final PaymentCardRepository _cardRepository;
  static int _nextId = 0;

  List<PaymentCardEntity> _cards = [];
  List<PaymentCardEntity> get cards => List.unmodifiable(_cards);

  PaymentCardEntity? get defaultCard =>
      _cards.where((c) => c.isDefault).firstOrNull ?? _cards.firstOrNull;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _cards = await _cardRepository.getCards();
    } catch (e) {
      _errorMessage = errorKeyFor(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validates and saves a card. Only the last 4 digits are kept; the CVV
  /// is checked and then discarded. Returns the saved card, or throws a
  /// [CardFormException] naming the field and translation key at fault.
  Future<PaymentCardEntity> addCard({
    required String holderName,
    required String number,
    required String expiry,
    required String cvv,
    DateTime? now,
  }) async {
    final problems = <String, String>{
      'name': ?CardValidator.holderName(holderName),
      'number': ?CardValidator.number(number),
      'expiry': ?CardValidator.expiry(expiry, now: now),
      'cvv': ?CardValidator.cvv(cvv),
    };
    if (problems.isNotEmpty) throw CardFormException(problems);

    final digits = CardValidator.digitsOnly(number);
    final parts = expiry.split('/').map((p) => int.parse(p.trim())).toList();
    final card = PaymentCardEntity(
      // The counter keeps ids unique even within the same microsecond.
      id: '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}',
      holderName: holderName.trim(),
      last4: digits.substring(digits.length - 4),
      brand: CardBrand.fromNumber(digits),
      expiryMonth: parts[0],
      expiryYear: 2000 + parts[1],
    );
    try {
      await _cardRepository.saveCard(card);
    } catch (e) {
      throw CardFormException({'save': errorKeyFor(e)});
    }
    await fetchCards();
    return _cards.firstWhere((c) => c.id == card.id, orElse: () => card);
  }

  Future<void> deleteCard(String cardId) async {
    _cards = _cards.where((c) => c.id != cardId).toList();
    notifyListeners();
    try {
      await _cardRepository.deleteCard(cardId);
    } finally {
      await fetchCards();
    }
  }

  Future<void> setDefaultCard(String cardId) async {
    try {
      await _cardRepository.setDefaultCard(cardId);
    } finally {
      await fetchCards();
    }
  }
}

/// Field name -> translation key of what is wrong with it.
class CardFormException implements Exception {
  CardFormException(this.errors);

  final Map<String, String> errors;

  @override
  String toString() => 'CardFormException($errors)';
}

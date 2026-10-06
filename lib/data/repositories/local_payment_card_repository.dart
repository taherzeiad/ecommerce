import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/payment_card_entity.dart';
import '../../domain/repositories/payment_card_repository.dart';

/// Minimal key-value store, so the repository can be tested without the
/// platform keychain.
abstract class SecureKeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  FlutterSecureKeyValueStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

/// Keeps saved cards on the device, encrypted, one list per user. Only the
/// masked card (holder, brand, last 4 digits, expiry) is ever stored.
class LocalPaymentCardRepository implements PaymentCardRepository {
  LocalPaymentCardRepository(this._store, {required String? Function() userId})
    : _userId = userId;

  final SecureKeyValueStore _store;
  final String? Function() _userId;

  String get _key => 'payment_cards_${_userId() ?? 'guest'}';

  @override
  Future<List<PaymentCardEntity>> getCards() async {
    final raw = await _store.read(_key);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(PaymentCardEntity.fromJson)
        .toList();
  }

  Future<void> _write(List<PaymentCardEntity> cards) =>
      _store.write(_key, jsonEncode(cards.map((c) => c.toJson()).toList()));

  @override
  Future<void> saveCard(PaymentCardEntity card) async {
    final cards = (await getCards()).where((c) => c.id != card.id).toList();
    final makeDefault = card.isDefault || cards.isEmpty;
    await _write([
      for (final c in cards) makeDefault ? c.copyWith(isDefault: false) : c,
      card.copyWith(isDefault: makeDefault),
    ]);
  }

  @override
  Future<void> deleteCard(String cardId) async {
    final cards = await getCards();
    final removed = cards.where((c) => c.id == cardId).firstOrNull;
    final rest = cards.where((c) => c.id != cardId).toList();
    if ((removed?.isDefault ?? false) && rest.isNotEmpty) {
      rest[0] = rest[0].copyWith(isDefault: true);
    }
    await _write(rest);
  }

  @override
  Future<void> setDefaultCard(String cardId) async {
    final cards = await getCards();
    await _write([
      for (final c in cards) c.copyWith(isDefault: c.id == cardId),
    ]);
  }
}

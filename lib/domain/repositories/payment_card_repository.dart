import '../entities/payment_card_entity.dart';

/// Saved cards of the signed-in user (masked: last 4 digits only).
abstract class PaymentCardRepository {
  Future<List<PaymentCardEntity>> getCards();
  Future<void> saveCard(PaymentCardEntity card);
  Future<void> deleteCard(String cardId);
  Future<void> setDefaultCard(String cardId);
}

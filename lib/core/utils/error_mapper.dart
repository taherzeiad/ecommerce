import 'package:flutter/foundation.dart';

/// Turns any exception from Supabase or the network into a translation key,
/// so screens can show a readable message in the user's language.
String errorKeyFor(Object error) {
  debugPrint('🔴 [Supabase/App Error]: $error');
  final text = error.toString().toLowerCase();

  // Codes raised on purpose by the database functions (place_order).
  const serverCodes = {
    'invalid_coupon': 'error_invalid_coupon',
    'address_not_found': 'no_address_msg',
    'cart_empty': 'cart_empty',
    'invalid_payment_method': 'error_unexpected',
    'not_authenticated': 'error_session_expired',
  };
  for (final entry in serverCodes.entries) {
    if (text.contains(entry.key)) return entry.value;
  }

  if (text.contains('socketexception') ||
      text.contains('failed host lookup') ||
      text.contains('clientexception') ||
      text.contains('failed to fetch') ||
      text.contains('connection') ||
      text.contains('timeout') ||
      text.contains('network')) {
    return 'error_network';
  }
  if (text.contains('jwt') || text.contains('session')) {
    return 'error_session_expired';
  }
  if (text.contains('too many requests') ||
      text.contains('rate limit') ||
      text.contains('429')) {
    return 'error_too_many_requests';
  }
  return 'error_unexpected';
}

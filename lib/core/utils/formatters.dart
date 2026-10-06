/// Display helpers shared by every screen, so prices and dates look the same
/// everywhere. Prices in the database are US dollars.
String formatPrice(num value) {
  final fixed = value.abs().toStringAsFixed(2);
  final dot = fixed.indexOf('.');
  final whole = fixed.substring(0, dot);
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return '${value < 0 ? '-' : ''}\$$buffer${fixed.substring(dot)}';
}

String _two(int n) => n.toString().padLeft(2, '0');

/// 24-hour clock, e.g. `09:05`.
String formatTime(DateTime time) => '${_two(time.hour)}:${_two(time.minute)}';

/// Day/month/year, e.g. `03/01/2026`.
String formatDate(DateTime date) =>
    '${_two(date.day)}/${_two(date.month)}/${date.year}';

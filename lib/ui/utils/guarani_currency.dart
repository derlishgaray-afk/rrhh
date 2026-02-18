import 'package:intl/intl.dart';

class GuaraniCurrency {
  GuaraniCurrency._();

  static final NumberFormat _money = NumberFormat.currency(
    locale: 'es_PY',
    symbol: 'Gs. ',
    decimalDigits: 0,
  );

  static final NumberFormat _integer = NumberFormat.decimalPattern('es_PY');

  static String format(num value) {
    return _money.format(value.round());
  }

  static String formatPlain(num value) {
    return _integer.format(value.round());
  }

  static double? parse(String text) {
    final normalized = text
        .trim()
        .toLowerCase()
        .replaceAll('gs.', '')
        .replaceAll('gs', '')
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('.', '')
        .replaceAll(',', '');

    if (normalized.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      return null;
    }

    return parsed;
  }
}

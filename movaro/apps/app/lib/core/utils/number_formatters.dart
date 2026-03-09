import 'package:intl/intl.dart';

class NumberFormatters {
  const NumberFormatters._();

  static String compactPopulation({
    required int value,
    required String locale,
  }) {
    return NumberFormat.compactCurrency(
      locale: locale,
      decimalDigits: 1,
      symbol: '',
    ).format(value).trim();
  }

  static String fullInteger({required int value, required String locale}) {
    return NumberFormat.decimalPattern(locale).format(value);
  }

  static String decimal({
    required num value,
    required String locale,
    int decimalDigits = 1,
  }) {
    return NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: decimalDigits,
    ).format(value);
  }
}

import 'package:intl/intl.dart';

/// Formats planning estimates without implying accounting-level precision.
class CostEstimateFormatter {
  const CostEstimateFormatter._();

  static int roundedBrl(num amount, {int increment = 50}) {
    if (increment <= 0) return amount.round();
    return (amount / increment).round() * increment;
  }

  static String brl(
    num amount, {
    String locale = 'pt_BR',
    int increment = 50,
    bool compact = false,
  }) {
    final rounded = roundedBrl(amount, increment: increment);
    final formatter = compact
        ? NumberFormat.compactCurrency(
            locale: locale,
            symbol: 'R\$',
            decimalDigits: 1,
          )
        : NumberFormat.currency(
            locale: locale,
            symbol: 'R\$ ',
            decimalDigits: 0,
          );
    return '≈ ${formatter.format(rounded)}';
  }

  static String brlRange(
    num low,
    num high, {
    String locale = 'pt_BR',
    int increment = 100,
    bool compact = false,
  }) {
    final lowLabel = brl(
      low,
      locale: locale,
      increment: increment,
      compact: compact,
    ).replaceFirst('≈ ', '');
    final highLabel = brl(
      high,
      locale: locale,
      increment: increment,
      compact: compact,
    ).replaceFirst('≈ ', '');
    return '≈ $lowLabel–$highLabel';
  }
}

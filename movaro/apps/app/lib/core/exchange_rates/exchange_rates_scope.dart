import 'package:flutter/widgets.dart';
import 'package:movaro_app/core/exchange_rates/exchange_rates_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

/// Provides [ExchangeRatesController] to the widget tree so any widget can
/// read the current exchange rates without needing them passed explicitly.
class ExchangeRatesScope extends InheritedNotifier<ExchangeRatesController> {
  const ExchangeRatesScope({
    required ExchangeRatesController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static ExchangeRatesController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ExchangeRatesScope>()
        ?.notifier;
  }

  /// Returns the latest exchange rates, or null if not yet loaded.
  static CopilotExchangeRates? ratesOf(BuildContext context) {
    return maybeOf(context)?.rates;
  }
}

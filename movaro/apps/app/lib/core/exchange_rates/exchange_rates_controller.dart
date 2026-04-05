import 'package:flutter/foundation.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_service.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

/// Holds app-wide exchange rates loaded once and made available via [ExchangeRatesScope].
/// Widgets that already receive exchange rates explicitly can keep doing so; others
/// will automatically fall back to the rates held here.
class ExchangeRatesController extends ChangeNotifier {
  ExchangeRatesController({required CopilotExchangeRatesService service})
    : _service = service;

  final CopilotExchangeRatesService _service;
  CopilotExchangeRates? _rates;

  CopilotExchangeRates? get rates => _rates;

  Future<void> initialize() async {
    _rates = await _service.fetchLatest();
    notifyListeners();
  }

  Future<void> refresh() async {
    _rates = await _service.fetchLatest();
    notifyListeners();
  }
}

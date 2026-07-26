import 'package:movaro_app/features/migration_questionnaire/application/services/copilot_exchange_rates_store.dart';
import 'package:movaro_app/features/migration_questionnaire/data/datasources/copilot_exchange_rates_remote_data_source.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/copilot_exchange_rates_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

class CopilotExchangeRatesService {
  CopilotExchangeRatesService({
    required CopilotExchangeRatesRemoteDataSource remoteDataSource,
    CopilotExchangeRatesStore? store,
  }) : _remoteDataSource = remoteDataSource,
       _store = store ?? CopilotExchangeRatesStore();

  final CopilotExchangeRatesRemoteDataSource _remoteDataSource;
  final CopilotExchangeRatesStore _store;

  Future<CopilotExchangeRates?> fetchLatest() async {
    try {
      final response = await _remoteDataSource.getCurrentRates();
      final snapshot = CopilotExchangeRatesModel.fromJson(response).toEntity();
      if (!snapshot.isFresh()) {
        throw const FormatException('Exchange-rate snapshot is not current.');
      }
      await _store.write(snapshot);
      return snapshot;
    } catch (_) {
      final cached = await _store.read();
      return cached?.isFresh() == true ? cached : null;
    }
  }
}

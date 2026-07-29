import 'dart:io';

import 'package:movaro_app/core/storage/persistent_json_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/copilot_exchange_rates_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

typedef CopilotExchangeDirectoryProvider = Future<Directory> Function();

class CopilotExchangeRatesStore {
  static const _storageKey = 'movaro_copilot_exchange_rates';

  CopilotExchangeRatesStore({
    CopilotExchangeDirectoryProvider? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final CopilotExchangeDirectoryProvider _directoryProvider;

  Future<CopilotExchangeRates?> read() async {
    try {
      final decoded = await PersistentJsonStore.read(
        key: _storageKey,
        fileProvider: _file,
      );
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return CopilotExchangeRatesModel.fromJson(decoded).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> write(CopilotExchangeRates snapshot) async {
    final model = CopilotExchangeRatesModel.fromEntity(snapshot);
    await PersistentJsonStore.write(
      key: _storageKey,
      data: model.toJson(),
      fileProvider: _file,
    );
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_copilot_exchange_rates.json');
  }
}

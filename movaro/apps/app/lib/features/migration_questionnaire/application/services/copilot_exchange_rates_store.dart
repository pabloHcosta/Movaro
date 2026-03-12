import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/copilot_exchange_rates_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

typedef CopilotExchangeDirectoryProvider = Future<Directory> Function();

class CopilotExchangeRatesStore {
  CopilotExchangeRatesStore({
    CopilotExchangeDirectoryProvider? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final CopilotExchangeDirectoryProvider _directoryProvider;

  Future<CopilotExchangeRates?> read() async {
    try {
      final file = await _file();
      if (!file.existsSync()) {
        return null;
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return CopilotExchangeRatesModel.fromJson(decoded).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> write(CopilotExchangeRates snapshot) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final model = CopilotExchangeRatesModel.fromEntity(snapshot);
    await file.writeAsString(jsonEncode(model.toJson()));
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_copilot_exchange_rates.json');
  }
}

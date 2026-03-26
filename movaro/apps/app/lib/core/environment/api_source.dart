import 'package:movaro_app/core/error/app_configuration_exception.dart';

enum ApiSource { local, railway }

extension ApiSourceX on ApiSource {
  static ApiSource fromName(String value) {
    switch (value) {
      case 'local':
        return ApiSource.local;
      case 'railway':
        return ApiSource.railway;
      default:
        throw AppConfigurationException('Unsupported API_SOURCE value: $value');
    }
  }

  String get defineValue {
    switch (this) {
      case ApiSource.local:
        return 'local';
      case ApiSource.railway:
        return 'railway';
    }
  }

  String get displayName {
    switch (this) {
      case ApiSource.local:
        return 'Local';
      case ApiSource.railway:
        return 'Railway';
    }
  }
}

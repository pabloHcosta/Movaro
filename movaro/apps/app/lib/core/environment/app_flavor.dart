import 'package:movaro_app/core/error/app_configuration_exception.dart';

enum AppFlavor {
  development,
  staging,
  production;

  String get environmentName {
    switch (this) {
      case AppFlavor.development:
        return 'development';
      case AppFlavor.staging:
        return 'staging';
      case AppFlavor.production:
        return 'production';
    }
  }

  String get displayName {
    switch (this) {
      case AppFlavor.development:
        return 'Dev';
      case AppFlavor.staging:
        return 'Staging';
      case AppFlavor.production:
        return 'Production';
    }
  }
}

extension AppFlavorX on AppFlavor {
  static AppFlavor fromName(String value) {
    switch (value) {
      case 'dev':
      case 'development':
        return AppFlavor.development;
      case 'staging':
        return AppFlavor.staging;
      case 'prod':
      case 'production':
        return AppFlavor.production;
      default:
        throw AppConfigurationException('Unsupported APP_FLAVOR value: $value');
    }
  }

  String get defineValue {
    switch (this) {
      case AppFlavor.development:
        return 'dev';
      case AppFlavor.staging:
        return 'staging';
      case AppFlavor.production:
        return 'prod';
    }
  }
}

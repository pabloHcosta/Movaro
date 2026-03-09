import 'package:movaro_app/core/constants/dart_define_keys.dart';
import 'package:movaro_app/core/environment/app_flavor.dart';
import 'package:movaro_app/core/error/app_configuration_exception.dart';

class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.environmentName,
    required this.apiBaseUrl,
    required this.appName,
    this.supabaseUrl,
    this.supabaseAnonKey,
  });

  factory AppEnvironment.fromDartDefines({required AppFlavor defaultFlavor}) {
    final flavorValue = const String.fromEnvironment(
      DartDefineKeys.appFlavor,
      defaultValue: '',
    );
    final environmentValue = const String.fromEnvironment(
      DartDefineKeys.appEnvironment,
      defaultValue: '',
    );
    final apiBaseUrlValue = const String.fromEnvironment(
      DartDefineKeys.apiBaseUrl,
      defaultValue: '',
    );
    final appNameValue = const String.fromEnvironment(
      DartDefineKeys.appName,
      defaultValue: '',
    );
    final supabaseUrlValue = const String.fromEnvironment(
      DartDefineKeys.supabaseUrl,
      defaultValue: '',
    );
    final supabaseAnonKeyValue = const String.fromEnvironment(
      DartDefineKeys.supabaseAnonKey,
      defaultValue: '',
    );

    final flavor = AppFlavorX.fromName(
      flavorValue.isEmpty ? defaultFlavor.defineValue : flavorValue,
    );
    final environmentName = environmentValue.isEmpty
        ? flavor.environmentName
        : environmentValue;
    final apiBaseUrl = apiBaseUrlValue.isEmpty
        ? _defaultApiBaseUrlFor(flavor)
        : apiBaseUrlValue;
    final appName = appNameValue.isEmpty
        ? (flavor == AppFlavor.production
              ? 'Movaro'
              : 'Movaro ${flavor.displayName}')
        : appNameValue;

    if (environmentName.trim().isEmpty) {
      throw const AppConfigurationException(
        'APP_ENV is required to resolve the current environment.',
      );
    }

    if (apiBaseUrl.trim().isEmpty) {
      throw const AppConfigurationException(
        'API_BASE_URL is required to resolve the API base URL.',
      );
    }

    final parsedApiBaseUrl = Uri.tryParse(apiBaseUrl);
    if (parsedApiBaseUrl == null || !parsedApiBaseUrl.hasScheme) {
      throw const AppConfigurationException(
        'API_BASE_URL must be a valid absolute URL.',
      );
    }

    if (flavor != AppFlavor.development && parsedApiBaseUrl.scheme != 'https') {
      throw const AppConfigurationException(
        'API_BASE_URL must use HTTPS outside development.',
      );
    }

    if (appName.trim().isEmpty) {
      throw const AppConfigurationException(
        'APP_NAME is required to resolve the application name.',
      );
    }

    final normalizedSupabaseUrl = supabaseUrlValue.trim();
    final normalizedSupabaseAnonKey = supabaseAnonKeyValue.trim();
    final hasSupabaseUrl = normalizedSupabaseUrl.isNotEmpty;
    final hasSupabaseAnonKey = normalizedSupabaseAnonKey.isNotEmpty;

    if (hasSupabaseUrl != hasSupabaseAnonKey) {
      throw const AppConfigurationException(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be provided together.',
      );
    }

    if (hasSupabaseUrl) {
      final parsedSupabaseUrl = Uri.tryParse(normalizedSupabaseUrl);
      if (parsedSupabaseUrl == null || !parsedSupabaseUrl.hasScheme) {
        throw const AppConfigurationException(
          'SUPABASE_URL must be a valid absolute URL.',
        );
      }

      if (flavor != AppFlavor.development &&
          parsedSupabaseUrl.scheme != 'https') {
        throw const AppConfigurationException(
          'SUPABASE_URL must use HTTPS outside development.',
        );
      }
    }

    return AppEnvironment(
      flavor: flavor,
      environmentName: environmentName,
      apiBaseUrl: apiBaseUrl,
      appName: appName,
      supabaseUrl: hasSupabaseUrl ? normalizedSupabaseUrl : null,
      supabaseAnonKey: hasSupabaseAnonKey ? normalizedSupabaseAnonKey : null,
    );
  }

  final AppFlavor flavor;
  final String environmentName;
  final String apiBaseUrl;
  final String appName;
  final String? supabaseUrl;
  final String? supabaseAnonKey;

  bool get isDevelopment => flavor == AppFlavor.development;
  bool get hasSupabaseClientConfig =>
      supabaseUrl != null && supabaseAnonKey != null;

  static String _defaultApiBaseUrlFor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.development:
        return _resolveDevelopmentApiBaseUrl();
      case AppFlavor.staging:
        return 'https://staging.api.movaro.local';
      case AppFlavor.production:
        return 'https://api.movaro.com';
    }
  }

  static String _resolveDevelopmentApiBaseUrl() {
    final base = Uri.base;
    if (base.hasScheme && (base.scheme == 'http' || base.scheme == 'https')) {
      return '${base.scheme}://${base.host}:3000';
    }

    return 'http://localhost:3000';
  }
}

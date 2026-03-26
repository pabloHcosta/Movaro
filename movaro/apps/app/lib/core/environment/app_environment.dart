import 'package:movaro_app/core/constants/dart_define_keys.dart';
import 'package:movaro_app/core/environment/api_source.dart';
import 'package:movaro_app/core/environment/app_flavor.dart';
import 'package:movaro_app/core/error/app_configuration_exception.dart';

class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.environmentName,
    required this.apiSource,
    required this.apiBaseUrl,
    required this.localApiBaseUrl,
    required this.railwayApiBaseUrl,
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
    final apiSourceValue = const String.fromEnvironment(
      DartDefineKeys.apiSource,
      defaultValue: '',
    );
    final localApiBaseUrlValue = const String.fromEnvironment(
      DartDefineKeys.localApiBaseUrl,
      defaultValue: '',
    );
    final railwayApiBaseUrlValue = const String.fromEnvironment(
      DartDefineKeys.railwayApiBaseUrl,
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
    final apiSource = ApiSourceX.fromName(
      apiSourceValue.isEmpty
          ? _defaultApiSourceFor(flavor).defineValue
          : apiSourceValue,
    );
    final localApiBaseUrl = localApiBaseUrlValue.isEmpty
        ? _defaultLocalApiBaseUrlFor(flavor)
        : localApiBaseUrlValue.trim();
    final railwayApiBaseUrl = railwayApiBaseUrlValue.isEmpty
        ? _defaultRailwayApiBaseUrlFor(flavor)
        : railwayApiBaseUrlValue.trim();
    final apiBaseUrl = apiBaseUrlValue.isEmpty
        ? _resolveApiBaseUrl(
            apiSource: apiSource,
            localApiBaseUrl: localApiBaseUrl,
            railwayApiBaseUrl: railwayApiBaseUrl,
          )
        : apiBaseUrlValue.trim();
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

    _validateApiBaseUrl(
      apiBaseUrl,
      keyName: DartDefineKeys.apiBaseUrl,
      flavor: flavor,
    );

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
      apiSource: apiSource,
      apiBaseUrl: apiBaseUrl,
      localApiBaseUrl: localApiBaseUrl,
      railwayApiBaseUrl: railwayApiBaseUrl,
      appName: appName,
      supabaseUrl: hasSupabaseUrl ? normalizedSupabaseUrl : null,
      supabaseAnonKey: hasSupabaseAnonKey ? normalizedSupabaseAnonKey : null,
    );
  }

  final AppFlavor flavor;
  final String environmentName;
  final ApiSource apiSource;
  final String apiBaseUrl;
  final String localApiBaseUrl;
  final String railwayApiBaseUrl;
  final String appName;
  final String? supabaseUrl;
  final String? supabaseAnonKey;

  bool get isDevelopment => flavor == AppFlavor.development;
  bool get isLocalApiSource => apiSource == ApiSource.local;
  bool get hasSupabaseClientConfig =>
      supabaseUrl != null && supabaseAnonKey != null;

  static ApiSource _defaultApiSourceFor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.development:
        return ApiSource.local;
      case AppFlavor.staging:
        return ApiSource.railway;
      case AppFlavor.production:
        return ApiSource.railway;
    }
  }

  static String _defaultLocalApiBaseUrlFor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.development:
        return _resolveDevelopmentApiBaseUrl();
      case AppFlavor.staging:
      case AppFlavor.production:
        return '';
    }
  }

  static String _defaultRailwayApiBaseUrlFor(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.development:
      case AppFlavor.production:
        return 'https://movaro-production.up.railway.app';
      case AppFlavor.staging:
        return 'https://staging.api.movaro.local';
    }
  }

  static String _resolveApiBaseUrl({
    required ApiSource apiSource,
    required String localApiBaseUrl,
    required String railwayApiBaseUrl,
  }) {
    switch (apiSource) {
      case ApiSource.local:
        return localApiBaseUrl;
      case ApiSource.railway:
        return railwayApiBaseUrl;
    }
  }

  static void _validateApiBaseUrl(
    String value, {
    required String keyName,
    required AppFlavor flavor,
  }) {
    if (value.trim().isEmpty) {
      throw AppConfigurationException(
        '$keyName is required to resolve the API base URL.',
      );
    }

    final parsedApiBaseUrl = Uri.tryParse(value);
    if (parsedApiBaseUrl == null || !parsedApiBaseUrl.hasScheme) {
      throw AppConfigurationException('$keyName must be a valid absolute URL.');
    }

    if (flavor != AppFlavor.development && parsedApiBaseUrl.scheme != 'https') {
      throw AppConfigurationException(
        '$keyName must use HTTPS outside development.',
      );
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

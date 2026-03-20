import 'package:movaro_app/core/constants/dart_define_keys.dart';

class ApiKeys {
  const ApiKeys._();

  static const youtubeApiKey = String.fromEnvironment(
    DartDefineKeys.youtubeApiKey,
    defaultValue: '',
  );

  static const googlePlacesKey = String.fromEnvironment(
    DartDefineKeys.googlePlacesApiKey,
    defaultValue: '',
  );

  static const pexelsApiKey = String.fromEnvironment(
    DartDefineKeys.pexelsApiKey,
    defaultValue: '',
  );

  static bool get hasYoutubeApiKey => youtubeApiKey.trim().isNotEmpty;
  static bool get hasGooglePlacesKey => googlePlacesKey.trim().isNotEmpty;
  static bool get hasPexelsApiKey => pexelsApiKey.trim().isNotEmpty;
}

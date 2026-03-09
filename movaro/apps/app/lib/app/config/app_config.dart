import 'package:movaro_app/core/environment/app_environment.dart';

class AppConfig {
  const AppConfig._();

  static String appTitle(AppEnvironment environment) => environment.appName;
}

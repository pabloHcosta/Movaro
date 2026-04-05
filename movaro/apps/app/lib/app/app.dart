import 'package:flutter/material.dart';
import 'package:movaro_app/app/bootstrap/app_dependencies.dart';
import 'package:movaro_app/app/currency/currency_scope.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/locale_scope.dart';
import 'package:movaro_app/app/router/app_router.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_theme.dart';

class MovaroApp extends StatelessWidget {
  const MovaroApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        dependencies.localeController,
        dependencies.themeController,
        dependencies.currencyController,
      ]),
      builder: (context, _) {
        return CurrencyScope(
          controller: dependencies.currencyController,
          child: LocaleScope(
            controller: dependencies.localeController,
            child: MaterialApp(
              title: dependencies.environment.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: dependencies.themeController.themeMode,
              locale: dependencies.localeController.locale,
              supportedLocales: AppLocalization.supportedLocales,
              localizationsDelegates: AppLocalization.localizationsDelegates,
              localeListResolutionCallback: (locales, _) =>
                  AppLocalization.resolveLocales(locales),
              onGenerateTitle: (context) => dependencies.environment.appName,
              onGenerateRoute: AppRouter(
                dependencies: dependencies,
              ).onGenerateRoute,
              navigatorObservers: [appRouteObserver],
              initialRoute: AppRoutes.splash,
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:movaro_app/app/currency/currency_controller.dart';

class CurrencyScope extends InheritedNotifier<CurrencyController> {
  const CurrencyScope({
    required CurrencyController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static CurrencyController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CurrencyScope>();
    assert(scope != null, 'CurrencyScope is not available in this context.');
    return scope!.notifier!;
  }

  static String preferredCodeOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<CurrencyScope>()
            ?.notifier
            ?.resolvedCurrencyCode ??
        CurrencyController.defaultCurrencyCode;
  }
}

extension CurrencyScopeX on BuildContext {
  CurrencyController get currencyController => CurrencyScope.of(this);
  String get preferredCurrencyCode => CurrencyScope.preferredCodeOf(this);
}

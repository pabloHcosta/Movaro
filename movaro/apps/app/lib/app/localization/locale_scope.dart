import 'package:flutter/widgets.dart';
import 'package:movaro_app/app/localization/locale_controller.dart';

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    required LocaleController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope is not available in this context.');
    return scope!.notifier!;
  }
}

extension LocaleScopeX on BuildContext {
  LocaleController get localeController => LocaleScope.of(this);
}

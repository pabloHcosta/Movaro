import 'package:flutter/widgets.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/core/errors/error_mapper.dart';
import 'package:movaro_app/core/errors/ui_error_state.dart';

class ErrorHandler {
  const ErrorHandler._();

  static UiErrorState resolve(BuildContext context, Object error) {
    final mappedError = ErrorMapper.map(context.l10n, error);

    return UiErrorState(
      title: mappedError.title,
      description: mappedError.description,
      illustrationAsset: mappedError.illustrationAsset,
      isRetryable: mappedError.isRetryable,
    );
  }
}

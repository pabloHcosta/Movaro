import 'package:movaro_app/app/localization/generated/app_localizations.dart';
import 'package:movaro_app/core/errors/app_error.dart';
import 'package:movaro_app/core/network/network_exception.dart';

class ErrorMapper {
  const ErrorMapper._();

  static AppError map(AppLocalizations l10n, Object error) {
    if (error is NetworkException) {
      return NetworkError(
        title: l10n.errorNetworkTitle,
        description: l10n.errorNetworkMovaroDescription,
        isRetryable: error.isRetryable,
      );
    }

    if (error is ApiException) {
      final userMessage = error.error.userMessage.trim();
      final fallbackMessage = userMessage.isEmpty
          ? l10n.errorApiGenericDescription
          : userMessage;

      switch (error.error.code) {
        case 'CITY_NOT_FOUND':
        case 'RESOURCE_NOT_FOUND':
          return NotFoundError(
            title: l10n.errorNotFoundTitle,
            description: userMessage.isEmpty
                ? l10n.errorNotFoundDescription
                : userMessage,
          );
        case 'UNAUTHORIZED':
          return UnauthorizedError(
            title: l10n.errorUnauthorizedTitle,
            description: userMessage.isEmpty
                ? l10n.errorUnauthorizedDescription
                : userMessage,
          );
        case 'NETWORK_ERROR':
          return NetworkError(
            title: l10n.errorNetworkTitle,
            description: userMessage.isEmpty
                ? l10n.errorNetworkDescription
                : userMessage,
          );
        case 'VALIDATION_ERROR':
          return UnknownError(
            title: l10n.errorValidationTitle,
            description: fallbackMessage,
            illustrationAsset: 'assets/illustrations/error.svg',
            isRetryable: false,
          );
        case 'INTERNAL_ERROR':
          return ServerError(
            title: l10n.errorServerTitle,
            description: userMessage.isEmpty
                ? l10n.errorServerDescription
                : userMessage,
          );
        default:
          return error.error.status >= 500
              ? ServerError(
                  title: l10n.errorServerTitle,
                  description: userMessage.isEmpty
                      ? l10n.errorServerDescription
                      : userMessage,
                )
              : UnknownError(
                  title: l10n.errorUnknownTitle,
                  description: fallbackMessage,
                  isRetryable: false,
                );
      }
    }

    return UnknownError(
      title: l10n.errorUnknownTitle,
      description: l10n.errorUnknownDescription,
    );
  }
}

abstract class AppError {
  const AppError({
    required this.title,
    required this.description,
    required this.illustrationAsset,
    this.isRetryable = true,
  });

  final String title;
  final String description;
  final String illustrationAsset;
  final bool isRetryable;
}

class NetworkError extends AppError {
  const NetworkError({
    required super.title,
    required super.description,
    super.illustrationAsset = 'assets/illustrations/offline.svg',
    super.isRetryable = true,
  });
}

class ServerError extends AppError {
  const ServerError({
    required super.title,
    required super.description,
    super.illustrationAsset = 'assets/illustrations/error.svg',
    super.isRetryable = true,
  });
}

class NotFoundError extends AppError {
  const NotFoundError({
    required super.title,
    required super.description,
    super.illustrationAsset = 'assets/illustrations/empty.svg',
    super.isRetryable = false,
  });
}

class UnauthorizedError extends AppError {
  const UnauthorizedError({
    required super.title,
    required super.description,
    super.illustrationAsset = 'assets/illustrations/error.svg',
    super.isRetryable = false,
  });
}

class UnknownError extends AppError {
  const UnknownError({
    required super.title,
    required super.description,
    super.illustrationAsset = 'assets/illustrations/error.svg',
    super.isRetryable = true,
  });
}

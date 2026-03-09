import 'package:movaro_app/core/network/api_error_model.dart';

class ApiException implements Exception {
  const ApiException(this.error);

  final ApiErrorModel error;

  @override
  String toString() => 'ApiException(${error.code}): ${error.message}';
}

class NetworkException implements Exception {
  const NetworkException(this.message, {this.isRetryable = true});

  final String message;
  final bool isRetryable;

  @override
  String toString() => 'NetworkException: $message';
}

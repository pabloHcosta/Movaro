import 'dart:async';
import 'dart:convert';

import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/network/api_error_model.dart';
import 'package:movaro_app/core/network/api_response_model.dart';
import 'package:movaro_app/core/network/network_exception.dart';
import 'package:http/http.dart' as http;

class NetworkClient {
  NetworkClient({required AppEnvironment environment, http.Client? httpClient})
    : _environment = environment,
      _httpClient = httpClient ?? http.Client(),
      _timeout = environment.isLocalApiSource
          ? const Duration(seconds: 15)
          : const Duration(seconds: 8),
      _retrySchedule = environment.isLocalApiSource
          ? const [Duration(milliseconds: 500), Duration(milliseconds: 1200)]
          : const [Duration(milliseconds: 350), Duration(milliseconds: 700)];

  final AppEnvironment _environment;
  final http.Client _httpClient;
  final Duration _timeout;
  final List<Duration> _retrySchedule;

  Future<Map<String, dynamic>> getJsonMap(String path) async {
    final data = await _get(path);

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const NetworkException(
      'invalid_api_response_format',
      isRetryable: false,
    );
  }

  Future<Map<String, dynamic>> getJsonMapWithHeaders(
    String path, {
    Map<String, String> headers = const {},
  }) async {
    final data = await _get(path, headers: headers);

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const NetworkException(
      'invalid_api_response_format',
      isRetryable: false,
    );
  }

  Future<List<dynamic>> getJsonList(String path) async {
    final data = await _get(path);

    if (data is List<dynamic>) {
      return data;
    }

    throw const NetworkException(
      'invalid_api_response_format',
      isRetryable: false,
    );
  }

  Future<Map<String, dynamic>> postJsonMap(
    String path,
    Map<String, dynamic> body,
  ) async {
    final data = await _post(path, body);

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const NetworkException(
      'invalid_api_response_format',
      isRetryable: false,
    );
  }

  Future<Object?> _post(String path, Map<String, dynamic> body) {
    return _executeWithFailover(
      (baseUri) => _requestPost(path, body, baseUri: baseUri),
    );
  }

  Future<Object?> _requestPost(
    String path,
    Map<String, dynamic> body, {
    required Uri baseUri,
  }) async {
    if (!path.startsWith('/')) {
      throw const NetworkException('invalid_api_path', isRetryable: false);
    }

    final uri = baseUri.resolve(path);
    final requestHeaders = <String, String>{
      'accept': 'application/json',
      'content-type': 'application/json',
      'x-movaro-client': 'app',
      'x-movaro-environment': _environment.environmentName,
    };

    try {
      final response = await _httpClient
          .post(uri, headers: requestHeaders, body: jsonEncode(body))
          .timeout(_timeout);
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const NetworkException(
          'invalid_api_response_envelope',
          isRetryable: false,
        );
      }

      final envelope = ApiResponseModel<Object?>.fromJson(decoded);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          envelope.success) {
        return envelope.data;
      }

      throw ApiException(
        envelope.error ??
            ApiErrorModel(
              code: 'INTERNAL_ERROR',
              message: 'Unexpected API failure.',
              userMessage: '',
              status: response.statusCode,
            ),
      );
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw const NetworkException('network_unreachable');
    } on TimeoutException {
      throw const NetworkException('network_timeout');
    } on FormatException {
      throw const NetworkException(
        'invalid_api_response_body',
        isRetryable: false,
      );
    }
  }

  Future<Object?> _get(String path, {Map<String, String> headers = const {}}) {
    return _executeWithFailover(
      (baseUri) => _request(path, headers: headers, baseUri: baseUri),
    );
  }

  Future<Object?> _request(
    String path, {
    Map<String, String> headers = const {},
    required Uri baseUri,
  }) async {
    if (!path.startsWith('/')) {
      throw const NetworkException('invalid_api_path', isRetryable: false);
    }

    final uri = baseUri.resolve(path);
    final requestHeaders = <String, String>{
      'accept': 'application/json',
      'x-movaro-client': 'app',
      'x-movaro-environment': _environment.environmentName,
      ...headers,
    };

    try {
      final response = await _httpClient
          .get(uri, headers: requestHeaders)
          .timeout(_timeout);
      final body = response.body;
      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        throw const NetworkException(
          'invalid_api_response_envelope',
          isRetryable: false,
        );
      }

      final envelope = ApiResponseModel<Object?>.fromJson(decoded);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          envelope.success) {
        return envelope.data;
      }

      throw ApiException(
        envelope.error ??
            ApiErrorModel(
              code: 'INTERNAL_ERROR',
              message: 'Unexpected API failure.',
              userMessage: '',
              status: response.statusCode,
            ),
      );
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw const NetworkException('network_unreachable');
    } on TimeoutException {
      throw const NetworkException('network_timeout');
    } on FormatException {
      throw const NetworkException(
        'invalid_api_response_body',
        isRetryable: false,
      );
    }
  }

  Future<Object?> _executeWithFailover(
    Future<Object?> Function(Uri baseUri) operation,
  ) async {
    final endpoints = <Uri>[
      Uri.parse(_environment.apiBaseUrl),
      if (_environment.isLocalApiSource &&
          _environment.railwayApiBaseUrl.trim().isNotEmpty &&
          _environment.railwayApiBaseUrl.trim() !=
              _environment.apiBaseUrl.trim())
        Uri.parse(_environment.railwayApiBaseUrl),
    ];

    for (
      var endpointIndex = 0;
      endpointIndex < endpoints.length;
      endpointIndex++
    ) {
      var attempt = 0;
      while (true) {
        try {
          return await operation(endpoints[endpointIndex]);
        } on NetworkException catch (error) {
          final hasFallback = endpointIndex < endpoints.length - 1;
          if (hasFallback) {
            break;
          }

          final canRetryEndpoint =
              error.isRetryable && attempt < _retrySchedule.length;
          if (canRetryEndpoint) {
            await Future<void>.delayed(_retrySchedule[attempt]);
            attempt += 1;
            continue;
          }

          rethrow;
        }
      }
    }

    throw const NetworkException('network_unreachable');
  }
}

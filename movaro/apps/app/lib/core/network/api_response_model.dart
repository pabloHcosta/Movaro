import 'package:movaro_app/core/network/api_error_model.dart';

class ApiResponseModel<T> {
  const ApiResponseModel({required this.success, this.data, this.error});

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json, {
    T Function(Object? data)? fromData,
  }) {
    return ApiResponseModel<T>(
      success: json['success'] as bool? ?? false,
      data: fromData == null ? json['data'] as T? : fromData(json['data']),
      error: json['error'] is Map<String, dynamic>
          ? ApiErrorModel.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool success;
  final T? data;
  final ApiErrorModel? error;
}

class ApiErrorModel {
  const ApiErrorModel({
    required this.code,
    required this.message,
    required this.userMessage,
    required this.status,
    this.traceId,
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      code: json['code'] as String? ?? 'INTERNAL_ERROR',
      message: json['message'] as String? ?? 'Unexpected API error.',
      userMessage: json['userMessage'] as String? ?? '',
      status: json['status'] as int? ?? 500,
      traceId: json['traceId'] as String?,
    );
  }

  final String code;
  final String message;
  final String userMessage;
  final int status;
  final String? traceId;
}

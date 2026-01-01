class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final dynamic error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success({String? message, T? data, int? statusCode}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({String? message, dynamic error, int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      error: error,
      statusCode: statusCode,
    );
  }
}

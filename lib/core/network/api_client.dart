import 'package:dio/dio.dart';
import 'dio_client.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

class ApiClient {
  final Dio _dio = DioClient.instance.dio;

  // ══════════════════════════════════════════════════════════════════════════
  // GET REQUEST
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // POST REQUEST
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PUT REQUEST
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PATCH REQUEST
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE REQUEST
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPLOAD FILE (Multipart)
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required dynamic data, // ✅ Change to dynamic
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      // ✅ Accept FormData directly or convert Map
      final formData = data is FormData ? data : FormData.fromMap(data);

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DOWNLOAD FILE
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<void>> downloadFile(
    String endpoint,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        endpoint,
        savePath,
        queryParameters: queryParameters,
        options: options,
        onReceiveProgress: onReceiveProgress,
      );

      return ApiResponse.success(message: 'File downloaded successfully');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HANDLE RESPONSE
  // ══════════════════════════════════════════════════════════════════════════
  ApiResponse<T> _handleResponse<T>(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return ApiResponse.success(
        data: response.data is T ? response.data : null,
        message: response.data['message'],
        statusCode: response.statusCode,
      );
    } else {
      return ApiResponse.error(
        message: response.data['message'] ?? 'Unknown error',
        error: response.data,
        statusCode: response.statusCode,
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HANDLE DIO EXCEPTIONS
  // ══════════════════════════════════════════════════════════════════════════
  ApiException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(message: 'Request timeout. Please try again.');

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'No internet connection. Please check your network.',
        );

      case DioExceptionType.badResponse:
        return _handleStatusCode(error);

      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled');

      default:
        return ApiException(message: error.message ?? 'Something went wrong');
    }
  }

  ApiException _handleStatusCode(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.data?['message'];

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: message ?? 'Invalid request',
          data: error.response?.data,
        );
      case 401:
        return UnauthorizedException(message: message ?? 'Unauthorized access');
      case 404:
        return NotFoundException(message: message ?? 'Resource not found');
      case 500:
      case 502:
      case 503:
        return ServerException(
          message: message ?? 'Server error. Please try again later.',
        );
      default:
        return ApiException(
          message: message ?? 'Something went wrong',
          statusCode: statusCode,
          data: error.response?.data,
        );
    }
  }
}

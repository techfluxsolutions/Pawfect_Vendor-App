// import 'package:dio/dio.dart';
// import '../api/api_urls.dart';
// import 'api_interceptor.dart';
// import 'api_logger.dart';

import 'package:dio/dio.dart';
import 'package:pawfect_vendor_app/core/storage/storage_service.dart';

import '../../libs.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;
  factory DioClient() => _instance;

  late final Dio _dio;
  Dio get dio => _dio;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api-dev.pawfectcaring.com/api/vendor',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(ApiInterceptor());
    _dio.interceptors.add(ApiLogger());

    // Set token if available
    _setTokenFromStorage();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SET TOKEN FROM STORAGE
  // ══════════════════════════════════════════════════════════════════════════
  void _setTokenFromStorage() {
    final token = StorageService.instance.getToken();
    if (token != null && token.isNotEmpty) {
      setToken(token);
      print('🔑 Token loaded from storage');
    }
  }

  // Update base URL if needed
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Set authorization token
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('🔑 Token set in headers');
  }

  // Clear token
  void clearToken() {
    _dio.options.headers.remove('Authorization');
    print('🔓 Token removed from headers');
  }
}

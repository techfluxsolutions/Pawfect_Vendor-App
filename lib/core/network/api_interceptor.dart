import 'package:dio/dio.dart';
import 'package:pawfect_vendor_app/core/network/dio_client.dart';

import '../storage/storage_service.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Automatically add token to every request if available
    final token = StorageService.instance.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle global response logic here
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - Auto logout
    if (err.response?.statusCode == 401) {
      print('⚠️ Unauthorized - Clearing auth data');
      StorageService.instance.clearAuthData();
      DioClient.instance.clearToken();
      // Navigate to login screen
      // Get.offAllNamed(AppRoutes.login);
    }

    super.onError(err, handler);
  }
}

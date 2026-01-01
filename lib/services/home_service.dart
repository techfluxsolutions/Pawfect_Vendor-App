import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:pawfect_vendor_app/models/home_screen_model.dart';
import '../libs.dart';

class HomeService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://api-dev.pawfectcaring.com/api/vendor';

  HomeService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);

    // Add token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          log('❌ API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getToken() async {
    // TODO: Get token from secure storage
    // For now, return dummy token
    return 'your_auth_token_here';
  }

  // ========== Get Dashboard Stats ==========

  Future<ApiResponse<DashboardStatsModel>> getDashboardStats() async {
    try {
      log('📊 Fetching dashboard stats...');

      final response = await _dio.get('/dashboard/stats');

      if (response.statusCode == 200) {
        log('✅ Dashboard stats fetched successfully');
        final stats = DashboardStatsModel.fromJson(response.data['data']);
        return ApiResponse.success(
          data: stats,
          message: 'Stats fetched successfully',
        );
      } else {
        log('⚠️ Dashboard stats fetch failed: ${response.statusCode}');
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to fetch stats',
        );
      }
    } on DioException catch (e) {
      log('❌ Dashboard stats error: ${e.message}');
      return ApiResponse.error(message: _handleDioError(e));
    } catch (e) {
      log('❌ Unexpected error: $e');
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  // ========== Get Store Info ==========

  Future<ApiResponse<StoreInfoModel>> getStoreInfo() async {
    try {
      log('🏪 Fetching store info...');

      final response = await _dio.get('/store/info');

      if (response.statusCode == 200) {
        log('✅ Store info fetched successfully');
        final store = StoreInfoModel.fromJson(response.data['data']);
        return ApiResponse.success(
          data: store,
          message: 'Store info fetched successfully',
        );
      } else {
        log('⚠️ Store info fetch failed: ${response.statusCode}');
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to fetch store info',
        );
      }
    } on DioException catch (e) {
      log('❌ Store info error: ${e.message}');
      return ApiResponse.error(message: _handleDioError(e));
    } catch (e) {
      log('❌ Unexpected error: $e');
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  // ========== Get Alerts ==========

  Future<ApiResponse<List<AlertModel>>> getAlerts() async {
    try {
      log('🔔 Fetching alerts...');

      final response = await _dio.get('/alerts');

      if (response.statusCode == 200) {
        log('✅ Alerts fetched successfully');
        final List<dynamic> alertsJson = response.data['data']['alerts'] ?? [];
        final alerts =
            alertsJson.map((json) => AlertModel.fromJson(json)).toList();
        return ApiResponse.success(
          data: alerts,
          message: 'Alerts fetched successfully',
        );
      } else {
        log('⚠️ Alerts fetch failed: ${response.statusCode}');
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to fetch alerts',
        );
      }
    } on DioException catch (e) {
      log('❌ Alerts error: ${e.message}');
      return ApiResponse.error(message: _handleDioError(e));
    } catch (e) {
      log('❌ Unexpected error: $e');
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  // ========== Get Recent Orders ==========

  Future<ApiResponse<List<OrderModel>>> getRecentOrders({int limit = 5}) async {
    try {
      log('📦 Fetching recent orders...');

      final response = await _dio.get(
        '/orders/recent',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        log('✅ Recent orders fetched successfully');
        final List<dynamic> ordersJson = response.data['data']['orders'] ?? [];
        final orders =
            ordersJson.map((json) => OrderModel.fromJson(json)).toList();
        return ApiResponse.success(
          data: orders,
          message: 'Orders fetched successfully',
        );
      } else {
        log('⚠️ Recent orders fetch failed: ${response.statusCode}');
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to fetch orders',
        );
      }
    } on DioException catch (e) {
      log('❌ Recent orders error: ${e.message}');
      return ApiResponse.error(message: _handleDioError(e));
    } catch (e) {
      log('❌ Unexpected error: $e');
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  // ========== Get Top Selling Products ==========

  Future<ApiResponse<List<TopSellingProductModel>>> getTopSellingProducts({
    int limit = 3,
    String period = 'month', // month, week, day
  }) async {
    try {
      log('🏆 Fetching top selling products...');

      final response = await _dio.get(
        '/products/top-selling',
        queryParameters: {'limit': limit, 'period': period},
      );

      if (response.statusCode == 200) {
        log('✅ Top selling products fetched successfully');
        final List<dynamic> productsJson =
            response.data['data']['products'] ?? [];
        final products =
            productsJson
                .map((json) => TopSellingProductModel.fromJson(json))
                .toList();
        return ApiResponse.success(
          data: products,
          message: 'Products fetched successfully',
        );
      } else {
        log('⚠️ Top selling products fetch failed: ${response.statusCode}');
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to fetch products',
        );
      }
    } on DioException catch (e) {
      log('❌ Top selling products error: ${e.message}');
      return ApiResponse.error(message: _handleDioError(e));
    } catch (e) {
      log('❌ Unexpected error: $e');
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  // ========== Update Store Status ==========

  Future<ApiResponse<void>> updateStoreStatus(bool isActive) async {
    try {
      log('🔄 Updating store status to ${isActive ? "Active" : "Inactive"}...');

      final response = await _dio.put(
        '/store/status',
        data: {'isActive': isActive},
      );

      if (response.statusCode == 200) {
        log('✅ Store status updated successfully');
        return ApiResponse.success(
          message: response.data['message'] ?? 'Status updated successfully',
        );
      } else {
        log('⚠️ Store status update failed: ${response.statusCode}');
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to update status',
        );
      }
    } on DioException catch (e) {
      log('❌ Store status update error: ${e.message}');
      return ApiResponse.error(message: _handleDioError(e));
    } catch (e) {
      log('❌ Unexpected error: $e');
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  // ========== Error Handler ==========

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return error.response?.data['message'] ?? 'Server error occurred';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'An unexpected error occurred';
    }
  }
}

// ========== API Response Model ==========

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success({T? data, String? message, int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
    );
  }

  factory ApiResponse.error({String? message, int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message ?? 'An error occurred',
      statusCode: statusCode,
    );
  }
}

import 'dart:developer';
import '../libs.dart';

class HomeScreenService {
  final ApiClient _apiClient = ApiClient();

  // ══════════════════════════════════════════════════════════════════════════
  // GET DASHBOARD STATS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<DashboardStatsModel>> getDashboardStats() async {
    try {
      log('📊 Fetching dashboard stats...');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiUrls.dashboardStats,
      );

      if (response.success && response.data != null) {
        log('✅ Dashboard stats fetched successfully');
        final stats = DashboardStatsModel.fromJson(response.data!);
        return ApiResponse.success(
          data: stats,
          message: response.message ?? 'Stats fetched successfully',
        );
      } else {
        log('⚠️ Dashboard stats fetch failed: ${response.message}');
        return ApiResponse.error(
          message: response.message ?? 'Failed to fetch dashboard stats',
        );
      }
    } catch (e) {
      log('❌ Dashboard stats error: $e');
      return ApiResponse.error(
        message: 'Failed to fetch dashboard stats: ${e.toString()}',
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GET RECENT ORDERS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<List<RecentOrderModel>>> getRecentOrders({
    int limit = 5,
  }) async {
    try {
      log('📦 Fetching recent orders...');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiUrls.recentOrders,
        queryParameters: {'limit': limit},
      );

      if (response.success && response.data != null) {
        log('✅ Recent orders fetched successfully');

        final List<dynamic> ordersJson = response.data!['recentOrders'] ?? [];
        final orders =
            ordersJson.map((json) => RecentOrderModel.fromJson(json)).toList();

        log('📦 Parsed ${orders.length} recent orders');

        return ApiResponse.success(
          data: orders,
          message: response.message ?? 'Recent orders fetched successfully',
        );
      } else {
        log('⚠️ Recent orders fetch failed: ${response.message}');
        return ApiResponse.error(
          message: response.message ?? 'Failed to fetch recent orders',
        );
      }
    } catch (e) {
      log('❌ Recent orders error: $e');
      return ApiResponse.error(
        message: 'Failed to fetch recent orders: ${e.toString()}',
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GET TOP SELLING PRODUCTS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<List<TopSellingProductModel>>> getTopSellingProducts({
    int limit = 3,
  }) async {
    try {
      log('🏆 Fetching top selling products...');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiUrls.topSelling,
        queryParameters: {'limit': limit},
      );

      if (response.success && response.data != null) {
        log('✅ Top selling products fetched successfully');

        final List<dynamic> productsJson = response.data!['topSelling'] ?? [];
        final products =
            productsJson
                .map((json) => TopSellingProductModel.fromJson(json))
                .toList();

        log('🏆 Parsed ${products.length} top selling products');

        return ApiResponse.success(
          data: products,
          message:
              response.message ?? 'Top selling products fetched successfully',
        );
      } else {
        log('⚠️ Top selling products fetch failed: ${response.message}');
        return ApiResponse.error(
          message: response.message ?? 'Failed to fetch top selling products',
        );
      }
    } catch (e) {
      log('❌ Top selling products error: $e');
      return ApiResponse.error(
        message: 'Failed to fetch top selling products: ${e.toString()}',
      );
    }
  }
}

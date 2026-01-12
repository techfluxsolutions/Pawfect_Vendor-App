import 'dart:developer';
import '../libs.dart';

class AnalyticsService {
  final ApiClient _apiClient = ApiClient();

  // ══════════════════════════════════════════════════════════════════════════
  // GET ANALYTICS DATA
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<AnalyticsModel>> getAnalytics({
    String period = 'weekly',
  }) async {
    try {
      log('📊 Fetching analytics data for period: $period');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiUrls.analytics,
        queryParameters: {'period': period},
      );

      if (response.success && response.data != null) {
        log('✅ Analytics data fetched successfully');
        final analytics = AnalyticsModel.fromJson(response.data!);
        return ApiResponse.success(
          data: analytics,
          message: response.message ?? 'Analytics data fetched successfully',
        );
      } else {
        log('⚠️ Analytics data fetch failed: ${response.message}');
        return ApiResponse.error(
          message: response.message ?? 'Failed to fetch analytics data',
        );
      }
    } catch (e) {
      log('❌ Analytics data error: $e');
      return ApiResponse.error(
        message: 'Failed to fetch analytics data: ${e.toString()}',
      );
    }
  }
}

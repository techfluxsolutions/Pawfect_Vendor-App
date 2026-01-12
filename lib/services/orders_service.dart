import 'dart:developer';
import '../libs.dart';

class OrdersService {
  final ApiClient _apiClient = ApiClient();

  // ══════════════════════════════════════════════════════════════════════════
  // GET ORDERS WITH SEARCH AND FILTERS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<OrdersResponseModel>> getOrders({
    String? search,
    String? status,
    String? paymentStatus,
    String? dateFrom,
    String? dateTo,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? limit,
  }) async {
    try {
      log('📦 Fetching orders with filters...');

      // Build query parameters
      Map<String, dynamic> queryParams = {};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }
      if (paymentStatus != null &&
          paymentStatus.isNotEmpty &&
          paymentStatus != 'all') {
        queryParams['paymentStatus'] = paymentStatus;
      }
      if (dateFrom != null && dateFrom.isNotEmpty) {
        queryParams['dateFrom'] = dateFrom;
      }
      if (dateTo != null && dateTo.isNotEmpty) {
        queryParams['dateTo'] = dateTo;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sortOrder'] = sortOrder;
      }
      if (page != null) {
        queryParams['page'] = page.toString();
      }
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      log('📦 Query params: $queryParams');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiUrls.orders,
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        log('✅ Orders fetched successfully');

        final ordersResponse = OrdersResponseModel.fromJson(response.data!);

        log('📦 Parsed ${ordersResponse.orders.length} orders');
        log(
          '📊 Summary: ${ordersResponse.summary.totalOrders} total, ${ordersResponse.summary.formattedRevenue} revenue',
        );

        return ApiResponse.success(
          data: ordersResponse,
          message: response.message ?? 'Orders fetched successfully',
        );
      } else {
        log('⚠️ Orders fetch failed: ${response.message}');
        return ApiResponse.error(
          message: response.message ?? 'Failed to fetch orders',
        );
      }
    } catch (e) {
      log('❌ Orders error: $e');
      return ApiResponse.error(
        message: 'Failed to fetch orders: ${e.toString()}',
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE ORDER STATUS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<void>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      log('🔄 Updating order status: $orderId -> $status');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '${ApiUrls.orders}/$orderId/status',
        data: {'status': status},
      );

      if (response.success) {
        log('✅ Order status updated successfully');
        return ApiResponse.success(
          message: response.message ?? 'Order status updated successfully',
        );
      } else {
        log('⚠️ Order status update failed: ${response.message}');
        return ApiResponse.error(
          message: response.message ?? 'Failed to update order status',
        );
      }
    } catch (e) {
      log('❌ Order status update error: $e');
      return ApiResponse.error(
        message: 'Failed to update order status: ${e.toString()}',
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GET ORDER DETAILS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<OrdersApiModel>> getOrderDetails(String orderId) async {
    try {
      log('📋 Fetching order details: $orderId');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiUrls.orders}/$orderId',
      );

      if (response.success && response.data != null) {
        log('✅ Order details fetched successfully');

        final order = OrdersApiModel.fromJson(response.data!);

        return ApiResponse.success(
          data: order,
          message: response.message ?? 'Order details fetched successfully',
        );
      } else {
        log('⚠️ Order details fetch failed: ${response.message}');
        return ApiResponse.error(
          message: response.message ?? 'Failed to fetch order details',
        );
      }
    } catch (e) {
      log('❌ Order details error: $e');
      return ApiResponse.error(
        message: 'Failed to fetch order details: ${e.toString()}',
      );
    }
  }
}

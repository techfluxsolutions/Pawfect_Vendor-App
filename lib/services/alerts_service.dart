import 'dart:developer';
import '../libs.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/home_screen_model.dart';
import '../core/api/api_urls.dart';
import '../routes/app_routes.dart';

class AlertsService {
  final ApiClient _apiClient = ApiClient();

  // ══════════════════════════════════════════════════════════════════════════
  // GET ALERTS
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<AlertsResponse>> getAlerts() async {
    try {
      log('🔔 Fetching alerts...');

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiUrls.alerts,
      );

      if (response.success && response.data != null) {
        log('✅ Alerts fetched successfully');
        final alertsResponse = AlertsResponse.fromJson(response.data!);
        return ApiResponse.success(
          data: alertsResponse,
          message: response.message ?? 'Alerts fetched successfully',
        );
      } else {
        log('⚠️ Alerts fetch failed: ${response.message}');
        return ApiResponse.error(
          message: response.message ?? 'Failed to fetch alerts',
        );
      }
    } catch (e) {
      log('❌ Alerts error: $e');
      return ApiResponse.error(
        message: 'Failed to fetch alerts: ${e.toString()}',
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RESOLVE ALERT
  // ══════════════════════════════════════════════════════════════════════════
  Future<ApiResponse<void>> resolveAlert(String alertId) async {
    try {
      log('🔄 Resolving alert: $alertId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiUrls.alerts}/$alertId/resolve',
      );

      if (response.success) {
        log('✅ Alert resolved successfully');
        return ApiResponse.success(
          message: response.message ?? 'Alert resolved successfully',
        );
      } else {
        log('⚠️ Alert resolution failed: ${response.message}');
        return ApiResponse.error(
          message: response.message ?? 'Failed to resolve alert',
        );
      }
    } catch (e) {
      log('❌ Alert resolution error: $e');
      return ApiResponse.error(
        message: 'Failed to resolve alert: ${e.toString()}',
      );
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
// API RESPONSE MODELS
// ══════════════════════════════════════════════════════════════════════════

class AlertsResponse {
  final AlertsSummary summary;
  final List<ApiAlertModel> alerts;

  AlertsResponse({required this.summary, required this.alerts});

  factory AlertsResponse.fromJson(Map<String, dynamic> json) {
    return AlertsResponse(
      summary: AlertsSummary.fromJson(json['summary'] ?? {}),
      alerts:
          (json['alerts'] as List<dynamic>? ?? [])
              .map((alertJson) => ApiAlertModel.fromJson(alertJson))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'alerts': alerts.map((alert) => alert.toJson()).toList(),
    };
  }
}

class AlertsSummary {
  final int total;
  final int critical;

  AlertsSummary({required this.total, required this.critical});

  factory AlertsSummary.fromJson(Map<String, dynamic> json) {
    return AlertsSummary(
      total: json['total']?.toInt() ?? 0,
      critical: json['critical']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'critical': critical};
  }
}

class ApiAlertModel {
  final String type;
  final String message;
  final String status;
  final int count;
  final DateTime date;
  final AlertData? data;

  ApiAlertModel({
    required this.type,
    required this.message,
    required this.status,
    required this.count,
    required this.date,
    this.data,
  });

  factory ApiAlertModel.fromJson(Map<String, dynamic> json) {
    return ApiAlertModel(
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      count: json['count']?.toInt() ?? 0,
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      data: json['data'] != null ? AlertData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'status': status,
      'count': count,
      'date': date.toIso8601String(),
      'data': data?.toJson(),
    };
  }

  // Convert API alert to AlertModel for UI compatibility
  AlertModel toAlertModel() {
    return AlertModel(
      id: data?.productId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _mapApiTypeToAlertType(type),
      title: _generateTitle(type),
      message: message,
      count: count,
      actionRoute: _getActionRoute(type),
      date: date,
    );
  }

  AlertType _mapApiTypeToAlertType(String apiType) {
    switch (apiType.toLowerCase()) {
      case 'low stock alert':
        return AlertType.lowStock;
      case 'new order':
        return AlertType.newOrder;
      default:
        return AlertType.general;
    }
  }

  String _generateTitle(String apiType) {
    switch (apiType.toLowerCase()) {
      case 'low stock alert':
        return 'Low Stock Alert';
      case 'new order':
        return 'New Order Received';
      default:
        return 'Alert';
    }
  }

  String? _getActionRoute(String apiType) {
    switch (apiType.toLowerCase()) {
      case 'low stock alert':
        return AppRoutes.inventory;
      case 'new order':
        return AppRoutes.orders;
      default:
        return null;
    }
  }
}

class AlertData {
  final String? productId;

  AlertData({this.productId});

  factory AlertData.fromJson(Map<String, dynamic> json) {
    return AlertData(productId: json['productId']?.toString());
  }

  Map<String, dynamic> toJson() {
    return {'productId': productId};
  }
}

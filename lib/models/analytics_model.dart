class AnalyticsModel {
  final String period;
  final AnalyticsSummary summary;
  final AnalyticsQuickStats quickStats;

  AnalyticsModel({
    required this.period,
    required this.summary,
    required this.quickStats,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      period: json['period'] ?? '',
      summary: AnalyticsSummary.fromJson(json['summary'] ?? {}),
      quickStats: AnalyticsQuickStats.fromJson(json['quickStats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'summary': summary.toJson(),
      'quickStats': quickStats.toJson(),
    };
  }
}

class AnalyticsSummary {
  final double totalRevenue;
  final int totalOrders;
  final double growth;

  AnalyticsSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.growth,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      growth: (json['growth'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'growth': growth,
    };
  }
}

class AnalyticsQuickStats {
  final double avgOrder;
  final int customers;
  final int products;
  final double conversion;

  AnalyticsQuickStats({
    required this.avgOrder,
    required this.customers,
    required this.products,
    required this.conversion,
  });

  factory AnalyticsQuickStats.fromJson(Map<String, dynamic> json) {
    return AnalyticsQuickStats(
      avgOrder: (json['avgOrder'] ?? 0).toDouble(),
      customers: json['customers'] ?? 0,
      products: json['products'] ?? 0,
      conversion: (json['conversion'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avgOrder': avgOrder,
      'customers': customers,
      'products': products,
      'conversion': conversion,
    };
  }
}

import 'dart:developer';
import '../libs.dart';

class AnalyticsController extends GetxController {
  // Loading States
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var isExporting = false.obs;

  // Date Range Selection
  var selectedDateRange = 'month'.obs;
  var startDate = DateTime.now().subtract(Duration(days: 30)).obs;
  var endDate = DateTime.now().obs;

  // Sales Analytics
  var totalRevenue = 0.0.obs;
  var totalOrders = 0.obs;
  var averageOrderValue = 0.0.obs;
  var conversionRate = 0.0.obs;

  // Growth Metrics
  var revenueGrowth = 0.0.obs;
  var orderGrowth = 0.0.obs;
  var customerGrowth = 0.0.obs;

  // Chart Data
  var salesChartData = <SalesDataPoint>[].obs;
  var orderChartData = <OrderDataPoint>[].obs;
  var categoryChartData = <CategoryDataPoint>[].obs;
  var topProductsData = <ProductAnalytics>[].obs;

  // Customer Analytics
  var totalCustomers = 0.obs;
  var newCustomers = 0.obs;
  var returningCustomers = 0.obs;
  var customerRetentionRate = 0.0.obs;

  // Product Analytics
  var totalProducts = 0.obs;
  var activeProducts = 0.obs;
  var outOfStockProducts = 0.obs;
  var lowStockProducts = 0.obs;

  // Date Range Options
  final List<Map<String, String>> dateRangeOptions = [
    {'value': 'today', 'label': 'Today'},
    {'value': 'week', 'label': 'This Week'},
    {'value': 'month', 'label': 'This Month'},
    {'value': 'quarter', 'label': 'This Quarter'},
    {'value': 'year', 'label': 'This Year'},
    {'value': 'custom', 'label': 'Custom Range'},
  ];

  @override
  void onInit() {
    super.onInit();
    setDateRange('month');
    loadAnalytics();
  }

  // ========== Load Analytics Data ==========

  Future<void> loadAnalytics({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      await Future.wait([
        fetchSalesAnalytics(),
        fetchOrderAnalytics(),
        fetchCustomerAnalytics(),
        fetchProductAnalytics(),
        fetchChartData(),
      ]);

      log('✅ Analytics data loaded successfully');
    } catch (e) {
      log('❌ Error loading analytics: $e');
      Get.snackbar(
        'Error',
        'Failed to load analytics data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ========== Fetch Sales Analytics ==========

  Future<void> fetchSalesAnalytics() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 500));

      // Generate dummy sales data based on date range
      final days = endDate.value.difference(startDate.value).inDays;

      totalRevenue.value = _generateRevenueForPeriod(days);
      totalOrders.value = _generateOrdersForPeriod(days);
      averageOrderValue.value =
          totalOrders.value > 0 ? totalRevenue.value / totalOrders.value : 0.0;
      conversionRate.value = _generateConversionRate();

      // Calculate growth metrics (compared to previous period)
      revenueGrowth.value = _generateGrowthRate();
      orderGrowth.value = _generateGrowthRate();
      customerGrowth.value = _generateGrowthRate();
    } catch (e) {
      log('❌ Error fetching sales analytics: $e');
      rethrow;
    }
  }

  // ========== Fetch Order Analytics ==========

  Future<void> fetchOrderAnalytics() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 300));

      // Generate dummy order analytics
      // This would come from your API
    } catch (e) {
      log('❌ Error fetching order analytics: $e');
      rethrow;
    }
  }

  // ========== Fetch Customer Analytics ==========

  Future<void> fetchCustomerAnalytics() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 400));

      totalCustomers.value = 1250;
      newCustomers.value = 85;
      returningCustomers.value = 165;
      customerRetentionRate.value = 68.5;
    } catch (e) {
      log('❌ Error fetching customer analytics: $e');
      rethrow;
    }
  }

  // ========== Fetch Product Analytics ==========

  Future<void> fetchProductAnalytics() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 350));

      totalProducts.value = 48;
      activeProducts.value = 43;
      outOfStockProducts.value = 3;
      lowStockProducts.value = 7;

      // Generate top products data
      topProductsData.value = _generateTopProductsData();
    } catch (e) {
      log('❌ Error fetching product analytics: $e');
      rethrow;
    }
  }

  // ========== Fetch Chart Data ==========

  Future<void> fetchChartData() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 600));

      salesChartData.value = _generateSalesChartData();
      orderChartData.value = _generateOrderChartData();
      categoryChartData.value = _generateCategoryChartData();
    } catch (e) {
      log('❌ Error fetching chart data: $e');
      rethrow;
    }
  }

  // ========== Date Range Management ==========

  void setDateRange(String range) {
    selectedDateRange.value = range;

    final now = DateTime.now();
    switch (range) {
      case 'today':
        startDate.value = DateTime(now.year, now.month, now.day);
        endDate.value = now;
        break;
      case 'week':
        startDate.value = now.subtract(Duration(days: now.weekday - 1));
        endDate.value = now;
        break;
      case 'month':
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = now;
        break;
      case 'quarter':
        final quarterStart = DateTime(
          now.year,
          ((now.month - 1) ~/ 3) * 3 + 1,
          1,
        );
        startDate.value = quarterStart;
        endDate.value = now;
        break;
      case 'year':
        startDate.value = DateTime(now.year, 1, 1);
        endDate.value = now;
        break;
    }

    if (range != 'custom') {
      loadAnalytics();
    }
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    selectedDateRange.value = 'custom';
    loadAnalytics();
  }

  // ========== Export Functions ==========

  Future<void> exportReport(String format) async {
    isExporting.value = true;

    try {
      // TODO: Implement actual export functionality
      await Future.delayed(Duration(seconds: 2));

      Get.snackbar(
        'Export Complete',
        'Analytics report exported as $format',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        'Failed to export report: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isExporting.value = false;
    }
  }

  // ========== Helper Methods ==========

  double _generateRevenueForPeriod(int days) {
    // Simulate revenue based on period length
    final baseDaily = 2500.0;
    final variance = 0.3;
    final random = DateTime.now().millisecond / 1000;
    return baseDaily * days * (1 + (random - 0.5) * variance);
  }

  int _generateOrdersForPeriod(int days) {
    // Simulate orders based on period length
    final baseDaily = 12;
    final variance = 0.4;
    final random = DateTime.now().millisecond / 1000;
    return (baseDaily * days * (1 + (random - 0.5) * variance)).round();
  }

  double _generateConversionRate() {
    // Simulate conversion rate between 2-8%
    final base = 4.5;
    final variance = 1.5;
    final random = DateTime.now().millisecond / 1000;
    return base + (random - 0.5) * variance;
  }

  double _generateGrowthRate() {
    // Simulate growth rate between -15% to +25%
    final base = 5.0;
    final variance = 20.0;
    final random = DateTime.now().millisecond / 1000;
    return base + (random - 0.5) * variance;
  }

  List<SalesDataPoint> _generateSalesChartData() {
    final data = <SalesDataPoint>[];
    final days = endDate.value.difference(startDate.value).inDays;
    final pointCount = days > 30 ? 30 : days;

    for (int i = 0; i < pointCount; i++) {
      final date = startDate.value.add(
        Duration(days: (days / pointCount * i).round()),
      );
      final revenue = 1500 + (i * 100) + (DateTime.now().millisecond % 500);
      data.add(SalesDataPoint(date: date, revenue: revenue.toDouble()));
    }

    return data;
  }

  List<OrderDataPoint> _generateOrderChartData() {
    final data = <OrderDataPoint>[];
    final days = endDate.value.difference(startDate.value).inDays;
    final pointCount = days > 30 ? 30 : days;

    for (int i = 0; i < pointCount; i++) {
      final date = startDate.value.add(
        Duration(days: (days / pointCount * i).round()),
      );
      final orders = 8 + (i % 5) + (DateTime.now().millisecond % 3);
      data.add(OrderDataPoint(date: date, orders: orders));
    }

    return data;
  }

  List<CategoryDataPoint> _generateCategoryChartData() {
    return [
      CategoryDataPoint(category: 'Dog Food', value: 35.5, color: Colors.blue),
      CategoryDataPoint(
        category: 'Cat Food',
        value: 28.2,
        color: Colors.orange,
      ),
      CategoryDataPoint(category: 'Toys', value: 18.7, color: Colors.green),
      CategoryDataPoint(
        category: 'Accessories',
        value: 12.3,
        color: Colors.purple,
      ),
      CategoryDataPoint(category: 'Healthcare', value: 5.3, color: Colors.red),
    ];
  }

  List<ProductAnalytics> _generateTopProductsData() {
    return [
      ProductAnalytics(
        id: 'p1',
        name: 'Premium Dog Food 5kg',
        revenue: 15680.0,
        unitsSold: 145,
        growth: 12.5,
      ),
      ProductAnalytics(
        id: 'p2',
        name: 'Cat Food Premium',
        revenue: 12340.0,
        unitsSold: 132,
        growth: 8.3,
      ),
      ProductAnalytics(
        id: 'p3',
        name: 'Dog Treats Pack',
        revenue: 8950.0,
        unitsSold: 98,
        growth: -2.1,
      ),
      ProductAnalytics(
        id: 'p4',
        name: 'Interactive Cat Toy',
        revenue: 6780.0,
        unitsSold: 76,
        growth: 18.7,
      ),
      ProductAnalytics(
        id: 'p5',
        name: 'Dog Leash Premium',
        revenue: 4560.0,
        unitsSold: 54,
        growth: 5.2,
      ),
    ];
  }

  // ========== Refresh ==========

  Future<void> refreshAnalytics() async {
    await loadAnalytics(isRefresh: true);
  }

  // ========== Getters for formatted values ==========

  String get formattedTotalRevenue =>
      '₹${totalRevenue.value.toStringAsFixed(0)}';
  String get formattedAverageOrderValue =>
      '₹${averageOrderValue.value.toStringAsFixed(0)}';
  String get formattedConversionRate =>
      '${conversionRate.value.toStringAsFixed(1)}%';
  String get formattedRevenueGrowth =>
      '${revenueGrowth.value >= 0 ? '+' : ''}${revenueGrowth.value.toStringAsFixed(1)}%';
  String get formattedOrderGrowth =>
      '${orderGrowth.value >= 0 ? '+' : ''}${orderGrowth.value.toStringAsFixed(1)}%';
  String get formattedCustomerGrowth =>
      '${customerGrowth.value >= 0 ? '+' : ''}${customerGrowth.value.toStringAsFixed(1)}%';
  String get formattedRetentionRate =>
      '${customerRetentionRate.value.toStringAsFixed(1)}%';

  String get selectedDateRangeLabel {
    return dateRangeOptions.firstWhere(
      (option) => option['value'] == selectedDateRange.value,
      orElse: () => {'label': 'Custom Range'},
    )['label']!;
  }
}

// ========== Analytics Models ==========

class SalesDataPoint {
  final DateTime date;
  final double revenue;

  SalesDataPoint({required this.date, required this.revenue});
}

class OrderDataPoint {
  final DateTime date;
  final int orders;

  OrderDataPoint({required this.date, required this.orders});
}

class CategoryDataPoint {
  final String category;
  final double value;
  final Color color;

  CategoryDataPoint({
    required this.category,
    required this.value,
    required this.color,
  });
}

class ProductAnalytics {
  final String id;
  final String name;
  final double revenue;
  final int unitsSold;
  final double growth;

  ProductAnalytics({
    required this.id,
    required this.name,
    required this.revenue,
    required this.unitsSold,
    required this.growth,
  });

  String get formattedRevenue => '₹${revenue.toStringAsFixed(0)}';
  String get formattedGrowth =>
      '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%';
  Color get growthColor => growth >= 0 ? Colors.green : Colors.red;
}

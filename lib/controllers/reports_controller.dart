import 'dart:developer';
import '../libs.dart';

class ReportsController extends GetxController {
  // Loading States
  var isLoading = false.obs;
  var isGenerating = false.obs;
  var isExporting = false.obs;

  // Available Reports
  var availableReports = <ReportTemplate>[].obs;
  var generatedReports = <GeneratedReport>[].obs;

  // Filters
  var selectedReportType = 'all'.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  // ========== Load Reports ==========

  Future<void> loadReports() async {
    isLoading.value = true;

    try {
      await Future.wait([loadAvailableReports(), loadGeneratedReports()]);

      log('✅ Reports loaded successfully');
    } catch (e) {
      log('❌ Error loading reports: $e');
      Get.snackbar(
        'Error',
        'Failed to load reports',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAvailableReports() async {
    // TODO: Replace with actual API call
    await Future.delayed(Duration(milliseconds: 500));

    availableReports.value = [
      ReportTemplate(
        id: 'sales_summary',
        name: 'Sales Summary Report',
        description: 'Comprehensive overview of sales performance',
        category: ReportCategory.sales,
        icon: Icons.trending_up,
        color: Colors.green,
        estimatedTime: '2-3 minutes',
        parameters: [
          ReportParameter(
            key: 'date_range',
            label: 'Date Range',
            type: ParameterType.dateRange,
            required: true,
          ),
          ReportParameter(
            key: 'include_charts',
            label: 'Include Charts',
            type: ParameterType.boolean,
            required: false,
            defaultValue: true,
          ),
        ],
      ),
      ReportTemplate(
        id: 'product_performance',
        name: 'Product Performance Report',
        description: 'Detailed analysis of product sales and inventory',
        category: ReportCategory.products,
        icon: Icons.inventory_2,
        color: Colors.blue,
        estimatedTime: '3-5 minutes',
        parameters: [
          ReportParameter(
            key: 'date_range',
            label: 'Date Range',
            type: ParameterType.dateRange,
            required: true,
          ),
          ReportParameter(
            key: 'category',
            label: 'Product Category',
            type: ParameterType.dropdown,
            required: false,
            options: ['All', 'Dog Food', 'Cat Food', 'Toys', 'Accessories'],
          ),
        ],
      ),
      ReportTemplate(
        id: 'customer_analysis',
        name: 'Customer Analysis Report',
        description: 'Customer behavior and retention insights',
        category: ReportCategory.customers,
        icon: Icons.people,
        color: Colors.purple,
        estimatedTime: '4-6 minutes',
        parameters: [
          ReportParameter(
            key: 'date_range',
            label: 'Date Range',
            type: ParameterType.dateRange,
            required: true,
          ),
          ReportParameter(
            key: 'segment',
            label: 'Customer Segment',
            type: ParameterType.dropdown,
            required: false,
            options: ['All', 'New', 'Returning', 'VIP'],
          ),
        ],
      ),
      ReportTemplate(
        id: 'financial_summary',
        name: 'Financial Summary Report',
        description: 'Revenue, expenses, and profit analysis',
        category: ReportCategory.financial,
        icon: Icons.account_balance,
        color: Colors.orange,
        estimatedTime: '5-7 minutes',
        parameters: [
          ReportParameter(
            key: 'date_range',
            label: 'Date Range',
            type: ParameterType.dateRange,
            required: true,
          ),
          ReportParameter(
            key: 'include_expenses',
            label: 'Include Expenses',
            type: ParameterType.boolean,
            required: false,
            defaultValue: true,
          ),
        ],
      ),
      ReportTemplate(
        id: 'inventory_report',
        name: 'Inventory Status Report',
        description: 'Current stock levels and reorder recommendations',
        category: ReportCategory.inventory,
        icon: Icons.warehouse,
        color: Colors.teal,
        estimatedTime: '1-2 minutes',
        parameters: [
          ReportParameter(
            key: 'stock_level',
            label: 'Stock Level Filter',
            type: ParameterType.dropdown,
            required: false,
            options: ['All', 'Low Stock', 'Out of Stock', 'Overstocked'],
          ),
        ],
      ),
    ];
  }

  Future<void> loadGeneratedReports() async {
    // TODO: Replace with actual API call
    await Future.delayed(Duration(milliseconds: 300));

    generatedReports.value = [
      GeneratedReport(
        id: 'report_001',
        templateId: 'sales_summary',
        name: 'Sales Summary - December 2024',
        status: ReportStatus.completed,
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        fileSize: '2.4 MB',
        format: 'PDF',
      ),
      GeneratedReport(
        id: 'report_002',
        templateId: 'product_performance',
        name: 'Product Performance - Q4 2024',
        status: ReportStatus.completed,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        fileSize: '3.1 MB',
        format: 'Excel',
      ),
      GeneratedReport(
        id: 'report_003',
        templateId: 'customer_analysis',
        name: 'Customer Analysis - November 2024',
        status: ReportStatus.failed,
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        fileSize: '',
        format: 'PDF',
        error: 'Insufficient data for the selected period',
      ),
    ];
  }

  // ========== Generate Report ==========

  Future<void> generateReport(
    ReportTemplate template,
    Map<String, dynamic> parameters,
  ) async {
    isGenerating.value = true;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 3));

      // Simulate report generation
      final newReport = GeneratedReport(
        id: 'report_${DateTime.now().millisecondsSinceEpoch}',
        templateId: template.id,
        name:
            '${template.name} - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        status: ReportStatus.completed,
        createdAt: DateTime.now(),
        fileSize:
            '${(1.5 + DateTime.now().millisecond / 1000).toStringAsFixed(1)} MB',
        format: 'PDF',
      );

      generatedReports.insert(0, newReport);

      Get.snackbar(
        'Report Generated',
        'Your report has been generated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Generation Failed',
        'Failed to generate report: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  // ========== Export/Download Report ==========

  Future<void> downloadReport(GeneratedReport report) async {
    if (report.status != ReportStatus.completed) return;

    try {
      // TODO: Implement actual download functionality
      await Future.delayed(Duration(seconds: 1));

      Get.snackbar(
        'Download Started',
        'Report download started: ${report.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Download Failed',
        'Failed to download report: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========== Delete Report ==========

  Future<void> deleteReport(GeneratedReport report) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Report'),
        content: Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // TODO: Replace with actual API call
        await Future.delayed(Duration(milliseconds: 500));

        generatedReports.removeWhere((r) => r.id == report.id);

        Get.snackbar(
          'Report Deleted',
          'Report has been deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } catch (e) {
        Get.snackbar(
          'Delete Failed',
          'Failed to delete report: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // ========== Filters ==========

  void setReportTypeFilter(String type) {
    selectedReportType.value = type;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<ReportTemplate> get filteredAvailableReports {
    var reports = availableReports.toList();

    // Filter by type
    if (selectedReportType.value != 'all') {
      final category = _getCategoryFromString(selectedReportType.value);
      reports = reports.where((r) => r.category == category).toList();
    }

    // Filter by search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      reports =
          reports
              .where(
                (r) =>
                    r.name.toLowerCase().contains(query) ||
                    r.description.toLowerCase().contains(query),
              )
              .toList();
    }

    return reports;
  }

  List<GeneratedReport> get filteredGeneratedReports {
    var reports = generatedReports.toList();

    // Filter by search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      reports =
          reports.where((r) => r.name.toLowerCase().contains(query)).toList();
    }

    return reports;
  }

  ReportCategory _getCategoryFromString(String category) {
    switch (category) {
      case 'sales':
        return ReportCategory.sales;
      case 'products':
        return ReportCategory.products;
      case 'customers':
        return ReportCategory.customers;
      case 'financial':
        return ReportCategory.financial;
      case 'inventory':
        return ReportCategory.inventory;
      default:
        return ReportCategory.sales;
    }
  }

  // ========== Refresh ==========

  Future<void> refreshReports() async {
    await loadReports();
  }
}

// ========== Report Models ==========

enum ReportCategory { sales, products, customers, financial, inventory }

enum ReportStatus { pending, generating, completed, failed }

enum ParameterType { text, number, boolean, date, dateRange, dropdown }

class ReportTemplate {
  final String id;
  final String name;
  final String description;
  final ReportCategory category;
  final IconData icon;
  final Color color;
  final String estimatedTime;
  final List<ReportParameter> parameters;

  ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.estimatedTime,
    required this.parameters,
  });

  String get categoryName {
    switch (category) {
      case ReportCategory.sales:
        return 'Sales';
      case ReportCategory.products:
        return 'Products';
      case ReportCategory.customers:
        return 'Customers';
      case ReportCategory.financial:
        return 'Financial';
      case ReportCategory.inventory:
        return 'Inventory';
    }
  }
}

class ReportParameter {
  final String key;
  final String label;
  final ParameterType type;
  final bool required;
  final dynamic defaultValue;
  final List<String>? options;

  ReportParameter({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    this.defaultValue,
    this.options,
  });
}

class GeneratedReport {
  final String id;
  final String templateId;
  final String name;
  final ReportStatus status;
  final DateTime createdAt;
  final String fileSize;
  final String format;
  final String? error;

  GeneratedReport({
    required this.id,
    required this.templateId,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.fileSize,
    required this.format,
    this.error,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  Color get statusColor {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.generating:
        return Colors.blue;
      case ReportStatus.completed:
        return Colors.green;
      case ReportStatus.failed:
        return Colors.red;
    }
  }

  String get statusText {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.generating:
        return 'Generating';
      case ReportStatus.completed:
        return 'Completed';
      case ReportStatus.failed:
        return 'Failed';
    }
  }
}

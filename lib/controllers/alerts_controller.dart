import 'dart:developer';
import '../libs.dart';

class AlertsController extends GetxController {
  // Loading States
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var isResolvingAlert = false.obs;

  // Alerts Data
  var alerts = <AlertModel>[].obs;
  var filteredAlerts = <AlertModel>[].obs;

  // Filter & Search
  var searchQuery = ''.obs;
  var selectedFilter = 'all'.obs;

  // Summary Data
  var totalAlerts = 0.obs;
  var criticalAlerts = 0.obs;
  var resolvedToday = 0.obs;

  // Filter Options
  final List<Map<String, String>> filterOptions = [
    {'value': 'all', 'label': 'All Alerts'},
    {'value': 'lowStock', 'label': 'Low Stock'},
    {'value': 'newOrder', 'label': 'New Orders'},
    {'value': 'general', 'label': 'General'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
  }

  // ========== Load Alerts ==========

  Future<void> loadAlerts({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 800));

      // Generate dummy alerts data
      final newAlerts = _generateDummyAlerts();

      alerts.value = newAlerts;
      _calculateSummary();
      applyFilters();

      log('✅ Alerts loaded');
    } catch (e) {
      log('❌ Error loading alerts: $e');
      Get.snackbar(
        'Error',
        'Failed to load alerts',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  List<AlertModel> _generateDummyAlerts() {
    return [
      AlertModel(
        type: AlertType.lowStock,
        title: 'Low Stock Alert',
        message: 'Premium Dog Food 5kg - Only 2 units left',
        count: 2,
        actionRoute: AppRoutes.inventory,
      ),
      AlertModel(
        type: AlertType.lowStock,
        title: 'Low Stock Alert',
        message: 'Cat Food Premium - Only 1 unit left',
        count: 1,
        actionRoute: AppRoutes.inventory,
      ),
      AlertModel(
        type: AlertType.lowStock,
        title: 'Low Stock Alert',
        message: 'Dog Treats Pack - Only 3 units left',
        count: 3,
        actionRoute: AppRoutes.inventory,
      ),
      AlertModel(
        type: AlertType.newOrder,
        title: 'New Order Received',
        message: 'Order #ORD-2024-001 from John Doe - ₹1,250',
        count: 1,
        actionRoute: AppRoutes.orders,
      ),
      AlertModel(
        type: AlertType.newOrder,
        title: 'New Order Received',
        message: 'Order #ORD-2024-002 from Jane Smith - ₹890',
        count: 1,
        actionRoute: AppRoutes.orders,
      ),
      AlertModel(
        type: AlertType.general,
        title: 'System Maintenance',
        message: 'Scheduled maintenance on Jan 15, 2025 at 2:00 AM',
        count: 1,
      ),
      AlertModel(
        type: AlertType.general,
        title: 'Payment Gateway Update',
        message: 'New payment options available for customers',
        count: 1,
      ),
    ];
  }

  void _calculateSummary() {
    totalAlerts.value = alerts.length;
    criticalAlerts.value =
        alerts
            .where((a) => a.type == AlertType.lowStock && a.count <= 2)
            .length;

    // Simulate resolved alerts today
    resolvedToday.value = 3;
  }

  // ========== Search & Filter ==========

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  void applyFilters() {
    List<AlertModel> result = List.from(alerts);

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      result =
          result.where((alert) {
            final query = searchQuery.value.toLowerCase();
            return alert.title.toLowerCase().contains(query) ||
                alert.message.toLowerCase().contains(query);
          }).toList();
    }

    // Type filter
    if (selectedFilter.value != 'all') {
      final filterType = _getAlertTypeFromString(selectedFilter.value);
      result = result.where((a) => a.type == filterType).toList();
    }

    // Sort by priority (low stock first, then by count)
    result.sort((a, b) {
      if (a.type == AlertType.lowStock && b.type != AlertType.lowStock) {
        return -1;
      } else if (a.type != AlertType.lowStock && b.type == AlertType.lowStock) {
        return 1;
      } else if (a.type == AlertType.lowStock && b.type == AlertType.lowStock) {
        return a.count.compareTo(b.count);
      }
      return 0;
    });

    filteredAlerts.value = result;
  }

  AlertType _getAlertTypeFromString(String type) {
    switch (type) {
      case 'lowStock':
        return AlertType.lowStock;
      case 'newOrder':
        return AlertType.newOrder;
      case 'general':
        return AlertType.general;
      default:
        return AlertType.general;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedFilter.value = 'all';
    applyFilters();
  }

  // ========== Alert Actions ==========

  Future<void> resolveAlert(AlertModel alert) async {
    isResolvingAlert.value = true;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 500));

      // Remove alert from list
      alerts.removeWhere((a) => a == alert);
      applyFilters();
      _calculateSummary();

      Get.snackbar(
        'Success',
        'Alert resolved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to resolve alert',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isResolvingAlert.value = false;
    }
  }

  void handleAlertAction(AlertModel alert) {
    if (alert.actionRoute != null) {
      Get.toNamed(alert.actionRoute!);
    } else {
      _showAlertDetails(alert);
    }
  }

  void _showAlertDetails(AlertModel alert) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),

            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: getAlertTypeColor(alert.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    getAlertTypeIcon(alert.type),
                    color: getAlertTypeColor(alert.type),
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alert.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            Text(
              alert.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

            if (alert.count > 0) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Count: ${alert.count}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: Text('Close'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      resolveAlert(alert);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Resolve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========== Helper Methods ==========

  IconData getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return Icons.inventory_2;
      case AlertType.newOrder:
        return Icons.shopping_bag;
      case AlertType.general:
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color getAlertTypeColor(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return Colors.orange;
      case AlertType.newOrder:
        return Colors.green;
      case AlertType.general:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String getAlertTypeDisplayName(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return 'Low Stock';
      case AlertType.newOrder:
        return 'New Order';
      case AlertType.general:
        return 'General';
      default:
        return 'Alert';
    }
  }

  // ========== Refresh ==========

  Future<void> refreshAlerts() async {
    await loadAlerts(isRefresh: true);
  }
}

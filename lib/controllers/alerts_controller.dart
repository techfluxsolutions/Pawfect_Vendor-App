import 'dart:developer';
import '../libs.dart';
import '../services/alerts_service.dart';

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

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD ALERTS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> loadAlerts({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      // Call the actual API using the service
      final alertsService = AlertsService();
      final response = await alertsService.getAlerts();

      if (response.success && response.data != null) {
        // Convert API alerts to AlertModel for UI compatibility
        final newAlerts =
            response.data!.alerts
                .map((apiAlert) => apiAlert.toAlertModel())
                .toList();

        alerts.value = newAlerts;

        // Update summary with API data
        totalAlerts.value = response.data!.summary.total;
        criticalAlerts.value = response.data!.summary.critical;

        // Calculate resolved today (this might need to come from API in future)
        resolvedToday.value = 0; // TODO: Get from API when available

        applyFilters();

        log('✅ Alerts loaded from API');
      } else {
        throw Exception(response.message ?? 'Failed to load alerts');
      }
    } catch (e) {
      log('❌ Error loading alerts: $e');

      // Show error to user instead of fallback data
      Get.snackbar(
        'Error',
        'Failed to load alerts. Please check your connection and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      // Clear alerts on error
      alerts.clear();
      totalAlerts.value = 0;
      criticalAlerts.value = 0;
      resolvedToday.value = 0;
      applyFilters();
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEARCH & FILTER
  // ══════════════════════════════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════════════════════════════
  // ALERT ACTIONS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> resolveAlert(AlertModel alert) async {
    isResolvingAlert.value = true;

    try {
      // Use the alert ID if available, otherwise generate a placeholder
      final alertId =
          alert.id ?? 'placeholder-${DateTime.now().millisecondsSinceEpoch}';

      // Call the API to resolve the alert
      final alertsService = AlertsService();
      final response = await alertsService.resolveAlert(alertId);

      if (response.success) {
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
      } else {
        throw Exception(response.message ?? 'Failed to resolve alert');
      }
    } catch (e) {
      log('❌ Error resolving alert: $e');

      Get.snackbar(
        'Error',
        'Failed to resolve alert. Please try again.',
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

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════

  void _calculateSummary() {
    totalAlerts.value = alerts.length;
    criticalAlerts.value =
        alerts
            .where((a) => a.type == AlertType.lowStock && a.count <= 2)
            .length;
    // resolvedToday remains as set from API or 0
  }

  IconData getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return Icons.inventory_2;
      case AlertType.newOrder:
        return Icons.shopping_bag;
      case AlertType.general:
        return Icons.info;
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
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REFRESH
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> refreshAlerts() async {
    await loadAlerts(isRefresh: true);
  }
}

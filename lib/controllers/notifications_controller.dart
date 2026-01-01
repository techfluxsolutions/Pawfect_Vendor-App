import 'dart:developer';
import '../libs.dart';

class NotificationsController extends GetxController {
  // Loading States
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isRefreshing = false.obs;
  var isMarkingAsRead = false.obs;

  // Notifications Data
  var notifications = <NotificationModel>[].obs;
  var filteredNotifications = <NotificationModel>[].obs;

  // Filter & Search
  var searchQuery = ''.obs;
  var selectedFilter = 'all'.obs;
  var selectedDateRange = 'all'.obs;
  var startDate = DateTime.now().subtract(Duration(days: 30)).obs;
  var endDate = DateTime.now().obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  final int pageSize = 20;

  // Summary Data
  var totalNotifications = 0.obs;
  var unreadNotifications = 0.obs;
  var todayNotifications = 0.obs;

  // Filter Options
  final List<Map<String, String>> filterOptions = [
    {'value': 'all', 'label': 'All Notifications'},
    {'value': 'unread', 'label': 'Unread Only'},
    {'value': 'read', 'label': 'Read Only'},
    {'value': 'order', 'label': 'Orders'},
    {'value': 'product', 'label': 'Products'},
    {'value': 'payment', 'label': 'Payments'},
    {'value': 'system', 'label': 'System'},
    {'value': 'promotion', 'label': 'Promotions'},
  ];

  final List<Map<String, String>> dateRangeOptions = [
    {'value': 'all', 'label': 'All Time'},
    {'value': 'today', 'label': 'Today'},
    {'value': 'week', 'label': 'This Week'},
    {'value': 'month', 'label': 'This Month'},
    {'value': 'custom', 'label': 'Custom Range'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  // ========== Load Notifications ==========

  Future<void> loadNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
      currentPage.value = 1;
      hasMoreData.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 800));

      // Generate dummy notifications data
      final newNotifications = _generateDummyNotifications();

      if (isRefresh) {
        notifications.value = newNotifications;
      } else {
        notifications.addAll(newNotifications);
      }

      _calculateSummary();
      applyFilters();

      log('✅ Notifications loaded');
    } catch (e) {
      log('❌ Error loading notifications: $e');
      Get.snackbar(
        'Error',
        'Failed to load notifications',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  List<NotificationModel> _generateDummyNotifications() {
    final List<NotificationModel> dummyNotifications = [
      NotificationModel(
        id: 'notif_001',
        title: 'New Order Received',
        message:
            'You have received a new order #ORD-2024-001 from John Doe worth ₹1,250',
        type: NotificationType.order,
        isRead: false,
        createdAt: DateTime.now().subtract(Duration(minutes: 15)),
        actionData: {'orderId': 'ORD-2024-001', 'action': 'view_order'},
        priority: NotificationPriority.high,
      ),
      NotificationModel(
        id: 'notif_002',
        title: 'Low Stock Alert',
        message:
            'Premium Dog Food 5kg is running low. Only 3 units left in stock.',
        type: NotificationType.product,
        isRead: false,
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        actionData: {'productId': 'prod_001', 'action': 'manage_inventory'},
        priority: NotificationPriority.high,
      ),
      NotificationModel(
        id: 'notif_003',
        title: 'Payment Received',
        message: 'Payment of ₹890 received for order #ORD-2024-002',
        type: NotificationType.payment,
        isRead: true,
        createdAt: DateTime.now().subtract(Duration(hours: 4)),
        actionData: {'orderId': 'ORD-2024-002', 'action': 'view_payment'},
        priority: NotificationPriority.medium,
      ),
      NotificationModel(
        id: 'notif_004',
        title: 'Product Approval Required',
        message:
            'Your product "Cat Food Premium" is pending approval from admin.',
        type: NotificationType.product,
        isRead: false,
        createdAt: DateTime.now().subtract(Duration(hours: 6)),
        actionData: {'productId': 'prod_002', 'action': 'view_product'},
        priority: NotificationPriority.medium,
      ),
      NotificationModel(
        id: 'notif_005',
        title: 'Weekly Sales Report',
        message: 'Your weekly sales report is ready. Total sales: ₹12,450',
        type: NotificationType.system,
        isRead: true,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        actionData: {'reportId': 'report_001', 'action': 'view_report'},
        priority: NotificationPriority.low,
      ),
      NotificationModel(
        id: 'notif_006',
        title: 'Special Promotion Available',
        message:
            'Boost your sales with our new promotion campaign. 20% commission discount!',
        type: NotificationType.promotion,
        isRead: false,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        actionData: {'promotionId': 'promo_001', 'action': 'view_promotion'},
        priority: NotificationPriority.low,
      ),
      NotificationModel(
        id: 'notif_007',
        title: 'Order Cancelled',
        message:
            'Order #ORD-2024-005 has been cancelled by customer Tom Brown.',
        type: NotificationType.order,
        isRead: true,
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        actionData: {'orderId': 'ORD-2024-005', 'action': 'view_order'},
        priority: NotificationPriority.medium,
      ),
    ];

    return dummyNotifications;
  }

  void _calculateSummary() {
    totalNotifications.value = notifications.length;
    unreadNotifications.value = notifications.where((n) => !n.isRead).length;

    final today = DateTime.now();
    todayNotifications.value =
        notifications.where((n) {
          return n.createdAt.year == today.year &&
              n.createdAt.month == today.month &&
              n.createdAt.day == today.day;
        }).length;
  }

  // ========== Load More Notifications ==========

  Future<void> loadMoreNotifications() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    isLoadingMore.value = true;
    currentPage.value++;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 500));

      // Simulate no more data after page 3
      if (currentPage.value > 3) {
        hasMoreData.value = false;
      } else {
        final newNotifications = _generateDummyNotifications();
        notifications.addAll(newNotifications);
        applyFilters();
      }
    } catch (e) {
      log('❌ Error loading more notifications: $e');
    } finally {
      isLoadingMore.value = false;
    }
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
      case 'all':
        startDate.value = DateTime(2020, 1, 1);
        endDate.value = now;
        break;
    }

    if (range != 'custom') {
      applyFilters();
    }
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    selectedDateRange.value = 'custom';
    applyFilters();
  }

  void applyFilters() {
    List<NotificationModel> result = List.from(notifications);

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      result =
          result.where((notification) {
            final query = searchQuery.value.toLowerCase();
            return notification.title.toLowerCase().contains(query) ||
                notification.message.toLowerCase().contains(query);
          }).toList();
    }

    // Type/Status filter
    if (selectedFilter.value != 'all') {
      switch (selectedFilter.value) {
        case 'unread':
          result = result.where((n) => !n.isRead).toList();
          break;
        case 'read':
          result = result.where((n) => n.isRead).toList();
          break;
        case 'order':
          result =
              result.where((n) => n.type == NotificationType.order).toList();
          break;
        case 'product':
          result =
              result.where((n) => n.type == NotificationType.product).toList();
          break;
        case 'payment':
          result =
              result.where((n) => n.type == NotificationType.payment).toList();
          break;
        case 'system':
          result =
              result.where((n) => n.type == NotificationType.system).toList();
          break;
        case 'promotion':
          result =
              result
                  .where((n) => n.type == NotificationType.promotion)
                  .toList();
          break;
      }
    }

    // Date range filter
    if (selectedDateRange.value != 'all') {
      result =
          result.where((notification) {
            return notification.createdAt.isAfter(
                  startDate.value.subtract(Duration(days: 1)),
                ) &&
                notification.createdAt.isBefore(
                  endDate.value.add(Duration(days: 1)),
                );
          }).toList();
    }

    // Sort by date (newest first)
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    filteredNotifications.value = result;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedFilter.value = 'all';
    selectedDateRange.value = 'all';
    applyFilters();
  }

  // ========== Notification Actions ==========

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 300));

      // Update local data
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = notification.copyWith(isRead: true);
        applyFilters();
        _calculateSummary();
      }
    } catch (e) {
      log('❌ Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    isMarkingAsRead.value = true;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1));

      // Update all unread notifications
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = notifications[i].copyWith(isRead: true);
        }
      }

      applyFilters();
      _calculateSummary();

      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark notifications as read',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isMarkingAsRead.value = false;
    }
  }

  Future<void> deleteNotification(NotificationModel notification) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Notification'),
        content: Text('Are you sure you want to delete this notification?'),
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

        notifications.removeWhere((n) => n.id == notification.id);
        applyFilters();
        _calculateSummary();

        Get.snackbar(
          'Success',
          'Notification deleted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete notification',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void handleNotificationAction(NotificationModel notification) {
    // Mark as read when tapped
    markAsRead(notification);

    // Handle specific actions based on notification type
    final actionData = notification.actionData;
    if (actionData != null && actionData['action'] != null) {
      switch (actionData['action']) {
        case 'view_order':
          Get.toNamed(AppRoutes.orders);
          break;
        case 'manage_inventory':
          Get.toNamed(AppRoutes.inventory);
          break;
        case 'view_payment':
          Get.toNamed(AppRoutes.transactionHistory);
          break;
        case 'view_product':
          Get.toNamed(AppRoutes.product);
          break;
        case 'view_report':
          Get.toNamed(AppRoutes.analytics);
          break;
        case 'view_promotion':
          Get.snackbar(
            'Promotion',
            'Opening promotion details...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
          break;
        default:
          // Show notification details
          _showNotificationDetails(notification);
      }
    } else {
      _showNotificationDetails(notification);
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
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
                    color: getNotificationTypeColor(
                      notification.type,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    getNotificationTypeIcon(notification.type),
                    color: getNotificationTypeColor(notification.type),
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notification.title,
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
              notification.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                SizedBox(width: 4),
                Text(
                  notification.formattedDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getPriorityColor(
                      notification.priority,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    notification.priority
                        .toString()
                        .split('.')
                        .last
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: getPriorityColor(notification.priority),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(Get.context!).colorScheme.primary,
                foregroundColor: Colors.black,
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== Helper Methods ==========

  IconData getNotificationTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_bag;
      case NotificationType.product:
        return Icons.inventory_2;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.promotion:
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  Color getNotificationTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Colors.blue;
      case NotificationType.product:
        return Colors.orange;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.system:
        return Colors.purple;
      case NotificationType.promotion:
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Color getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Colors.red;
      case NotificationPriority.medium:
        return Colors.orange;
      case NotificationPriority.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String getNotificationTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return 'Order';
      case NotificationType.product:
        return 'Product';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.system:
        return 'System';
      case NotificationType.promotion:
        return 'Promotion';
      default:
        return 'General';
    }
  }

  // ========== Refresh ==========

  Future<void> refreshNotifications() async {
    await loadNotifications(isRefresh: true);
  }
}

// ========== Notification Models ==========

enum NotificationType { order, product, payment, system, promotion, general }

enum NotificationPriority { high, medium, low }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? actionData;
  final NotificationPriority priority;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.actionData,
    this.priority = NotificationPriority.medium,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: _notificationTypeFromString(json['type'] ?? 'general'),
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      actionData: json['actionData'],
      priority: _notificationPriorityFromString(json['priority'] ?? 'medium'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'actionData': actionData,
      'priority': priority.toString().split('.').last,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? actionData,
    NotificationPriority? priority,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actionData: actionData ?? this.actionData,
      priority: priority ?? this.priority,
    );
  }

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

  static NotificationType _notificationTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return NotificationType.order;
      case 'product':
        return NotificationType.product;
      case 'payment':
        return NotificationType.payment;
      case 'system':
        return NotificationType.system;
      case 'promotion':
        return NotificationType.promotion;
      default:
        return NotificationType.general;
    }
  }

  static NotificationPriority _notificationPriorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return NotificationPriority.high;
      case 'medium':
        return NotificationPriority.medium;
      case 'low':
        return NotificationPriority.low;
      default:
        return NotificationPriority.medium;
    }
  }
}

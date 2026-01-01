import 'dart:developer';
import '../libs.dart';
import '../models/order_model.dart';

class OrdersController extends GetxController {
  // Loading States
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isRefreshing = false.obs;

  // Orders Data
  var orders = <ExtendedOrderModel>[].obs;
  var filteredOrders = <ExtendedOrderModel>[].obs;

  // Filter & Search
  var searchQuery = ''.obs;
  var selectedStatus = 'all'.obs;
  var selectedDateRange = 'all'.obs;
  var startDate = DateTime.now().subtract(Duration(days: 30)).obs;
  var endDate = DateTime.now().obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  final int pageSize = 20;

  // Summary Data
  var totalOrders = 0.obs;
  var pendingOrders = 0.obs;
  var processingOrders = 0.obs;
  var deliveredOrders = 0.obs;
  var cancelledOrders = 0.obs;
  var totalRevenue = 0.0.obs;

  // Filter Options
  final List<Map<String, String>> statusOptions = [
    {'value': 'all', 'label': 'All Orders'},
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'processing', 'label': 'Processing'},
    {'value': 'shipped', 'label': 'Shipped'},
    {'value': 'delivered', 'label': 'Delivered'},
    {'value': 'cancelled', 'label': 'Cancelled'},
    {'value': 'returned', 'label': 'Returned'},
  ];

  final List<Map<String, String>> dateRangeOptions = [
    {'value': 'all', 'label': 'All Time'},
    {'value': 'today', 'label': 'Today'},
    {'value': 'week', 'label': 'This Week'},
    {'value': 'month', 'label': 'This Month'},
    {'value': 'quarter', 'label': 'This Quarter'},
    {'value': 'custom', 'label': 'Custom Range'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  // ========== Load Orders ==========

  Future<void> loadOrders({bool isRefresh = false}) async {
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

      // Generate dummy orders data
      final newOrders = _generateDummyOrders();

      if (isRefresh) {
        orders.value = newOrders;
      } else {
        orders.addAll(newOrders);
      }

      _calculateSummary();
      applyFilters();

      log('✅ Orders loaded');
    } catch (e) {
      log('❌ Error loading orders: $e');
      Get.snackbar(
        'Error',
        'Failed to load orders',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  List<ExtendedOrderModel> _generateDummyOrders() {
    final List<ExtendedOrderModel> dummyOrders = [
      ExtendedOrderModel(
        id: 'ORD-2024-001',
        customerName: 'John Doe',
        customerPhone: '+91 9876543210',
        customerEmail: 'john.doe@email.com',
        amount: 1250.0,
        status: 'pending',
        date: DateTime.now().subtract(Duration(hours: 2)),
        items: [
          {'name': 'Premium Dog Food 5kg', 'quantity': 1, 'price': 1250.0},
        ],
        shippingAddress: '123 Main St, Mumbai, Maharashtra 400001',
        paymentMethod: 'Credit Card',
        orderNotes: 'Please deliver between 10 AM - 6 PM',
      ),
      ExtendedOrderModel(
        id: 'ORD-2024-002',
        customerName: 'Jane Smith',
        customerPhone: '+91 9876543211',
        customerEmail: 'jane.smith@email.com',
        amount: 890.0,
        status: 'processing',
        date: DateTime.now().subtract(Duration(hours: 5)),
        items: [
          {'name': 'Cat Food Premium', 'quantity': 2, 'price': 445.0},
        ],
        shippingAddress: '456 Park Ave, Delhi, Delhi 110001',
        paymentMethod: 'UPI',
      ),
      ExtendedOrderModel(
        id: 'ORD-2024-003',
        customerName: 'Mike Johnson',
        customerPhone: '+91 9876543212',
        customerEmail: 'mike.johnson@email.com',
        amount: 2340.0,
        status: 'delivered',
        date: DateTime.now().subtract(Duration(days: 1)),
        items: [
          {'name': 'Dog Treats Pack', 'quantity': 3, 'price': 349.0},
          {'name': 'Pet Toy Set', 'quantity': 2, 'price': 820.5},
        ],
        shippingAddress: '789 Oak St, Bangalore, Karnataka 560001',
        paymentMethod: 'Cash on Delivery',
        orderNotes: 'Fragile items - handle with care',
      ),
      ExtendedOrderModel(
        id: 'ORD-2024-004',
        customerName: 'Sarah Wilson',
        customerPhone: '+91 9876543213',
        customerEmail: 'sarah.wilson@email.com',
        amount: 670.0,
        status: 'shipped',
        date: DateTime.now().subtract(Duration(days: 2)),
        items: [
          {'name': 'Bird Food Mix', 'quantity': 1, 'price': 670.0},
        ],
        shippingAddress: '321 Pine St, Chennai, Tamil Nadu 600001',
        paymentMethod: 'Digital Wallet',
        orderNotes: 'Call before delivery',
      ),
      ExtendedOrderModel(
        id: 'ORD-2024-005',
        customerName: 'Tom Brown',
        customerPhone: '+91 9876543214',
        customerEmail: 'tom.brown@email.com',
        amount: 1540.0,
        status: 'cancelled',
        date: DateTime.now().subtract(Duration(days: 3)),
        items: [
          {'name': 'Fish Tank Accessories', 'quantity': 1, 'price': 1540.0},
        ],
        shippingAddress: '654 Elm St, Pune, Maharashtra 411001',
        paymentMethod: 'Credit Card',
        orderNotes: 'Customer requested cancellation',
      ),
    ];

    return dummyOrders;
  }

  void _calculateSummary() {
    totalOrders.value = orders.length;
    pendingOrders.value = orders.where((o) => o.status == 'pending').length;
    processingOrders.value =
        orders.where((o) => o.status == 'processing').length;
    deliveredOrders.value = orders.where((o) => o.status == 'delivered').length;
    cancelledOrders.value = orders.where((o) => o.status == 'cancelled').length;

    totalRevenue.value = orders
        .where((o) => o.status != 'cancelled')
        .fold(0.0, (sum, order) => sum + order.amount);
  }

  // ========== Load More Orders ==========

  Future<void> loadMoreOrders() async {
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
        final newOrders = _generateDummyOrders();
        orders.addAll(newOrders);
        applyFilters();
      }
    } catch (e) {
      log('❌ Error loading more orders: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ========== Search & Filter ==========

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
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
      case 'quarter':
        final quarterStart = DateTime(
          now.year,
          ((now.month - 1) ~/ 3) * 3 + 1,
          1,
        );
        startDate.value = quarterStart;
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
    List<ExtendedOrderModel> result = List.from(orders);

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      result =
          result.where((order) {
            final query = searchQuery.value.toLowerCase();
            return order.id.toLowerCase().contains(query) ||
                order.customerName.toLowerCase().contains(query) ||
                (order.customerPhone?.contains(query) ?? false);
          }).toList();
    }

    // Status filter
    if (selectedStatus.value != 'all') {
      result =
          result.where((order) {
            return order.status == selectedStatus.value;
          }).toList();
    }

    // Date range filter
    if (selectedDateRange.value != 'all') {
      result =
          result.where((order) {
            return order.date.isAfter(
                  startDate.value.subtract(Duration(days: 1)),
                ) &&
                order.date.isBefore(endDate.value.add(Duration(days: 1)));
          }).toList();
    }

    // Sort by date (newest first)
    result.sort((a, b) => b.date.compareTo(a.date));

    filteredOrders.value = result;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedStatus.value = 'all';
    selectedDateRange.value = 'all';
    applyFilters();
  }

  // ========== Order Actions ==========

  void viewOrderDetails(ExtendedOrderModel order) {
    Get.toNamed(AppRoutes.orderDetails, arguments: order);
  }

  Future<void> updateOrderStatus(
    ExtendedOrderModel order,
    String newStatus,
  ) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 500));

      // Update local data
      final index = orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        orders[index] = order.copyWith(status: newStatus);
        applyFilters();
        _calculateSummary();
      }

      Get.snackbar(
        'Success',
        'Order status updated to ${newStatus.toUpperCase()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update order status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void callCustomer(ExtendedOrderModel order) {
    Get.snackbar(
      'Calling Customer',
      'Calling ${order.customerName} at ${order.customerPhone}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void sendMessage(ExtendedOrderModel order) {
    Get.snackbar(
      'Sending Message',
      'Opening message to ${order.customerName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  // ========== Helper Methods ==========

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.sync;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'returned':
        return Icons.undo;
      default:
        return Icons.help_outline;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'returned':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String getStatusDisplayName(String status) {
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }

  // ========== Refresh ==========

  Future<void> refreshOrders() async {
    await loadOrders(isRefresh: true);
  }
}

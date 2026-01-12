import 'dart:async';
import 'dart:developer';
import '../libs.dart';

class OrdersController extends GetxController {
  final OrdersService _ordersService = OrdersService();

  // Loading States
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isRefreshing = false.obs;

  // API Data
  var ordersResponse = Rxn<OrdersResponseModel>();
  var apiOrders = <OrdersApiModel>[].obs;

  // Legacy Data (for UI compatibility)
  var orders = <ExtendedOrderModel>[].obs;
  var filteredOrders = <ExtendedOrderModel>[].obs;

  // Filter & Search
  var searchQuery = ''.obs;
  var selectedStatus = 'all'.obs;
  var selectedPaymentStatus = 'all'.obs;
  var selectedDateRange = 'all'.obs;
  var startDate = DateTime.now().subtract(Duration(days: 30)).obs;
  var endDate = DateTime.now().obs;
  var sortBy = 'date'.obs;
  var sortOrder = 'desc'.obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  final int pageSize = 20;

  // Summary Data (from API)
  var totalOrders = 0.obs;
  var totalRevenue = 0.0.obs;
  var statusCounts = <String, int>{}.obs;

  // Computed summary for UI compatibility
  var pendingOrders = 0.obs;
  var processingOrders = 0.obs;
  var deliveredOrders = 0.obs;
  var cancelledOrders = 0.obs;

  // Filter Options
  final List<Map<String, String>> statusOptions = [
    {'value': 'all', 'label': 'All Orders'},
    {'value': 'Pending', 'label': 'Pending'},
    {'value': 'Processing', 'label': 'Processing'},
    {'value': 'Completed', 'label': 'Completed'},
    {'value': 'Shipped', 'label': 'Shipped'},
    {'value': 'Delivered', 'label': 'Delivered'},
    {'value': 'Cancelled', 'label': 'Cancelled'},
  ];

  final List<Map<String, String>> paymentStatusOptions = [
    {'value': 'all', 'label': 'All Payments'},
    {'value': 'Pending', 'label': 'Pending'},
    {'value': 'Completed', 'label': 'Completed'},
    {'value': 'Failed', 'label': 'Failed'},
    {'value': 'Refunded', 'label': 'Refunded'},
  ];

  final List<Map<String, String>> sortOptions = [
    {'value': 'date', 'label': 'Order Date'},
    {'value': 'amount', 'label': 'Order Amount'},
    {'value': 'status', 'label': 'Status'},
    {'value': 'customer', 'label': 'Customer Name'},
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

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD ORDERS FROM API
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> loadOrders({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
      currentPage.value = 1;
      hasMoreData.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      log('📦 Loading orders from API...');

      final response = await _ordersService.getOrders(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: selectedStatus.value != 'all' ? selectedStatus.value : null,
        paymentStatus:
            selectedPaymentStatus.value != 'all'
                ? selectedPaymentStatus.value
                : null,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
        page: currentPage.value,
        limit: pageSize,
      );

      if (response.success && response.data != null) {
        final ordersData = response.data!;

        // Store API response
        ordersResponse.value = ordersData;

        if (isRefresh) {
          apiOrders.value = ordersData.orders;
        } else {
          apiOrders.addAll(ordersData.orders);
        }

        // Update summary from API
        _updateSummaryFromApi(ordersData.summary);

        // Convert to legacy format for UI compatibility
        _convertToLegacyFormat();

        // Apply local filters if needed
        applyFilters();

        log('✅ Orders loaded successfully: ${ordersData.orders.length} orders');

        // Check if we have more data
        hasMoreData.value = ordersData.orders.length >= pageSize;
      } else {
        log('⚠️ Orders API failed: ${response.message}');
        // Load dummy data as fallback
        _loadDummyOrders(isRefresh);
        _showInfoSnackbar('Using sample order data');
      }
    } catch (e) {
      log('❌ Error loading orders: $e');
      // Load dummy data as fallback
      _loadDummyOrders(isRefresh);
      _showErrorSnackbar('Failed to load orders');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE SUMMARY FROM API
  // ══════════════════════════════════════════════════════════════════════════
  void _updateSummaryFromApi(OrdersSummaryModel summary) {
    totalOrders.value = summary.totalOrders;
    totalRevenue.value = summary.totalRevenue;
    statusCounts.value = summary.statusCounts;

    // Update computed values for UI compatibility
    pendingOrders.value = summary.statusCounts['Pending'] ?? 0;
    processingOrders.value = summary.statusCounts['Processing'] ?? 0;
    deliveredOrders.value = summary.statusCounts['Delivered'] ?? 0;
    cancelledOrders.value = summary.statusCounts['Cancelled'] ?? 0;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONVERT API DATA TO LEGACY FORMAT
  // ══════════════════════════════════════════════════════════════════════════
  void _convertToLegacyFormat() {
    final legacyOrders =
        apiOrders.map((apiOrder) {
          return ExtendedOrderModel(
            id: apiOrder.orderId,
            customerName: apiOrder.clientName,
            customerPhone: apiOrder.phoneNumber,
            customerEmail: '', // Not provided in API
            amount: apiOrder.totalPrice,
            status: apiOrder.status.toLowerCase(),
            date: apiOrder.estimatedDate, // Using estimated date as order date
            items: [
              {
                'name': apiOrder.productName,
                'quantity': apiOrder.quantity,
                'price': apiOrder.price,
              },
            ],
            shippingAddress: '', // Not provided in API
            paymentMethod: apiOrder.paymentStatus,
            orderNotes: '',
          );
        }).toList();

    orders.value = legacyOrders;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FALLBACK DUMMY DATA
  // ══════════════════════════════════════════════════════════════════════════
  void _loadDummyOrders(bool isRefresh) {
    final dummyOrders = _generateDummyOrders();

    if (isRefresh) {
      orders.value = dummyOrders;
    } else {
      orders.addAll(dummyOrders);
    }

    _calculateDummySummary();
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

  void _calculateDummySummary() {
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

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD MORE ORDERS
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> loadMoreOrders() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    isLoadingMore.value = true;
    currentPage.value++;

    try {
      final response = await _ordersService.getOrders(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: selectedStatus.value != 'all' ? selectedStatus.value : null,
        paymentStatus:
            selectedPaymentStatus.value != 'all'
                ? selectedPaymentStatus.value
                : null,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
        page: currentPage.value,
        limit: pageSize,
      );

      if (response.success && response.data != null) {
        final newOrders = response.data!.orders;
        apiOrders.addAll(newOrders);
        _convertToLegacyFormat();
        applyFilters();

        hasMoreData.value = newOrders.length >= pageSize;
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      log('❌ Error loading more orders: $e');
      hasMoreData.value = false;
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEARCH & FILTER METHODS
  // ══════════════════════════════════════════════════════════════════════════
  void setSearchQuery(String query) {
    searchQuery.value = query;
    _debounceSearch();
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
    _reloadWithFilters();
  }

  void setPaymentStatusFilter(String paymentStatus) {
    selectedPaymentStatus.value = paymentStatus;
    _reloadWithFilters();
  }

  void setSortBy(String sort) {
    sortBy.value = sort;
    _reloadWithFilters();
  }

  void setSortOrder(String order) {
    sortOrder.value = order;
    _reloadWithFilters();
  }

  // Debounce search to avoid too many API calls
  Timer? _searchTimer;
  void _debounceSearch() {
    _searchTimer?.cancel();
    _searchTimer = Timer(Duration(milliseconds: 500), () {
      _reloadWithFilters();
    });
  }

  void _reloadWithFilters() {
    currentPage.value = 1;
    hasMoreData.value = true;
    loadOrders(isRefresh: true);
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

  // ══════════════════════════════════════════════════════════════════════════
  // ORDER ACTIONS
  // ══════════════════════════════════════════════════════════════════════════
  void viewOrderDetails(ExtendedOrderModel order) {
    Get.toNamed(AppRoutes.orderDetails, arguments: order);
  }

  Future<void> updateOrderStatus(
    ExtendedOrderModel order,
    String newStatus,
  ) async {
    try {
      log('🔄 Updating order status: ${order.id} -> $newStatus');

      final response = await _ordersService.updateOrderStatus(
        orderId: order.id,
        status: newStatus,
      );

      if (response.success) {
        // Update local data
        final index = orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          orders[index] = order.copyWith(status: newStatus);
          applyFilters();

          // Update API data as well
          final apiIndex = apiOrders.indexWhere((o) => o.orderId == order.id);
          if (apiIndex != -1) {
            // Create updated API order (this is a simplified approach)
            // In a real app, you might want to refetch the order details
          }
        }

        _showSuccessSnackbar(
          'Order status updated to ${newStatus.toUpperCase()}',
        );
      } else {
        _showErrorSnackbar(response.message ?? 'Failed to update order status');
      }
    } catch (e) {
      log('❌ Error updating order status: $e');
      _showErrorSnackbar('Failed to update order status');
    }
  }

  void callCustomer(ExtendedOrderModel order) {
    _showInfoSnackbar(
      'Calling ${order.customerName} at ${order.customerPhone}',
    );
  }

  void sendMessage(ExtendedOrderModel order) {
    _showInfoSnackbar('Opening message to ${order.customerName}');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════
  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.sync;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
      case 'completed':
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
      case 'completed':
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

  // ══════════════════════════════════════════════════════════════════════════
  // SNACKBAR HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void _showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REFRESH
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> refreshOrders() async {
    await loadOrders(isRefresh: true);
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedStatus.value = 'all';
    selectedPaymentStatus.value = 'all';
    selectedDateRange.value = 'all';
    sortBy.value = 'date';
    sortOrder.value = 'desc';
    _reloadWithFilters();
  }
}

import '../libs.dart';

class OrderController extends GetxController {
  // Loading States
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var isLoadingMore = false.obs;
  var isUpdatingOrder = false.obs;

  // Data
  var orders = <VendorOrderModel>[].obs;
  var filteredOrders = <VendorOrderModel>[].obs;

  // Filters
  var searchQuery = ''.obs;
  var selectedStatus = 'all'.obs;
  var selectedDateRange = 'all'.obs;
  var sortBy = 'date'.obs;
  var sortOrder = 'desc'.obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  final int itemsPerPage = 20;

  // Filter Options
  final List<Map<String, String>> statusOptions = [
    {'value': 'all', 'label': 'All Orders'},
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'confirmed', 'label': 'Confirmed'},
    {'value': 'processing', 'label': 'Processing'},
    {'value': 'packed', 'label': 'Packed'},
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
  ];

  final List<Map<String, String>> sortOptions = [
    {'value': 'date', 'label': 'Order Date'},
    {'value': 'amount', 'label': 'Order Amount'},
    {'value': 'status', 'label': 'Status'},
    {'value': 'customer', 'label': 'Customer Name'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadOrders();

    // Setup reactive filtering
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedStatus, (_) => _applyFilters());
    ever(selectedDateRange, (_) => _applyFilters());
    ever(sortBy, (_) => _applyFilters());
    ever(sortOrder, (_) => _applyFilters());
  }

  // ========== Data Loading ==========

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      hasMoreData.value = true;

      // Simulate API call
      await Future.delayed(Duration(seconds: 1));

      orders.value = _generateDummyOrders();
      _applyFilters();

      print('✅ Orders loaded successfully');
    } catch (e) {
      print('❌ Error loading orders: $e');
      Get.snackbar('Error', 'Failed to load orders');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    try {
      isRefreshing.value = true;
      await loadOrders();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadMoreOrders() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      // Simulate API call
      await Future.delayed(Duration(milliseconds: 500));

      // In real app, load more data from API
      // For demo, we'll just mark as no more data after page 3
      if (currentPage.value >= 3) {
        hasMoreData.value = false;
      }
    } catch (e) {
      print('❌ Error loading more orders: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ========== Filtering & Sorting ==========

  void _applyFilters() {
    var filtered =
        orders.where((order) {
          // Search filter
          if (searchQuery.value.isNotEmpty) {
            final query = searchQuery.value.toLowerCase();
            if (!order.id.toLowerCase().contains(query) &&
                !order.customerName.toLowerCase().contains(query) &&
                !order.customerPhone.toLowerCase().contains(query)) {
              return false;
            }
          }

          // Status filter
          if (selectedStatus.value != 'all' &&
              order.status != selectedStatus.value) {
            return false;
          }

          // Date range filter
          if (selectedDateRange.value != 'all') {
            final now = DateTime.now();
            final orderDate = order.orderDate;

            switch (selectedDateRange.value) {
              case 'today':
                if (!_isSameDay(orderDate, now)) return false;
                break;
              case 'week':
                if (now.difference(orderDate).inDays > 7) return false;
                break;
              case 'month':
                if (now.difference(orderDate).inDays > 30) return false;
                break;
              case 'quarter':
                if (now.difference(orderDate).inDays > 90) return false;
                break;
            }
          }

          return true;
        }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;

      switch (sortBy.value) {
        case 'date':
          comparison = a.orderDate.compareTo(b.orderDate);
          break;
        case 'amount':
          comparison = a.totalAmount.compareTo(b.totalAmount);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
        case 'customer':
          comparison = a.customerName.compareTo(b.customerName);
          break;
      }

      return sortOrder.value == 'desc' ? -comparison : comparison;
    });

    filteredOrders.value = filtered;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
  }

  void setDateRangeFilter(String range) {
    selectedDateRange.value = range;
  }

  void setSortBy(String sort) {
    if (sortBy.value == sort) {
      // Toggle sort order if same field
      sortOrder.value = sortOrder.value == 'asc' ? 'desc' : 'asc';
    } else {
      sortBy.value = sort;
      sortOrder.value = 'desc';
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedStatus.value = 'all';
    selectedDateRange.value = 'all';
    sortBy.value = 'date';
    sortOrder.value = 'desc';
  }

  // ========== Order Management ==========

  Future<void> updateOrderStatus(
    VendorOrderModel order,
    String newStatus,
  ) async {
    try {
      isUpdatingOrder.value = true;

      // Simulate API call
      await Future.delayed(Duration(milliseconds: 800));

      // Update order status
      final index = orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        orders[index] = order.copyWith(status: newStatus);
        _applyFilters();
      }

      Get.snackbar(
        'Success',
        'Order ${order.id} status updated to ${_getStatusLabel(newStatus)}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error updating order status: $e');
      Get.snackbar('Error', 'Failed to update order status');
    } finally {
      isUpdatingOrder.value = false;
    }
  }

  String _getStatusLabel(String status) {
    return statusOptions.firstWhere(
      (option) => option['value'] == status,
      orElse: () => {'label': status},
    )['label']!;
  }

  // ========== Navigation ==========

  void navigateToOrderDetails(VendorOrderModel order) {
    Get.toNamed(AppRoutes.orderDetails, arguments: order);
  }

  // ========== Helper Methods ==========

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'packed':
        return Colors.indigo;
      case 'shipped':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'returned':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.settings;
      case 'packed':
        return Icons.inventory_2;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'returned':
        return Icons.keyboard_return;
      default:
        return Icons.help_outline;
    }
  }

  // ========== Computed Properties ==========

  int get totalOrders => orders.length;
  int get pendingOrders => orders.where((o) => o.status == 'pending').length;
  int get processingOrders =>
      orders
          .where(
            (o) => ['confirmed', 'processing', 'packed'].contains(o.status),
          )
          .length;
  int get completedOrders =>
      orders.where((o) => o.status == 'delivered').length;

  double get totalRevenue => orders
      .where((o) => o.status == 'delivered')
      .fold(0.0, (sum, order) => sum + order.totalAmount);

  String get formattedTotalRevenue => '₹${totalRevenue.toStringAsFixed(2)}';

  // ========== Dummy Data ==========

  List<VendorOrderModel> _generateDummyOrders() {
    return [
      VendorOrderModel(
        id: 'ORD001',
        customerName: 'Rahul Sharma',
        customerPhone: '+91 98765 43210',
        customerEmail: 'rahul.sharma@email.com',
        customerAddress: '123 MG Road, Bangalore, Karnataka 560001',
        orderDate: DateTime.now().subtract(Duration(hours: 2)),
        status: 'pending',
        paymentMethod: 'UPI',
        paymentStatus: 'paid',
        totalAmount: 1250.00,
        deliveryFee: 50.00,
        discount: 100.00,
        items: [
          OrderItemModel(
            productId: 'P001',
            productName: 'Royal Canin Dog Food',
            quantity: 2,
            price: 600.00,
            imageUrl: '',
          ),
        ],
      ),
      VendorOrderModel(
        id: 'ORD002',
        customerName: 'Priya Patel',
        customerPhone: '+91 87654 32109',
        customerEmail: 'priya.patel@email.com',
        customerAddress: '456 Park Street, Mumbai, Maharashtra 400001',
        orderDate: DateTime.now().subtract(Duration(hours: 5)),
        status: 'confirmed',
        paymentMethod: 'Card',
        paymentStatus: 'paid',
        totalAmount: 850.00,
        deliveryFee: 40.00,
        discount: 50.00,
        items: [
          OrderItemModel(
            productId: 'P002',
            productName: 'Cat Treats Premium',
            quantity: 3,
            price: 280.00,
            imageUrl: '',
          ),
        ],
      ),
      VendorOrderModel(
        id: 'ORD003',
        customerName: 'Amit Kumar',
        customerPhone: '+91 76543 21098',
        customerEmail: 'amit.kumar@email.com',
        customerAddress: '789 Civil Lines, Delhi 110001',
        orderDate: DateTime.now().subtract(Duration(days: 1)),
        status: 'processing',
        paymentMethod: 'COD',
        paymentStatus: 'pending',
        totalAmount: 2100.00,
        deliveryFee: 80.00,
        discount: 200.00,
        items: [
          OrderItemModel(
            productId: 'P003',
            productName: 'Dog Toy Set',
            quantity: 1,
            price: 450.00,
            imageUrl: '',
          ),
          OrderItemModel(
            productId: 'P004',
            productName: 'Pet Shampoo',
            quantity: 2,
            price: 320.00,
            imageUrl: '',
          ),
        ],
      ),
      VendorOrderModel(
        id: 'ORD004',
        customerName: 'Sneha Reddy',
        customerPhone: '+91 65432 10987',
        customerEmail: 'sneha.reddy@email.com',
        customerAddress: '321 Jubilee Hills, Hyderabad, Telangana 500001',
        orderDate: DateTime.now().subtract(Duration(days: 2)),
        status: 'shipped',
        paymentMethod: 'UPI',
        paymentStatus: 'paid',
        totalAmount: 1800.00,
        deliveryFee: 60.00,
        discount: 150.00,
        items: [
          OrderItemModel(
            productId: 'P005',
            productName: 'Premium Cat Food',
            quantity: 4,
            price: 400.00,
            imageUrl: '',
          ),
        ],
      ),
      VendorOrderModel(
        id: 'ORD005',
        customerName: 'Vikash Singh',
        customerPhone: '+91 54321 09876',
        customerEmail: 'vikash.singh@email.com',
        customerAddress: '654 Sector 15, Noida, UP 201301',
        orderDate: DateTime.now().subtract(Duration(days: 3)),
        status: 'delivered',
        paymentMethod: 'Card',
        paymentStatus: 'paid',
        totalAmount: 950.00,
        deliveryFee: 45.00,
        discount: 75.00,
        items: [
          OrderItemModel(
            productId: 'P006',
            productName: 'Bird Food Mix',
            quantity: 2,
            price: 240.00,
            imageUrl: '',
          ),
        ],
      ),
    ];
  }
}

// ========== Order Models ==========

class VendorOrderModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String customerAddress;
  final DateTime orderDate;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double totalAmount;
  final double deliveryFee;
  final double discount;
  final List<OrderItemModel> items;

  VendorOrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.customerAddress,
    required this.orderDate,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalAmount,
    required this.deliveryFee,
    required this.discount,
    required this.items,
  });

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  String get formattedOrderDate {
    final now = DateTime.now();
    final difference = now.difference(orderDate);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hr ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${orderDate.day}/${orderDate.month}/${orderDate.year}';
    }
  }

  String get formattedTotalAmount => '₹${totalAmount.toStringAsFixed(2)}';

  VendorOrderModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
    DateTime? orderDate,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    double? totalAmount,
    double? deliveryFee,
    double? discount,
    List<OrderItemModel>? items,
  }) {
    return VendorOrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      customerAddress: customerAddress ?? this.customerAddress,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      items: items ?? this.items,
    );
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String imageUrl;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  double get totalPrice => price * quantity;
  String get formattedPrice => '₹${price.toStringAsFixed(2)}';
  String get formattedTotalPrice => '₹${totalPrice.toStringAsFixed(2)}';
}

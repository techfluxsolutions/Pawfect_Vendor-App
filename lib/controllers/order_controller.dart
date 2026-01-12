import 'dart:async';
import 'dart:developer';
import '../libs.dart';

class OrderController extends GetxController {
  final OrdersService _ordersService = OrdersService();

  // Loading States
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var isLoadingMore = false.obs;
  var isUpdatingOrder = false.obs;

  // API Data
  var ordersResponse = Rxn<OrdersResponseModel>();
  var apiOrders = <OrdersApiModel>[].obs;

  // Legacy Data (for UI compatibility)
  var orders = <VendorOrderModel>[].obs;
  var filteredOrders = <VendorOrderModel>[].obs;

  // Filters
  var searchQuery = ''.obs;
  var selectedStatus = 'all'.obs;
  var selectedPaymentStatus = 'all'.obs;
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
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD ORDERS FROM API
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      currentPage.value = 1;
      hasMoreData.value = true;

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
        limit: itemsPerPage,
      );

      if (response.success && response.data != null) {
        final ordersData = response.data!;

        // Store API response
        ordersResponse.value = ordersData;
        apiOrders.value = ordersData.orders;

        // Convert to VendorOrderModel for UI compatibility
        _convertToVendorOrderModel();

        log('✅ Orders loaded successfully: ${ordersData.orders.length} orders');

        // Check if we have more data
        hasMoreData.value = ordersData.orders.length >= itemsPerPage;
      } else {
        log('⚠️ Orders API failed: ${response.message}');
        // Load dummy data as fallback
        orders.value = _generateDummyOrders();
        _showInfoSnackbar('Using sample order data');
      }

      _applyFilters();
    } catch (e) {
      log('❌ Error loading orders: $e');
      // Load dummy data as fallback
      orders.value = _generateDummyOrders();
      _showErrorSnackbar('Failed to load orders');
    } finally {
      isLoading.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONVERT API DATA TO VENDOR ORDER MODEL
  // ══════════════════════════════════════════════════════════════════════════
  void _convertToVendorOrderModel() {
    final vendorOrders =
        apiOrders.map((apiOrder) {
          return VendorOrderModel(
            id: apiOrder.orderId,
            customerName: apiOrder.clientName,
            customerPhone: apiOrder.phoneNumber,
            customerEmail: '', // Not provided in API
            customerAddress: '', // Not provided in API
            orderDate:
                apiOrder.estimatedDate, // Using estimated date as order date
            status: apiOrder.status.toLowerCase(),
            paymentMethod: apiOrder.paymentStatus,
            paymentStatus: apiOrder.paymentStatus.toLowerCase(),
            totalAmount: apiOrder.totalPrice,
            deliveryFee: 0.0, // Not provided in API
            discount: 0.0, // Not provided in API
            items: [
              OrderItemModel(
                productId: apiOrder.orderId, // Using order ID as product ID
                productName: apiOrder.productName,
                quantity: apiOrder.quantity,
                price: apiOrder.price,
                imageUrl: apiOrder.productImage,
              ),
            ],
          );
        }).toList();

    orders.value = vendorOrders;
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
        limit: itemsPerPage,
      );

      if (response.success && response.data != null) {
        final newOrders = response.data!.orders;
        apiOrders.addAll(newOrders);
        _convertToVendorOrderModel();
        _applyFilters();

        hasMoreData.value = newOrders.length >= itemsPerPage;
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
  // FILTERING & SORTING
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

  void setDateRangeFilter(String range) {
    selectedDateRange.value = range;
    _reloadWithFilters();
  }

  void setSortBy(String sort) {
    if (sortBy.value == sort) {
      // Toggle sort order if same field
      sortOrder.value = sortOrder.value == 'asc' ? 'desc' : 'asc';
    } else {
      sortBy.value = sort;
      sortOrder.value = 'desc';
    }
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
    loadOrders();
  }

  void _applyFilters() {
    // Since we're using API filtering, this method now just applies local sorting if needed
    // Most filtering is done server-side via API parameters
    filteredOrders.value = List.from(orders);
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

  // ══════════════════════════════════════════════════════════════════════════
  // ORDER MANAGEMENT
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> updateOrderStatus(
    VendorOrderModel order,
    String newStatus,
  ) async {
    try {
      isUpdatingOrder.value = true;

      final response = await _ordersService.updateOrderStatus(
        orderId: order.id,
        status: newStatus,
      );

      if (response.success) {
        // Update local data
        final index = orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          orders[index] = order.copyWith(status: newStatus);
          _applyFilters();
        }

        _showSuccessSnackbar(
          'Order ${order.id} status updated to ${_getStatusLabel(newStatus)}',
        );
      } else {
        _showErrorSnackbar(response.message ?? 'Failed to update order status');
      }
    } catch (e) {
      log('❌ Error updating order status: $e');
      _showErrorSnackbar('Failed to update order status');
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

  // ══════════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ══════════════════════════════════════════════════════════════════════════
  void navigateToOrderDetails(VendorOrderModel order) {
    Get.toNamed(AppRoutes.orderDetails, arguments: order);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'processing':
        return Colors.blue;
      case 'packed':
        return Colors.purple;
      case 'shipped':
        return Colors.teal;
      case 'delivered':
      case 'completed':
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
    switch (status.toLowerCase()) {
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
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'returned':
        return Icons.keyboard_return;
      default:
        return Icons.help_outline;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // COMPUTED PROPERTIES
  // ══════════════════════════════════════════════════════════════════════════
  int get totalOrders =>
      ordersResponse.value?.summary.totalOrders ?? orders.length;
  int get pendingOrders =>
      ordersResponse.value?.summary.statusCounts['Pending'] ??
      orders.where((o) => o.status == 'pending').length;
  int get processingOrders =>
      ordersResponse.value?.summary.statusCounts['Processing'] ??
      orders
          .where(
            (o) => ['confirmed', 'processing', 'packed'].contains(o.status),
          )
          .length;
  int get completedOrders =>
      ordersResponse.value?.summary.statusCounts['Completed'] ??
      orders.where((o) => o.status == 'delivered').length;

  double get totalRevenue =>
      ordersResponse.value?.summary.totalRevenue ??
      orders
          .where((o) => o.status == 'delivered')
          .fold(0.0, (sum, order) => sum + order.totalAmount);

  String get formattedTotalRevenue => '₹${totalRevenue.toStringAsFixed(2)}';

  // ══════════════════════════════════════════════════════════════════════════
  // SNACKBAR HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void _showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

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

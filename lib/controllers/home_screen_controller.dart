import 'dart:developer';

import '../libs.dart';
import '../services/home_service.dart';

class HomeScreenController extends GetxController {
  final HomeService _homeService = HomeService();

  // Store Info
  var storeName = 'Pawfect Store'.obs;
  var isStoreActive = true.obs;
  var notificationCount = 5.obs;

  // Loading State
  var isLoading = false.obs;

  // Stats
  var monthlySales = 0.0.obs;
  var weeklySales = 0.0.obs;
  var dailySales = 0.0.obs;
  var totalOrders = 0.obs;
  var totalProducts = 0.obs;
  var outOfStockProducts = 0.obs;

  // Alerts
  var alerts = <AlertModel>[].obs;

  // Recent Orders
  var recentOrders = <OrderModel>[].obs;

  // Top Selling Products
  var topSellingProducts = <TopSellingProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // ========== Load Dashboard Data ==========

  Future<void> loadDashboardData() async {
    isLoading.value = true;

    try {
      await Future.wait([
        fetchStoreInfo(),
        fetchStats(),
        fetchAlerts(),
        fetchRecentOrders(),
        fetchTopSellingProducts(),
      ]);
    } catch (e) {
      log('Error loading dashboard data: $e');
      Get.snackbar(
        'Error',
        'Failed to load dashboard data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== Refresh Data ==========

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // ========== Fetch Store Info ==========

  Future<void> fetchStoreInfo() async {
    try {
      final response = await _homeService.getStoreInfo();

      if (response.success && response.data != null) {
        final store = response.data!;
        storeName.value = store.name;
        isStoreActive.value = store.isActive;
        log('✅ Store info loaded: ${store.name}');
      } else {
        // Use dummy data on error
        storeName.value = 'Pawfect Pet Store';
        isStoreActive.value = true;
        log('⚠️ Using dummy store data');
      }

      // Always set notification count (could be from a separate API)
      notificationCount.value = 5;
    } catch (e) {
      log('❌ Error fetching store info: $e');
      // Use default values
      storeName.value = 'Pawfect Pet Store';
      isStoreActive.value = true;
    }
  }

  // ========== Fetch Stats ==========

  Future<void> fetchStats() async {
    try {
      final response = await _homeService.getDashboardStats();

      if (response.success && response.data != null) {
        final stats = response.data!;
        monthlySales.value = stats.monthlySales;
        weeklySales.value = stats.weeklySales;
        dailySales.value = stats.dailySales;
        totalOrders.value = stats.totalOrders;
        totalProducts.value = stats.totalProducts;
        outOfStockProducts.value = stats.outOfStockProducts;
        log('✅ Stats loaded successfully');
      } else {
        // Use dummy data on error
        _loadDummyStats();
        log('⚠️ Using dummy stats data');
      }
    } catch (e) {
      log('❌ Error fetching stats: $e');
      _loadDummyStats();
    }
  }

  void _loadDummyStats() {
    monthlySales.value = 45680.0;
    weeklySales.value = 12450.0;
    dailySales.value = 2340.0;
    totalOrders.value = 234;
    totalProducts.value = 48;
    outOfStockProducts.value = 5;
  }

  // ========== Fetch Alerts ==========

  Future<void> fetchAlerts() async {
    try {
      final response = await _homeService.getAlerts();

      if (response.success && response.data != null) {
        alerts.value = response.data!;
        log('✅ Alerts loaded: ${alerts.length} alerts');
      } else {
        // Use dummy data on error
        _loadDummyAlerts();
        log('⚠️ Using dummy alerts data');
      }
    } catch (e) {
      log('❌ Error fetching alerts: $e');
      _loadDummyAlerts();
    }
  }

  void _loadDummyAlerts() {
    alerts.value = [
      AlertModel(
        type: AlertType.lowStock,
        title: 'Low Stock Alert',
        message: '5 products are running low on stock',
        count: 5,
      ),
      AlertModel(
        type: AlertType.pendingApproval,
        title: 'Pending Approval',
        message: '3 products awaiting approval',
        count: 3,
      ),
      AlertModel(
        type: AlertType.newOrder,
        title: 'New Orders',
        message: '2 new orders received',
        count: 2,
      ),
    ];
  }

  // ========== Fetch Recent Orders ==========

  Future<void> fetchRecentOrders() async {
    try {
      final response = await _homeService.getRecentOrders(limit: 5);

      if (response.success && response.data != null) {
        recentOrders.value = response.data!;
        log('✅ Recent orders loaded: ${recentOrders.length} orders');
      } else {
        // Use dummy data on error
        _loadDummyOrders();
        log('⚠️ Using dummy orders data');
      }
    } catch (e) {
      log('❌ Error fetching recent orders: $e');
      _loadDummyOrders();
    }
  }

  void _loadDummyOrders() {
    recentOrders.value = [
      OrderModel(
        id: '1234',
        customerName: 'John Doe',
        amount: 1250.0,
        status: 'Pending',
        date: DateTime.now(),
      ),
      OrderModel(
        id: '1235',
        customerName: 'Jane Smith',
        amount: 890.0,
        status: 'Processing',
        date: DateTime.now().subtract(Duration(hours: 2)),
      ),
      OrderModel(
        id: '1236',
        customerName: 'Mike Johnson',
        amount: 2340.0,
        status: 'Delivered',
        date: DateTime.now().subtract(Duration(hours: 5)),
      ),
      OrderModel(
        id: '1237',
        customerName: 'Sarah Wilson',
        amount: 670.0,
        status: 'Pending',
        date: DateTime.now().subtract(Duration(hours: 8)),
      ),
      OrderModel(
        id: '1238',
        customerName: 'Tom Brown',
        amount: 1540.0,
        status: 'Processing',
        date: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  }

  // ========== Fetch Top Selling Products ==========

  Future<void> fetchTopSellingProducts() async {
    try {
      final response = await _homeService.getTopSellingProducts(
        limit: 3,
        period: 'month',
      );

      if (response.success && response.data != null) {
        topSellingProducts.value = response.data!;
        log(
          '✅ Top selling products loaded: ${topSellingProducts.length} products',
        );
      } else {
        // Use dummy data on error
        _loadDummyProducts();
        log('⚠️ Using dummy products data');
      }
    } catch (e) {
      log('❌ Error fetching top selling products: $e');
      _loadDummyProducts();
    }
  }

  void _loadDummyProducts() {
    topSellingProducts.value = [
      TopSellingProductModel(
        id: 'p1',
        name: 'Premium Dog Food 5kg',
        imageUrl: '', // Using empty string to avoid invalid URI
        price: 1299.0,
        soldCount: 145,
      ),
      TopSellingProductModel(
        id: 'p2',
        name: 'Cat Food Premium',
        imageUrl: '', // Using empty string to avoid invalid URI
        price: 899.0,
        soldCount: 132,
      ),
      TopSellingProductModel(
        id: 'p3',
        name: 'Dog Treats Pack',
        imageUrl: '', // Using empty string to avoid invalid URI
        price: 349.0,
        soldCount: 98,
      ),
    ];
  }

  // ========== Toggle Store Status ==========

  Future<void> toggleStoreStatus() async {
    final newStatus = !isStoreActive.value;

    try {
      // Optimistically update UI
      isStoreActive.value = newStatus;

      final response = await _homeService.updateStoreStatus(newStatus);

      if (response.success) {
        Get.snackbar(
          'Store Status',
          'Store is now ${newStatus ? "Active" : "Inactive"}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: newStatus ? Colors.green : Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        // Revert on failure
        isStoreActive.value = !newStatus;
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to update store status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Revert on error
      isStoreActive.value = !newStatus;
      log('❌ Error toggling store status: $e');
      Get.snackbar(
        'Error',
        'Failed to update store status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========== Navigation Methods ==========

  void openNotifications() {
    Get.toNamed(AppRoutes.notifications);
  }

  void navigateToAddProduct() {
    Get.toNamed(AppRoutes.addProduct)?.then((_) => refreshData());
  }

  void navigateToOrders() {
    Get.toNamed(AppRoutes.orders);
  }

  void navigateToInventory() {
    Get.toNamed(AppRoutes.inventory);
  }

  void navigateToAnalytics() {
    Get.toNamed(AppRoutes.analytics);
  }

  void navigateToOrderDetails(OrderModel order) {
    Get.snackbar(
      'Order Details',
      'Order #${order.id} - Coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void navigateToProductDetails(TopSellingProductModel product) {
    // If you have product details route
    Get.snackbar(
      'Product Details',
      '${product.name} - Coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
}

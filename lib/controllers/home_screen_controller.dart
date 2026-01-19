import 'dart:developer';
import '../libs.dart';

class HomeScreenController extends GetxController {
  final HomeScreenService _homeService = HomeScreenService();

  // Store Info
  var storeName = 'Pawfect Store'.obs;
  var isStoreActive = true.obs;
  var notificationCount = 5.obs;

  // Loading State
  var isLoading = false.obs;

  // Dashboard Stats - Initialize with 0 values
  var totalProducts = 0.obs;
  var outOfStockProducts = 0.obs;
  var totalOrders = 0.obs;
  var totalSales = 0.0.obs;
  var dailySales = 0.0.obs;
  var weeklySales = 0.0.obs;
  var monthlySales = 0.0.obs;

  // Alerts
  var alerts = <AlertModel>[].obs;

  // Recent Orders
  var recentOrders = <OrderModel>[].obs;
  var recentOrdersFromApi = <RecentOrderModel>[].obs;

  // Top Selling Products
  var topSellingProducts = <TopSellingProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStoreInfo(); // ✅ Load store info from KYC API
    loadDashboardData();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD STORE INFO FROM KYC API
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> loadStoreInfo() async {
    try {
      // log('📊 Loading store info from KYC API...');

      final response = await ApiClient().get(ApiUrls.kycStatus);

      if (response.success && response.data != null) {
        final vendor = response.data['vendor'];

        if (vendor != null) {
          // ✅ Update store name from API response
          storeName.value = vendor['storeName'] ?? 'Pawfect Store';

          log('✅ Store info loaded: ${storeName.value}');
        } else {
          log('⚠️ No vendor data in KYC response');
        }
      } else {
        log('⚠️ KYC API failed, using default store name: ${response.message}');
      }
    } catch (e) {
      log('❌ Error loading store info: $e');
      // Keep default store name on error
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD DASHBOARD DATA
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> loadDashboardData() async {
    isLoading.value = true;

    try {
      await Future.wait([
        fetchDashboardStats(),
        fetchRecentOrders(),
        fetchTopSellingProducts(),
        fetchDummyData(), // Load other dummy data while backend is in development
      ]);
    } catch (e) {
      log('❌ Error loading dashboard data: $e');
      _showErrorSnackbar('Failed to load dashboard data');
    } finally {
      isLoading.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REFRESH DATA
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH DASHBOARD STATS FROM API
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> fetchDashboardStats() async {
    try {
      log('📊 Fetching dashboard stats from API...');

      final response = await _homeService.getDashboardStats();

      if (response.success && response.data != null) {
        final stats = response.data!;

        // Update stats with API data
        totalProducts.value = stats.totalProducts;
        outOfStockProducts.value = stats.outOfStockProducts;
        totalOrders.value = stats.totalOrders;
        totalSales.value = stats.totalSales;
        dailySales.value = stats.dailySales;
        weeklySales.value = stats.weeklySales;
        monthlySales.value = stats.monthlySales;

        log('✅ Dashboard stats loaded successfully: $stats');

        // Show success message if values are not all zero
        if (stats.totalProducts > 0 ||
            stats.totalOrders > 0 ||
            stats.totalSales > 0) {
          // _showSuccessSnackbar('Dashboard stats updated');
        }
      } else {
        log('⚠️ Dashboard stats API failed: ${response.message}');
        // Keep current values (which are 0 initially)
        // _showInfoSnackbar('Using default dashboard values');
      }
    } catch (e) {
      log('❌ Error fetching dashboard stats: $e');
      // Keep current values (which are 0 initially)
      // _showInfoSnackbar('Dashboard stats will update when available');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH RECENT ORDERS FROM API
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> fetchRecentOrders() async {
    try {
      log('📦 Fetching recent orders from API...');

      final response = await _homeService.getRecentOrders(limit: 5);

      if (response.success && response.data != null) {
        final apiOrders = response.data!;

        // Store API orders
        recentOrdersFromApi.value = apiOrders;

        // Convert to OrderModel for existing UI compatibility
        recentOrders.value =
            apiOrders.map((order) => order.toOrderModel()).toList();

        log('✅ Recent orders loaded successfully: ${apiOrders.length} orders');

        // Show success message if we have orders
        if (apiOrders.isNotEmpty) {
          // _showSuccessSnackbar('Recent orders updated');
        }
      } else {
        log('⚠️ Recent orders API failed: ${response.message}');
        // Keep current values or load dummy data
        _loadDummyOrders();
        _showInfoSnackbar('Using sample order data');
      }
    } catch (e) {
      log('❌ Error fetching recent orders: $e');
      // Keep current values or load dummy data
      _loadDummyOrders();
      _showInfoSnackbar('Recent orders will update when available');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD DUMMY ORDERS (Fallback)
  // ══════════════════════════════════════════════════════════════════════════
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
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH TOP SELLING PRODUCTS FROM API
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> fetchTopSellingProducts() async {
    try {
      log('🏆 Fetching top selling products from API...');

      final response = await _homeService.getTopSellingProducts(limit: 3);

      if (response.success && response.data != null) {
        final products = response.data!;

        // Update top selling products with API data
        topSellingProducts.value = products;

        log(
          '✅ Top selling products loaded successfully: ${products.length} products',
        );

        // Show success message if we have products
        if (products.isNotEmpty) {
          // _showSuccessSnackbar('Top selling products updated');
        }
      } else {
        log('⚠️ Top selling products API failed: ${response.message}');
        // Keep current values or load dummy data
        _loadDummyProducts();
        _showInfoSnackbar('Using sample product data');
      }
    } catch (e) {
      log('❌ Error fetching top selling products: $e');
      // Keep current values or load dummy data
      _loadDummyProducts();
      _showInfoSnackbar('Top selling products will update when available');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD DUMMY PRODUCTS (Fallback)
  // ══════════════════════════════════════════════════════════════════════════
  void _loadDummyProducts() {
    topSellingProducts.value = [
      TopSellingProductModel(
        id: 'p1',
        name: 'Premium Dog Food 5kg',
        images: [], // Using empty list to avoid invalid URI
        price: 1299.0,
        totalSold: 145,
        totalRevenue: 188355.0,
        category: 'Dog',
      ),
      TopSellingProductModel(
        id: 'p2',
        name: 'Cat Food Premium',
        images: [], // Using empty list to avoid invalid URI
        price: 899.0,
        totalSold: 132,
        totalRevenue: 118668.0,
        category: 'Cat',
      ),
      TopSellingProductModel(
        id: 'p3',
        name: 'Dog Treats Pack',
        images: [], // Using empty list to avoid invalid URI
        price: 349.0,
        totalSold: 98,
        totalRevenue: 34202.0,
        category: 'Dog',
      ),
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH DUMMY DATA (While backend is in development)
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> fetchDummyData() async {
    try {
      // Store info - will be loaded from KYC API
      // storeName.value = 'Pawfect Pet Store'; // ✅ Removed - now loaded from API
      isStoreActive.value = true;
      notificationCount.value = 5;

      // Dummy alerts
      alerts.value = [
        AlertModel(
          type: AlertType.lowStock,
          title: 'Low Stock Alert',
          message: 'Some products are running low on stock',
          count: outOfStockProducts.value,
        ),
        AlertModel(
          type: AlertType.newOrder,
          title: 'New Orders',
          message: 'You have new orders to process',
          count: 2,
        ),
      ];

      log('✅ Dummy data loaded successfully');
    } catch (e) {
      log('❌ Error loading dummy data: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TOGGLE STORE STATUS
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> toggleStoreStatus() async {
    final newStatus = !isStoreActive.value;

    try {
      // Optimistically update UI
      isStoreActive.value = newStatus;

      // TODO: Implement store status API when backend is ready
      // For now, just show success message
      _showSuccessSnackbar('Store is now ${newStatus ? "Active" : "Inactive"}');

      log('✅ Store status toggled to: ${newStatus ? "Active" : "Inactive"}');
    } catch (e) {
      // Revert on error
      isStoreActive.value = !newStatus;
      log('❌ Error toggling store status: $e');
      _showErrorSnackbar('Failed to update store status');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NAVIGATION METHODS
  // ══════════════════════════════════════════════════════════════════════════
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
    Get.snackbar(
      'Product Details',
      '${product.name} - Coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
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
}

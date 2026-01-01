import 'dart:developer';
import '../libs.dart';

class InventoryController extends GetxController {
  // Loading States
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var isUpdatingStock = false.obs;
  var isLoadingMore = false.obs;

  // Inventory Data
  var inventoryItems = <InventoryItem>[].obs;
  var filteredItems = <InventoryItem>[].obs;

  // Search & Filter
  var searchQuery = ''.obs;
  var selectedCategory = 'all'.obs;
  var selectedStockStatus = 'all'.obs;
  var sortBy = 'name'.obs;
  var sortOrder = 'asc'.obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  final int pageSize = 20;

  // Summary Data
  var totalProducts = 0.obs;
  var inStockProducts = 0.obs;
  var lowStockProducts = 0.obs;
  var outOfStockProducts = 0.obs;
  var totalStockValue = 0.0.obs;

  // Filter Options
  final List<Map<String, String>> categoryOptions = [
    {'value': 'all', 'label': 'All Categories'},
    {'value': 'dog_food', 'label': 'Dog Food'},
    {'value': 'cat_food', 'label': 'Cat Food'},
    {'value': 'toys', 'label': 'Toys'},
    {'value': 'accessories', 'label': 'Accessories'},
    {'value': 'healthcare', 'label': 'Healthcare'},
    {'value': 'treats', 'label': 'Treats'},
  ];

  final List<Map<String, String>> stockStatusOptions = [
    {'value': 'all', 'label': 'All Stock Status'},
    {'value': 'in_stock', 'label': 'In Stock'},
    {'value': 'low_stock', 'label': 'Low Stock'},
    {'value': 'out_of_stock', 'label': 'Out of Stock'},
  ];

  final List<Map<String, String>> sortOptions = [
    {'value': 'name', 'label': 'Product Name'},
    {'value': 'stock', 'label': 'Stock Quantity'},
    {'value': 'price', 'label': 'Price'},
    {'value': 'category', 'label': 'Category'},
    {'value': 'updated', 'label': 'Last Updated'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadInventory();
  }

  // ========== Load Inventory ==========

  Future<void> loadInventory({bool isRefresh = false}) async {
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

      final newItems = _generateDummyInventory();

      if (isRefresh) {
        inventoryItems.value = newItems;
      } else {
        inventoryItems.addAll(newItems);
      }

      _calculateSummary();
      applyFilters();

      log('✅ Inventory loaded successfully');
    } catch (e) {
      log('❌ Error loading inventory: $e');
      Get.snackbar(
        'Error',
        'Failed to load inventory',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  List<InventoryItem> _generateDummyInventory() {
    return [
      InventoryItem(
        id: 'inv_001',
        productId: 'prod_001',
        name: 'Premium Dog Food 5kg',
        category: 'Dog Food',
        sku: 'PDF-5KG-001',
        currentStock: 25,
        minStockLevel: 10,
        maxStockLevel: 100,
        price: 1299.0,
        costPrice: 950.0,
        lastUpdated: DateTime.now().subtract(Duration(hours: 2)),
        supplier: 'Pet Nutrition Co.',
        location: 'Warehouse A - Shelf 12',
        imageUrl: '',
      ),
      InventoryItem(
        id: 'inv_002',
        productId: 'prod_002',
        name: 'Cat Food Premium 2kg',
        category: 'Cat Food',
        sku: 'CFP-2KG-002',
        currentStock: 8,
        minStockLevel: 15,
        maxStockLevel: 80,
        price: 899.0,
        costPrice: 650.0,
        lastUpdated: DateTime.now().subtract(Duration(hours: 5)),
        supplier: 'Feline Foods Ltd.',
        location: 'Warehouse A - Shelf 8',
        imageUrl: '',
      ),
      InventoryItem(
        id: 'inv_003',
        productId: 'prod_003',
        name: 'Interactive Dog Toy',
        category: 'Toys',
        sku: 'IDT-TOY-003',
        currentStock: 0,
        minStockLevel: 5,
        maxStockLevel: 50,
        price: 549.0,
        costPrice: 350.0,
        lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        supplier: 'Toy Masters Inc.',
        location: 'Warehouse B - Shelf 3',
        imageUrl: '',
      ),
      InventoryItem(
        id: 'inv_004',
        productId: 'prod_004',
        name: 'Dog Leash Premium',
        category: 'Accessories',
        sku: 'DLP-ACC-004',
        currentStock: 45,
        minStockLevel: 20,
        maxStockLevel: 100,
        price: 799.0,
        costPrice: 500.0,
        lastUpdated: DateTime.now().subtract(Duration(hours: 8)),
        supplier: 'Pet Accessories Pro',
        location: 'Warehouse A - Shelf 15',
        imageUrl: '',
      ),
      InventoryItem(
        id: 'inv_005',
        productId: 'prod_005',
        name: 'Cat Treats Variety Pack',
        category: 'Treats',
        sku: 'CTV-TRT-005',
        currentStock: 12,
        minStockLevel: 25,
        maxStockLevel: 75,
        price: 349.0,
        costPrice: 200.0,
        lastUpdated: DateTime.now().subtract(Duration(hours: 12)),
        supplier: 'Treat Factory',
        location: 'Warehouse B - Shelf 7',
        imageUrl: '',
      ),
      InventoryItem(
        id: 'inv_006',
        productId: 'prod_006',
        name: 'Pet Vitamins & Supplements',
        category: 'Healthcare',
        sku: 'PVS-HLT-006',
        currentStock: 18,
        minStockLevel: 10,
        maxStockLevel: 60,
        price: 1199.0,
        costPrice: 800.0,
        lastUpdated: DateTime.now().subtract(Duration(days: 2)),
        supplier: 'Health Pet Solutions',
        location: 'Warehouse A - Shelf 5',
        imageUrl: '',
      ),
    ];
  }

  void _calculateSummary() {
    totalProducts.value = inventoryItems.length;
    inStockProducts.value =
        inventoryItems.where((item) => item.isInStock).length;
    lowStockProducts.value =
        inventoryItems.where((item) => item.isLowStock).length;
    outOfStockProducts.value =
        inventoryItems.where((item) => item.isOutOfStock).length;

    totalStockValue.value = inventoryItems.fold(
      0.0,
      (sum, item) => sum + (item.currentStock * item.costPrice),
    );
  }

  // ========== Load More ==========

  Future<void> loadMoreInventory() async {
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
        final newItems = _generateDummyInventory();
        inventoryItems.addAll(newItems);
        applyFilters();
      }
    } catch (e) {
      log('❌ Error loading more inventory: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ========== Search & Filter ==========

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  void setStockStatus(String status) {
    selectedStockStatus.value = status;
    applyFilters();
  }

  void setSortBy(String sort) {
    if (sortBy.value == sort) {
      // Toggle sort order if same field
      sortOrder.value = sortOrder.value == 'asc' ? 'desc' : 'asc';
    } else {
      sortBy.value = sort;
      sortOrder.value = 'asc';
    }
    applyFilters();
  }

  void applyFilters() {
    List<InventoryItem> result = List.from(inventoryItems);

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      result =
          result.where((item) {
            final query = searchQuery.value.toLowerCase();
            return item.name.toLowerCase().contains(query) ||
                item.sku.toLowerCase().contains(query) ||
                item.category.toLowerCase().contains(query) ||
                item.supplier.toLowerCase().contains(query);
          }).toList();
    }

    // Category filter
    if (selectedCategory.value != 'all') {
      final categoryLabel =
          categoryOptions.firstWhere(
            (cat) => cat['value'] == selectedCategory.value,
            orElse: () => {'label': ''},
          )['label']!;
      result = result.where((item) => item.category == categoryLabel).toList();
    }

    // Stock status filter
    if (selectedStockStatus.value != 'all') {
      switch (selectedStockStatus.value) {
        case 'in_stock':
          result = result.where((item) => item.isInStock).toList();
          break;
        case 'low_stock':
          result = result.where((item) => item.isLowStock).toList();
          break;
        case 'out_of_stock':
          result = result.where((item) => item.isOutOfStock).toList();
          break;
      }
    }

    // Sort
    result.sort((a, b) {
      int comparison = 0;
      switch (sortBy.value) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'stock':
          comparison = a.currentStock.compareTo(b.currentStock);
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'category':
          comparison = a.category.compareTo(b.category);
          break;
        case 'updated':
          comparison = a.lastUpdated.compareTo(b.lastUpdated);
          break;
      }
      return sortOrder.value == 'asc' ? comparison : -comparison;
    });

    filteredItems.value = result;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = 'all';
    selectedStockStatus.value = 'all';
    sortBy.value = 'name';
    sortOrder.value = 'asc';
    applyFilters();
  }

  // ========== Stock Management ==========

  Future<void> updateStock(
    InventoryItem item,
    int newStock,
    String reason,
  ) async {
    isUpdatingStock.value = true;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 800));

      // Update local data
      final index = inventoryItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        inventoryItems[index] = item.copyWith(
          currentStock: newStock,
          lastUpdated: DateTime.now(),
        );

        // Add stock movement record
        _addStockMovement(item, newStock - item.currentStock, reason);

        applyFilters();
        _calculateSummary();
      }

      Get.snackbar(
        'Stock Updated',
        'Stock updated successfully for ${item.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        'Failed to update stock: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdatingStock.value = false;
    }
  }

  void _addStockMovement(InventoryItem item, int quantity, String reason) {
    // TODO: Implement stock movement tracking
    log(
      '📦 Stock movement: ${item.name} ${quantity > 0 ? '+' : ''}$quantity - $reason',
    );
  }

  // ========== Bulk Actions ==========

  Future<void> bulkUpdateLowStock() async {
    final lowStockItems =
        inventoryItems.where((item) => item.isLowStock).toList();

    if (lowStockItems.isEmpty) {
      Get.snackbar(
        'No Action Needed',
        'No low stock items found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Bulk Restock'),
        content: Text(
          'Restock ${lowStockItems.length} low stock items to their maximum levels?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Restock'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      isUpdatingStock.value = true;

      try {
        // TODO: Replace with actual API call
        await Future.delayed(Duration(seconds: 2));

        for (final item in lowStockItems) {
          final index = inventoryItems.indexWhere((i) => i.id == item.id);
          if (index != -1) {
            inventoryItems[index] = item.copyWith(
              currentStock: item.maxStockLevel,
              lastUpdated: DateTime.now(),
            );
          }
        }

        applyFilters();
        _calculateSummary();

        Get.snackbar(
          'Bulk Restock Complete',
          '${lowStockItems.length} items restocked successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } catch (e) {
        Get.snackbar(
          'Bulk Restock Failed',
          'Failed to restock items: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isUpdatingStock.value = false;
      }
    }
  }

  // ========== Export ==========

  Future<void> exportInventory(String format) async {
    try {
      // TODO: Implement actual export functionality
      await Future.delayed(Duration(seconds: 2));

      Get.snackbar(
        'Export Complete',
        'Inventory exported as $format',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        'Failed to export inventory: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========== Navigation ==========

  void navigateToProductDetails(InventoryItem item) {
    Get.toNamed(
      AppRoutes.productDetails,
      arguments: {'productId': item.productId},
    );
  }

  void navigateToAddProduct() {
    Get.toNamed(AppRoutes.addProduct)?.then((_) => refreshInventory());
  }

  // ========== Refresh ==========

  Future<void> refreshInventory() async {
    await loadInventory(isRefresh: true);
  }

  // ========== Getters ==========

  String get formattedTotalStockValue =>
      '₹${totalStockValue.value.toStringAsFixed(0)}';

  String get selectedCategoryLabel {
    return categoryOptions.firstWhere(
      (option) => option['value'] == selectedCategory.value,
      orElse: () => {'label': 'All Categories'},
    )['label']!;
  }

  String get selectedStockStatusLabel {
    return stockStatusOptions.firstWhere(
      (option) => option['value'] == selectedStockStatus.value,
      orElse: () => {'label': 'All Stock Status'},
    )['label']!;
  }

  String get selectedSortLabel {
    return sortOptions.firstWhere(
      (option) => option['value'] == sortBy.value,
      orElse: () => {'label': 'Product Name'},
    )['label']!;
  }
}

// ========== Inventory Models ==========

class InventoryItem {
  final String id;
  final String productId;
  final String name;
  final String category;
  final String sku;
  final int currentStock;
  final int minStockLevel;
  final int maxStockLevel;
  final double price;
  final double costPrice;
  final DateTime lastUpdated;
  final String supplier;
  final String location;
  final String imageUrl;

  InventoryItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.category,
    required this.sku,
    required this.currentStock,
    required this.minStockLevel,
    required this.maxStockLevel,
    required this.price,
    required this.costPrice,
    required this.lastUpdated,
    required this.supplier,
    required this.location,
    required this.imageUrl,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      sku: json['sku'] ?? '',
      currentStock: json['currentStock'] ?? 0,
      minStockLevel: json['minStockLevel'] ?? 0,
      maxStockLevel: json['maxStockLevel'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      costPrice: (json['costPrice'] ?? 0.0).toDouble(),
      lastUpdated:
          json['lastUpdated'] != null
              ? DateTime.parse(json['lastUpdated'])
              : DateTime.now(),
      supplier: json['supplier'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'category': category,
      'sku': sku,
      'currentStock': currentStock,
      'minStockLevel': minStockLevel,
      'maxStockLevel': maxStockLevel,
      'price': price,
      'costPrice': costPrice,
      'lastUpdated': lastUpdated.toIso8601String(),
      'supplier': supplier,
      'location': location,
      'imageUrl': imageUrl,
    };
  }

  InventoryItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? category,
    String? sku,
    int? currentStock,
    int? minStockLevel,
    int? maxStockLevel,
    double? price,
    double? costPrice,
    DateTime? lastUpdated,
    String? supplier,
    String? location,
    String? imageUrl,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      currentStock: currentStock ?? this.currentStock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      supplier: supplier ?? this.supplier,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Status getters
  bool get isInStock => currentStock > minStockLevel;
  bool get isLowStock => currentStock > 0 && currentStock <= minStockLevel;
  bool get isOutOfStock => currentStock == 0;

  StockStatus get stockStatus {
    if (isOutOfStock) return StockStatus.outOfStock;
    if (isLowStock) return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  Color get stockStatusColor {
    switch (stockStatus) {
      case StockStatus.inStock:
        return Colors.green;
      case StockStatus.lowStock:
        return Colors.orange;
      case StockStatus.outOfStock:
        return Colors.red;
    }
  }

  String get stockStatusText {
    switch (stockStatus) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  String get formattedPrice => '₹${price.toStringAsFixed(0)}';
  String get formattedCostPrice => '₹${costPrice.toStringAsFixed(0)}';
  String get formattedStockValue =>
      '₹${(currentStock * costPrice).toStringAsFixed(0)}';

  String get formattedLastUpdated {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastUpdated.day}/${lastUpdated.month}/${lastUpdated.year}';
    }
  }
}

enum StockStatus { inStock, lowStock, outOfStock }

import 'dart:developer';
import '../libs.dart';
import '../services/inventory_service.dart';

class InventoryController extends GetxController {
  final InventoryService _inventoryService = InventoryService();
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
    {'value': 'Dog', 'label': 'Dog'},
    {'value': 'Cat', 'label': 'Cat'},
    {'value': 'Fish', 'label': 'Fish'},
    {'value': 'Bird', 'label': 'Bird'},
    {'value': 'Accessories', 'label': 'Accessories'},
    {'value': 'Healthcare', 'label': 'Healthcare'},
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
      log('📦 Loading inventory stats from API...');

      final response = await _inventoryService.getInventoryStats();

      if (response.success && response.data != null) {
        final data = response.data;

        // Update summary stats from API
        totalProducts.value = data['totalProducts'] ?? 0;
        inStockProducts.value = data['inStock'] ?? 0;
        lowStockProducts.value = data['lowStock'] ?? 0;
        outOfStockProducts.value = data['outOfStock'] ?? 0;
        totalStockValue.value = (data['totalStockValue'] ?? 0.0).toDouble();

        // Parse products from API
        final List<dynamic> productsJson = data['products'] ?? [];
        final List<InventoryItem> newItems =
            productsJson.map((json) => InventoryItem.fromJson(json)).toList();

        if (isRefresh) {
          inventoryItems.value = newItems;
        } else {
          inventoryItems.addAll(newItems);
        }

        applyFilters();

        log('✅ Inventory loaded successfully: ${newItems.length} items');
      } else {
        log('❌ API failed: ${response.message}');
        throw Exception(response.message ?? 'Failed to load inventory');
      }
    } catch (e) {
      log('❌ Error loading inventory: $e');

      Get.snackbar(
        'Error',
        'Failed to load inventory. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ========== Load More ==========

  Future<void> loadMoreInventory() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    isLoadingMore.value = true;
    currentPage.value++;

    try {
      // For now, disable pagination since API returns all data
      // TODO: Implement pagination when API supports it
      hasMoreData.value = false;

      log(
        '📄 Pagination not implemented yet - showing all data from initial load',
      );
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
      result =
          result
              .where((item) => item.category == selectedCategory.value)
              .toList();
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

      // Determine new stock status based on quantity
      String newStockStatus;
      if (newStock == 0) {
        newStockStatus = 'Out of Stock';
      } else if (newStock <= item.minStockLevel) {
        newStockStatus = 'Low Stock';
      } else {
        newStockStatus = 'In Stock';
      }

      // Update local data
      final index = inventoryItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        inventoryItems[index] = item.copyWith(
          currentStock: newStock,
          lastUpdated: DateTime.now(),
          stockStatus: newStockStatus,
        );

        // Add stock movement record
        _addStockMovement(item, newStock - item.currentStock, reason);

        applyFilters();
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
              stockStatus: 'In Stock',
            );
          }
        }

        applyFilters();

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
    // Convert InventoryItem to ProductModel for compatibility
    final ProductModel product = ProductModel(
      id: item.productId,
      name: item.name,
      images: item.imageUrl.isNotEmpty ? [item.imageUrl] : [],
      petType: item.category,
      category: item.category,
      foodType: '', // Not available in InventoryItem
      weight: '', // Not available in InventoryItem
      stockQuantity: item.currentStock,
      sellingPrice: item.price,
      mrp: item.price, // Using price as MRP since costPrice might be different
      discount: 0, // Not available in InventoryItem
      status: item.currentStock > 0 ? 'active' : 'out_of_stock',
      description: '', // Not available in InventoryItem
      benefits: [], // Not available in InventoryItem
      deliveryEstimate: '', // Not available in InventoryItem
      stockStatus:
          item.currentStock <= item.minStockLevel
              ? 'Low Stock'
              : item.currentStock == 0
              ? 'Out of Stock'
              : 'In Stock',
    );

    Get.toNamed(AppRoutes.productDetails, arguments: product);
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
  final String stockStatus;

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
    required this.stockStatus,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['_id']?.toString() ?? '',
      productId: json['_id']?.toString() ?? '', // Using _id as productId
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      sku: json['_id']?.toString() ?? '', // Using _id as SKU since not provided
      currentStock: json['stockQuantity'] ?? 0,
      minStockLevel: 5, // Default min stock level
      maxStockLevel: 100, // Default max stock level
      price: (json['price'] ?? 0.0).toDouble(),
      costPrice: (json['price'] ?? 0.0).toDouble() * 0.7, // Assuming 30% margin
      lastUpdated:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      supplier: 'Default Supplier', // Not provided in API
      location: 'Warehouse A', // Not provided in API
      imageUrl: json['image'] ?? '',
      stockStatus: json['stockStatus'] ?? 'In Stock',
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
      'stockStatus': stockStatus,
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
    String? stockStatus,
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
      stockStatus: stockStatus ?? this.stockStatus,
    );
  }

  // Status getters
  bool get isInStock => stockStatus.toLowerCase() == 'in stock';
  bool get isLowStock => stockStatus.toLowerCase() == 'low stock';
  bool get isOutOfStock => stockStatus.toLowerCase() == 'out of stock';

  StockStatus get stockStatusEnum {
    switch (stockStatus.toLowerCase()) {
      case 'out of stock':
        return StockStatus.outOfStock;
      case 'low stock':
        return StockStatus.lowStock;
      default:
        return StockStatus.inStock;
    }
  }

  Color get stockStatusColor {
    switch (stockStatusEnum) {
      case StockStatus.inStock:
        return Colors.green;
      case StockStatus.lowStock:
        return Colors.orange;
      case StockStatus.outOfStock:
        return Colors.red;
    }
  }

  String get stockStatusText => stockStatus;

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

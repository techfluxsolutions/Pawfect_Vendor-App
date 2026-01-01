import 'dart:developer';
import '../libs.dart';

class StockMovementsController extends GetxController {
  // Loading States
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var isLoadingMore = false.obs;

  // Stock Movements Data
  var stockMovements = <StockMovement>[].obs;
  var filteredMovements = <StockMovement>[].obs;

  // Filter & Search
  var searchQuery = ''.obs;
  var selectedMovementType = 'all'.obs;
  var selectedDateRange = 'week'.obs;
  var startDate = DateTime.now().subtract(Duration(days: 7)).obs;
  var endDate = DateTime.now().obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  final int pageSize = 20;

  // Filter Options
  final List<Map<String, String>> movementTypeOptions = [
    {'value': 'all', 'label': 'All Movements'},
    {'value': 'stock_in', 'label': 'Stock In'},
    {'value': 'stock_out', 'label': 'Stock Out'},
    {'value': 'adjustment', 'label': 'Adjustment'},
    {'value': 'transfer', 'label': 'Transfer'},
    {'value': 'returned', 'label': 'Return'},
  ];

  final List<Map<String, String>> dateRangeOptions = [
    {'value': 'today', 'label': 'Today'},
    {'value': 'week', 'label': 'This Week'},
    {'value': 'month', 'label': 'This Month'},
    {'value': 'quarter', 'label': 'This Quarter'},
    {'value': 'custom', 'label': 'Custom Range'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadStockMovements();
  }

  // ========== Load Stock Movements ==========

  Future<void> loadStockMovements({bool isRefresh = false}) async {
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

      final newMovements = _generateDummyMovements();

      if (isRefresh) {
        stockMovements.value = newMovements;
      } else {
        stockMovements.addAll(newMovements);
      }

      applyFilters();

      log('✅ Stock movements loaded successfully');
    } catch (e) {
      log('❌ Error loading stock movements: $e');
      Get.snackbar(
        'Error',
        'Failed to load stock movements',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  List<StockMovement> _generateDummyMovements() {
    return [
      StockMovement(
        id: 'mov_001',
        productId: 'prod_001',
        productName: 'Premium Dog Food 5kg',
        sku: 'PDF-5KG-001',
        movementType: MovementType.stockIn,
        quantity: 50,
        previousStock: 25,
        newStock: 75,
        reason: 'Received shipment from supplier',
        reference: 'PO-2024-001',
        performedBy: 'John Doe',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        notes: 'Shipment arrived in good condition',
      ),
      StockMovement(
        id: 'mov_002',
        productId: 'prod_002',
        productName: 'Cat Food Premium 2kg',
        sku: 'CFP-2KG-002',
        movementType: MovementType.stockOut,
        quantity: -5,
        previousStock: 13,
        newStock: 8,
        reason: 'Order fulfillment',
        reference: 'ORD-2024-015',
        performedBy: 'System',
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
        notes: 'Sold to customer',
      ),
      StockMovement(
        id: 'mov_003',
        productId: 'prod_003',
        productName: 'Interactive Dog Toy',
        sku: 'IDT-TOY-003',
        movementType: MovementType.adjustment,
        quantity: -3,
        previousStock: 3,
        newStock: 0,
        reason: 'Damaged items removed',
        reference: 'ADJ-2024-003',
        performedBy: 'Jane Smith',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
        notes: 'Items damaged during handling',
      ),
      StockMovement(
        id: 'mov_004',
        productId: 'prod_004',
        productName: 'Dog Leash Premium',
        sku: 'DLP-ACC-004',
        movementType: MovementType.returned,
        quantity: 2,
        previousStock: 43,
        newStock: 45,
        reason: 'Customer return',
        reference: 'RET-2024-008',
        performedBy: 'Mike Johnson',
        timestamp: DateTime.now().subtract(Duration(hours: 8)),
        notes: 'Customer returned unused items',
      ),
      StockMovement(
        id: 'mov_005',
        productId: 'prod_005',
        productName: 'Cat Treats Variety Pack',
        sku: 'CTV-TRT-005',
        movementType: MovementType.transfer,
        quantity: -8,
        previousStock: 20,
        newStock: 12,
        reason: 'Transfer to branch store',
        reference: 'TRF-2024-002',
        performedBy: 'Sarah Wilson',
        timestamp: DateTime.now().subtract(Duration(hours: 12)),
        notes: 'Transferred to downtown branch',
      ),
    ];
  }

  // ========== Load More ==========

  Future<void> loadMoreMovements() async {
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
        final newMovements = _generateDummyMovements();
        stockMovements.addAll(newMovements);
        applyFilters();
      }
    } catch (e) {
      log('❌ Error loading more movements: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ========== Search & Filter ==========

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void setMovementType(String type) {
    selectedMovementType.value = type;
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
    List<StockMovement> result = List.from(stockMovements);

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      result =
          result.where((movement) {
            final query = searchQuery.value.toLowerCase();
            return movement.productName.toLowerCase().contains(query) ||
                movement.sku.toLowerCase().contains(query) ||
                movement.reason.toLowerCase().contains(query) ||
                movement.reference.toLowerCase().contains(query);
          }).toList();
    }

    // Movement type filter
    if (selectedMovementType.value != 'all') {
      final type = _getMovementTypeFromString(selectedMovementType.value);
      result =
          result.where((movement) => movement.movementType == type).toList();
    }

    // Date range filter
    result =
        result.where((movement) {
          return movement.timestamp.isAfter(
                startDate.value.subtract(Duration(days: 1)),
              ) &&
              movement.timestamp.isBefore(endDate.value.add(Duration(days: 1)));
        }).toList();

    // Sort by timestamp (newest first)
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    filteredMovements.value = result;
  }

  MovementType _getMovementTypeFromString(String type) {
    switch (type) {
      case 'stock_in':
        return MovementType.stockIn;
      case 'stock_out':
        return MovementType.stockOut;
      case 'adjustment':
        return MovementType.adjustment;
      case 'transfer':
        return MovementType.transfer;
      case 'returned':
        return MovementType.returned;
      default:
        return MovementType.adjustment;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedMovementType.value = 'all';
    selectedDateRange.value = 'week';
    setDateRange('week');
  }

  // ========== Export ==========

  Future<void> exportMovements(String format) async {
    try {
      // TODO: Implement actual export functionality
      await Future.delayed(Duration(seconds: 2));

      Get.snackbar(
        'Export Complete',
        'Stock movements exported as $format',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        'Failed to export movements: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========== Refresh ==========

  Future<void> refreshMovements() async {
    await loadStockMovements(isRefresh: true);
  }

  // ========== Getters ==========

  String get selectedMovementTypeLabel {
    return movementTypeOptions.firstWhere(
      (option) => option['value'] == selectedMovementType.value,
      orElse: () => {'label': 'All Movements'},
    )['label']!;
  }

  String get selectedDateRangeLabel {
    return dateRangeOptions.firstWhere(
      (option) => option['value'] == selectedDateRange.value,
      orElse: () => {'label': 'This Week'},
    )['label']!;
  }
}

// ========== Stock Movement Models ==========

enum MovementType { stockIn, stockOut, adjustment, transfer, returned }

class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final MovementType movementType;
  final int quantity;
  final int previousStock;
  final int newStock;
  final String reason;
  final String reference;
  final String performedBy;
  final DateTime timestamp;
  final String notes;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.movementType,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.reason,
    required this.reference,
    required this.performedBy,
    required this.timestamp,
    required this.notes,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName'] ?? '',
      sku: json['sku'] ?? '',
      movementType: _movementTypeFromString(
        json['movementType'] ?? 'adjustment',
      ),
      quantity: json['quantity'] ?? 0,
      previousStock: json['previousStock'] ?? 0,
      newStock: json['newStock'] ?? 0,
      reason: json['reason'] ?? '',
      reference: json['reference'] ?? '',
      performedBy: json['performedBy'] ?? '',
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'sku': sku,
      'movementType': movementType.toString().split('.').last,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'reason': reason,
      'reference': reference,
      'performedBy': performedBy,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  static MovementType _movementTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'stockin':
      case 'stock_in':
        return MovementType.stockIn;
      case 'stockout':
      case 'stock_out':
        return MovementType.stockOut;
      case 'adjustment':
        return MovementType.adjustment;
      case 'transfer':
        return MovementType.transfer;
      case 'returned':
        return MovementType.returned;
      default:
        return MovementType.adjustment;
    }
  }

  // Getters
  bool get isIncrease => quantity > 0;
  bool get isDecrease => quantity < 0;

  Color get movementTypeColor {
    switch (movementType) {
      case MovementType.stockIn:
        return Colors.green;
      case MovementType.stockOut:
        return Colors.red;
      case MovementType.adjustment:
        return Colors.orange;
      case MovementType.transfer:
        return Colors.blue;
      case MovementType.returned:
        return Colors.purple;
    }
  }

  String get movementTypeText {
    switch (movementType) {
      case MovementType.stockIn:
        return 'Stock In';
      case MovementType.stockOut:
        return 'Stock Out';
      case MovementType.adjustment:
        return 'Adjustment';
      case MovementType.transfer:
        return 'Transfer';
      case MovementType.returned:
        return 'Return';
    }
  }

  IconData get movementTypeIcon {
    switch (movementType) {
      case MovementType.stockIn:
        return Icons.add_circle;
      case MovementType.stockOut:
        return Icons.remove_circle;
      case MovementType.adjustment:
        return Icons.edit;
      case MovementType.transfer:
        return Icons.swap_horiz;
      case MovementType.returned:
        return Icons.undo;
    }
  }

  String get formattedQuantity {
    return '${quantity > 0 ? '+' : ''}$quantity';
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

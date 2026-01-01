import 'dart:developer';
import '../libs.dart';

class TransactionHistoryController extends GetxController {
  // Loading States
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isRefreshing = false.obs;

  // Transaction Data
  var transactions = <Map<String, dynamic>>[].obs;
  var filteredTransactions = <Map<String, dynamic>>[].obs;

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
  var totalAmount = 0.0.obs;
  var totalCredit = 0.0.obs;
  var totalDebit = 0.0.obs;
  var transactionCount = 0.obs;

  // Filter Options
  final List<Map<String, String>> filterOptions = [
    {'value': 'all', 'label': 'All Transactions'},
    {'value': 'credit', 'label': 'Credits Only'},
    {'value': 'debit', 'label': 'Debits Only'},
    {'value': 'settlement', 'label': 'Settlements'},
    {'value': 'commission', 'label': 'Commission'},
    {'value': 'refund', 'label': 'Refunds'},
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
    loadTransactions();
  }

  // ========== Load Transactions ==========

  Future<void> loadTransactions({bool isRefresh = false}) async {
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

      // Generate dummy transaction data
      final newTransactions = _generateDummyTransactions();

      if (isRefresh) {
        transactions.value = newTransactions;
      } else {
        transactions.addAll(newTransactions);
      }

      _calculateSummary();
      applyFilters();

      log('✅ Transactions loaded');
    } catch (e) {
      log('❌ Error loading transactions: $e');
      Get.snackbar(
        'Error',
        'Failed to load transactions',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  List<Map<String, dynamic>> _generateDummyTransactions() {
    final List<Map<String, dynamic>> dummyTransactions = [
      {
        'id': 'txn_001',
        'type': 'settlement',
        'amount': 8920.00,
        'status': 'completed',
        'date': '2024-01-20',
        'time': '14:30:00',
        'description': 'Weekly settlement payment',
        'orderId': 'ORD-2024-001',
        'paymentMethod': 'Bank Transfer',
        'transactionId': 'TXN123456789',
        'commission': 1068.00,
        'netAmount': 7852.00,
      },
      {
        'id': 'txn_002',
        'type': 'commission',
        'amount': -150.00,
        'status': 'completed',
        'date': '2024-01-19',
        'time': '16:45:00',
        'description': 'Commission deduction for order #ORD-2024-002',
        'orderId': 'ORD-2024-002',
        'paymentMethod': 'UPI',
        'transactionId': 'TXN123456788',
        'commission': 150.00,
        'netAmount': -150.00,
      },
      {
        'id': 'txn_003',
        'type': 'credit',
        'amount': 1250.00,
        'status': 'completed',
        'date': '2024-01-19',
        'time': '12:15:00',
        'description': 'Payment received for order #ORD-2024-003',
        'orderId': 'ORD-2024-003',
        'paymentMethod': 'Credit Card',
        'transactionId': 'TXN123456787',
        'commission': 0.00,
        'netAmount': 1250.00,
      },
      {
        'id': 'txn_004',
        'type': 'refund',
        'amount': -450.00,
        'status': 'completed',
        'date': '2024-01-18',
        'time': '10:20:00',
        'description': 'Refund processed for order #ORD-2024-004',
        'orderId': 'ORD-2024-004',
        'paymentMethod': 'UPI',
        'transactionId': 'TXN123456786',
        'commission': 0.00,
        'netAmount': -450.00,
      },
      {
        'id': 'txn_005',
        'type': 'credit',
        'amount': 2100.00,
        'status': 'pending',
        'date': '2024-01-17',
        'time': '18:30:00',
        'description': 'Payment received for order #ORD-2024-005',
        'orderId': 'ORD-2024-005',
        'paymentMethod': 'Digital Wallet',
        'transactionId': 'TXN123456785',
        'commission': 0.00,
        'netAmount': 2100.00,
      },
    ];

    return dummyTransactions;
  }

  void _calculateSummary() {
    double credit = 0.0;
    double debit = 0.0;

    for (var transaction in transactions) {
      final amount = transaction['amount'] ?? 0.0;
      if (amount > 0) {
        credit += amount;
      } else {
        debit += amount.abs();
      }
    }

    totalCredit.value = credit;
    totalDebit.value = debit;
    totalAmount.value = credit - debit;
    transactionCount.value = transactions.length;
  }

  // ========== Load More Transactions ==========

  Future<void> loadMoreTransactions() async {
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
        final newTransactions = _generateDummyTransactions();
        transactions.addAll(newTransactions);
        applyFilters();
      }
    } catch (e) {
      log('❌ Error loading more transactions: $e');
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
    List<Map<String, dynamic>> result = List.from(transactions);

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      result =
          result.where((transaction) {
            final query = searchQuery.value.toLowerCase();
            return transaction['description'].toString().toLowerCase().contains(
                  query,
                ) ||
                transaction['orderId'].toString().toLowerCase().contains(
                  query,
                ) ||
                transaction['transactionId'].toString().toLowerCase().contains(
                  query,
                );
          }).toList();
    }

    // Type filter
    if (selectedFilter.value != 'all') {
      result =
          result.where((transaction) {
            return transaction['type'] == selectedFilter.value;
          }).toList();
    }

    // Date range filter
    if (selectedDateRange.value != 'all') {
      result =
          result.where((transaction) {
            final transactionDate = DateTime.parse(transaction['date']);
            return transactionDate.isAfter(
                  startDate.value.subtract(Duration(days: 1)),
                ) &&
                transactionDate.isBefore(endDate.value.add(Duration(days: 1)));
          }).toList();
    }

    // Sort by date (newest first)
    result.sort((a, b) {
      final dateA = DateTime.parse('${a['date']} ${a['time']}');
      final dateB = DateTime.parse('${b['date']} ${b['time']}');
      return dateB.compareTo(dateA);
    });

    filteredTransactions.value = result;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedFilter.value = 'all';
    selectedDateRange.value = 'all';
    applyFilters();
  }

  // ========== Transaction Actions ==========

  void viewTransactionDetails(Map<String, dynamic> transaction) {
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

            Text(
              'Transaction Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            _buildDetailRow('Transaction ID', transaction['transactionId']),
            _buildDetailRow('Order ID', transaction['orderId']),
            _buildDetailRow(
              'Type',
              _getTransactionTypeDisplayName(transaction['type']),
            ),
            _buildDetailRow(
              'Amount',
              '₹${transaction['amount'].abs().toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              'Status',
              transaction['status'].toString().toUpperCase(),
            ),
            _buildDetailRow(
              'Date',
              '${transaction['date']} ${transaction['time']}',
            ),
            _buildDetailRow('Payment Method', transaction['paymentMethod']),
            if (transaction['commission'] > 0)
              _buildDetailRow(
                'Commission',
                '₹${transaction['commission'].toStringAsFixed(2)}',
              ),
            _buildDetailRow(
              'Net Amount',
              '₹${transaction['netAmount'].toStringAsFixed(2)}',
            ),
            _buildDetailRow('Description', transaction['description']),

            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                      downloadTransactionReceipt(transaction);
                    },
                    child: Text('Download Receipt'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void downloadTransactionReceipt(Map<String, dynamic> transaction) {
    Get.snackbar(
      'Downloading Receipt',
      'Transaction receipt is being prepared...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void exportTransactions() {
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
            Text(
              'Export Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text('Export as PDF'),
              subtitle: Text('Detailed transaction report'),
              onTap: () {
                Get.back();
                _exportToPDF();
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: Colors.green),
              title: Text('Export as Excel'),
              subtitle: Text('Spreadsheet format'),
              onTap: () {
                Get.back();
                _exportToExcel();
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: Colors.blue),
              title: Text('Export as CSV'),
              subtitle: Text('Comma-separated values'),
              onTap: () {
                Get.back();
                _exportToCSV();
              },
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.back(),
              child: Center(child: Text('Cancel')),
            ),
          ],
        ),
      ),
    );
  }

  void _exportToPDF() {
    Get.snackbar(
      'Exporting PDF',
      'Transaction report is being generated...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void _exportToExcel() {
    Get.snackbar(
      'Exporting Excel',
      'Excel file is being generated...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void _exportToCSV() {
    Get.snackbar(
      'Exporting CSV',
      'CSV file is being generated...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  // ========== Helper Methods ==========

  IconData getTransactionTypeIcon(String type) {
    switch (type) {
      case 'settlement':
        return Icons.account_balance;
      case 'commission':
        return Icons.percent;
      case 'credit':
        return Icons.add_circle;
      case 'debit':
        return Icons.remove_circle;
      case 'refund':
        return Icons.undo;
      default:
        return Icons.payment;
    }
  }

  Color getTransactionTypeColor(String type) {
    switch (type) {
      case 'settlement':
        return Colors.blue;
      case 'commission':
        return Colors.orange;
      case 'credit':
        return Colors.green;
      case 'debit':
        return Colors.red;
      case 'refund':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTransactionTypeDisplayName(String type) {
    switch (type) {
      case 'settlement':
        return 'Settlement';
      case 'commission':
        return 'Commission';
      case 'credit':
        return 'Credit';
      case 'debit':
        return 'Debit';
      case 'refund':
        return 'Refund';
      default:
        return 'Unknown';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // ========== Refresh ==========

  Future<void> refreshTransactions() async {
    await loadTransactions(isRefresh: true);
  }
}

import 'dart:developer';
import '../libs.dart';

class EarningsController extends GetxController {
  // Earnings Data
  var totalEarnings = '₹45,280'.obs;
  var pendingAmount = '₹3,450'.obs;
  var thisMonthEarnings = '₹12,340'.obs;
  var lastSettlement = '₹8,920'.obs;

  // Analytics Data
  var avgOrderValue = '₹485'.obs;
  var commissionRate = '12%'.obs;

  // Recent Settlements
  var recentSettlements = <Map<String, dynamic>>[].obs;

  // Loading States
  var isLoading = false.obs;
  var isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadEarningsData();
  }

  // ========== Load Earnings Data ==========

  Future<void> loadEarningsData() async {
    isLoading.value = true;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 800));

      // Load dummy data
      totalEarnings.value = '₹45,280';
      pendingAmount.value = '₹3,450';
      thisMonthEarnings.value = '₹12,340';
      lastSettlement.value = '₹8,920';
      avgOrderValue.value = '₹485';
      commissionRate.value = '12%';

      // Load recent settlements
      recentSettlements.value = [
        {
          'amount': '₹8,920',
          'date': 'Dec 25, 2024',
          'status': 'Completed',
          'transactionId': 'TXN123456789',
        },
        {
          'amount': '₹6,750',
          'date': 'Dec 18, 2024',
          'status': 'Completed',
          'transactionId': 'TXN123456788',
        },
        {
          'amount': '₹5,430',
          'date': 'Dec 11, 2024',
          'status': 'Processing',
          'transactionId': 'TXN123456787',
        },
      ];

      log('✅ Earnings data loaded');
    } catch (e) {
      log('❌ Error loading earnings data: $e');
      Get.snackbar(
        'Error',
        'Failed to load earnings data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== Refresh Earnings ==========

  Future<void> refreshEarnings() async {
    isRefreshing.value = true;
    await loadEarningsData();
    isRefreshing.value = false;
  }

  // ========== Quick Actions ==========

  void downloadSettlementReport() {
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
              'Download Settlement Report',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.calendar_month, color: Colors.blue),
              title: Text('This Month'),
              subtitle: Text('December 2024'),
              onTap: () {
                Get.back();
                _downloadReport('This Month');
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.green),
              title: Text('Last Month'),
              subtitle: Text('November 2024'),
              onTap: () {
                Get.back();
                _downloadReport('Last Month');
              },
            ),
            ListTile(
              leading: Icon(Icons.date_range, color: Colors.orange),
              title: Text('Custom Range'),
              subtitle: Text('Select date range'),
              onTap: () {
                Get.back();
                _showDateRangePicker();
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

  void _downloadReport(String period) {
    Get.snackbar(
      'Downloading Report',
      'Settlement report for $period is being prepared...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void _showDateRangePicker() {
    Get.snackbar(
      'Date Range Picker',
      'Custom date range selection coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void updateBankDetails() {
    // Navigate to bank details screen
    Get.toNamed(AppRoutes.bankDetails);
  }

  void managePaymentMethods() {
    // Navigate to payment methods screen
    Get.toNamed(AppRoutes.paymentMethods);
  }

  void viewTransactionHistory() {
    // Navigate to transaction history screen
    Get.toNamed(AppRoutes.transactionHistory);
  }

  void showSettlementHelp() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Settlement Help'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How settlements work:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Settlements are processed weekly on Fridays'),
            Text('• Minimum settlement amount is ₹100'),
            Text('• Processing time: 2-3 business days'),
            Text('• Commission is deducted automatically'),
            SizedBox(height: 12),
            Text(
              'Need more help?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Contact our support team for assistance.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Got it')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Navigate to support
            },
            child: Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  // ========== Navigation Methods ==========

  void viewAllSettlements() {
    Get.toNamed(AppRoutes.transactionHistory);
  }

  void viewDetailedAnalytics() {
    Get.toNamed('/earnings-analytics');
  }

  // ========== Settlement Details ==========

  void viewSettlementDetails(Map<String, dynamic> settlement) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Settlement Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildDetailRow('Amount', settlement['amount']),
            _buildDetailRow('Date', settlement['date']),
            _buildDetailRow('Status', settlement['status']),
            _buildDetailRow('Transaction ID', settlement['transactionId']),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                      _downloadSettlementReceipt(settlement);
                    },
                    child: Text('Download Receipt'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _trackSettlement(settlement);
                    },
                    child: Text('Track Status'),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _downloadSettlementReceipt(Map<String, dynamic> settlement) {
    Get.snackbar(
      'Downloading Receipt',
      'Settlement receipt is being prepared...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _trackSettlement(Map<String, dynamic> settlement) {
    Get.snackbar(
      'Tracking Settlement',
      'Opening settlement tracking...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
}

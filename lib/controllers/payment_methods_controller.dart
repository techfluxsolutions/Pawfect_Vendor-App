import 'dart:developer';
import '../libs.dart';

class PaymentMethodsController extends GetxController {
  // Loading States
  var isLoading = false.obs;
  var isSaving = false.obs;

  // Payment Methods Data
  var paymentMethods = <Map<String, dynamic>>[].obs;
  var defaultPaymentMethod = ''.obs;

  // Available Payment Types
  final List<Map<String, dynamic>> availablePaymentTypes = [
    {
      'id': 'bank_transfer',
      'name': 'Bank Transfer',
      'description': 'Direct bank account transfer',
      'icon': Icons.account_balance,
      'color': Colors.blue,
      'isEnabled': true,
    },
    {
      'id': 'upi',
      'name': 'UPI',
      'description': 'Unified Payments Interface',
      'icon': Icons.payment,
      'color': Colors.green,
      'isEnabled': true,
    },
    {
      'id': 'digital_wallet',
      'name': 'Digital Wallet',
      'description': 'Paytm, PhonePe, Google Pay',
      'icon': Icons.account_balance_wallet,
      'color': Colors.orange,
      'isEnabled': true,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
  }

  // ========== Load Payment Methods ==========

  Future<void> loadPaymentMethods() async {
    isLoading.value = true;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 800));

      // Simulate existing payment methods
      paymentMethods.value = [
        {
          'id': 'pm_001',
          'type': 'bank_transfer',
          'name': 'HDFC Bank Account',
          'details': 'Account ending in 1234',
          'isDefault': true,
          'isVerified': true,
          'addedDate': '2024-01-15',
          'lastUsed': '2024-01-20',
          'metadata': {
            'accountNumber': '****1234',
            'bankName': 'HDFC Bank',
            'ifsc': 'HDFC0001234',
          },
        },
        {
          'id': 'pm_002',
          'type': 'upi',
          'name': 'UPI ID',
          'details': 'john.doe@paytm',
          'isDefault': false,
          'isVerified': true,
          'addedDate': '2024-01-10',
          'lastUsed': '2024-01-18',
          'metadata': {'upiId': 'john.doe@paytm'},
        },
      ];

      // Set default payment method
      final defaultMethod = paymentMethods.firstWhere(
        (method) => method['isDefault'] == true,
        orElse: () => {},
      );
      if (defaultMethod.isNotEmpty) {
        defaultPaymentMethod.value = defaultMethod['id'];
      }

      log('✅ Payment methods loaded');
    } catch (e) {
      log('❌ Error loading payment methods: $e');
      Get.snackbar(
        'Error',
        'Failed to load payment methods',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== Add Payment Method ==========

  void addPaymentMethod(String type) {
    switch (type) {
      case 'bank_transfer':
        _addBankTransfer();
        break;
      case 'upi':
        _addUPI();
        break;
      case 'digital_wallet':
        _addDigitalWallet();
        break;
      default:
        Get.snackbar(
          'Coming Soon',
          'This payment method will be available soon',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
    }
  }

  void _addBankTransfer() {
    Get.toNamed(AppRoutes.bankDetails);
  }

  void _addUPI() {
    final upiController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Add UPI ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: upiController,
              decoration: InputDecoration(
                labelText: 'UPI ID',
                hintText: 'yourname@paytm',
                prefixIcon: Icon(Icons.payment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 8),
            Text(
              'Enter your UPI ID (e.g., yourname@paytm)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (upiController.text.trim().isNotEmpty) {
                _saveUPIMethod(upiController.text.trim());
                Get.back();
              }
            },
            child: Text('Add UPI'),
          ),
        ],
      ),
    );
  }

  void _addDigitalWallet() {
    final walletTypes = ['Paytm', 'PhonePe', 'Google Pay', 'Amazon Pay'];

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
              'Select Wallet Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...walletTypes.map(
              (wallet) => ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.orange,
                ),
                title: Text(wallet),
                onTap: () {
                  Get.back();
                  _addWalletDetails(wallet);
                },
              ),
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

  void _addWalletDetails(String walletType) {
    final phoneController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Add $walletType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+91 9876543210',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 8),
            Text(
              'Enter the phone number linked to your $walletType account',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.trim().isNotEmpty) {
                _saveWalletMethod(walletType, phoneController.text.trim());
                Get.back();
              }
            },
            child: Text('Add Wallet'),
          ),
        ],
      ),
    );
  }

  // ========== Save Payment Methods ==========

  Future<void> _saveUPIMethod(String upiId) async {
    isSaving.value = true;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1));

      final newMethod = {
        'id': 'pm_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'upi',
        'name': 'UPI ID',
        'details': upiId,
        'isDefault': paymentMethods.isEmpty,
        'isVerified': false,
        'addedDate': DateTime.now().toString().split(' ')[0],
        'lastUsed': null,
        'metadata': {'upiId': upiId},
      };

      paymentMethods.add(newMethod);

      Get.snackbar(
        'Success',
        'UPI ID added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add UPI ID',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _saveWalletMethod(String walletType, String phoneNumber) async {
    isSaving.value = true;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1));

      final newMethod = {
        'id': 'pm_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'digital_wallet',
        'name': walletType,
        'details': phoneNumber,
        'isDefault': paymentMethods.isEmpty,
        'isVerified': false,
        'addedDate': DateTime.now().toString().split(' ')[0],
        'lastUsed': null,
        'metadata': {'walletType': walletType, 'phoneNumber': phoneNumber},
      };

      paymentMethods.add(newMethod);

      Get.snackbar(
        'Success',
        '$walletType added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add $walletType',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ========== Set Default Payment Method ==========

  Future<void> setDefaultPaymentMethod(String methodId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 500));

      // Update local data
      for (var method in paymentMethods) {
        method['isDefault'] = method['id'] == methodId;
      }
      defaultPaymentMethod.value = methodId;
      paymentMethods.refresh();

      Get.snackbar(
        'Success',
        'Default payment method updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update default payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========== Delete Payment Method ==========

  Future<void> deletePaymentMethod(Map<String, dynamic> method) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete "${method['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // TODO: Replace with actual API call
        await Future.delayed(Duration(seconds: 1));

        paymentMethods.removeWhere((m) => m['id'] == method['id']);

        // If deleted method was default, set first method as default
        if (method['isDefault'] && paymentMethods.isNotEmpty) {
          paymentMethods.first['isDefault'] = true;
          defaultPaymentMethod.value = paymentMethods.first['id'];
        }

        Get.snackbar(
          'Success',
          'Payment method deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete payment method',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // ========== Helper Methods ==========

  IconData getPaymentTypeIcon(String type) {
    switch (type) {
      case 'bank_transfer':
        return Icons.account_balance;
      case 'upi':
        return Icons.payment;
      case 'digital_wallet':
        return Icons.account_balance_wallet;
      case 'cheque':
        return Icons.receipt_long;
      default:
        return Icons.payment;
    }
  }

  Color getPaymentTypeColor(String type) {
    switch (type) {
      case 'bank_transfer':
        return Colors.blue;
      case 'upi':
        return Colors.green;
      case 'digital_wallet':
        return Colors.orange;
      case 'cheque':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String getPaymentTypeDisplayName(String type) {
    switch (type) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'upi':
        return 'UPI';
      case 'digital_wallet':
        return 'Digital Wallet';
      case 'cheque':
        return 'Cheque';
      default:
        return 'Unknown';
    }
  }

  // ========== Refresh Methods ==========

  Future<void> refreshPaymentMethods() async {
    await loadPaymentMethods();
  }
}

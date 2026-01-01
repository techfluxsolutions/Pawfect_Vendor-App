import 'dart:developer';
import '../libs.dart';

class BankDetailsController extends GetxController {
  // Form Key
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final accountHolderNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final confirmAccountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final bankNameController = TextEditingController();
  final branchNameController = TextEditingController();
  final upiIdController = TextEditingController();

  // Observable Values
  var isLoading = false.obs;
  var isSaving = false.obs;
  var hasExistingBankDetails = false.obs;
  var selectedAccountType = 'Savings'.obs;
  var isUpiEnabled = false.obs;

  // Bank Details Data
  var bankDetails = <String, dynamic>{}.obs;

  // Account Types
  final List<String> accountTypes = ['Savings', 'Current'];

  @override
  void onInit() {
    super.onInit();
    loadBankDetails();
  }

  @override
  void onClose() {
    accountHolderNameController.dispose();
    accountNumberController.dispose();
    confirmAccountNumberController.dispose();
    ifscCodeController.dispose();
    bankNameController.dispose();
    branchNameController.dispose();
    upiIdController.dispose();
    super.onClose();
  }

  // ========== Load Bank Details ==========

  Future<void> loadBankDetails() async {
    isLoading.value = true;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 800));

      // Simulate existing bank details (remove this when implementing API)
      final existingDetails = <String, dynamic>{
        // 'accountHolderName': 'John Doe',
        // 'accountNumber': '1234567890123456',
        // 'ifscCode': 'HDFC0001234',
        // 'bankName': 'HDFC Bank',
        // 'branchName': 'Main Branch, Mumbai',
        // 'accountType': 'Savings',
        // 'upiId': 'john.doe@paytm',
        // 'isVerified': true,
      };

      if (existingDetails.isNotEmpty) {
        hasExistingBankDetails.value = true;
        bankDetails.value = existingDetails;
        _populateForm(existingDetails);
      }

      log('✅ Bank details loaded');
    } catch (e) {
      log('❌ Error loading bank details: $e');
      Get.snackbar(
        'Error',
        'Failed to load bank details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _populateForm(Map<String, dynamic> details) {
    accountHolderNameController.text = details['accountHolderName'] ?? '';
    accountNumberController.text = details['accountNumber'] ?? '';
    confirmAccountNumberController.text = details['accountNumber'] ?? '';
    ifscCodeController.text = details['ifscCode'] ?? '';
    bankNameController.text = details['bankName'] ?? '';
    branchNameController.text = details['branchName'] ?? '';
    upiIdController.text = details['upiId'] ?? '';
    selectedAccountType.value = details['accountType'] ?? 'Savings';
    isUpiEnabled.value = (details['upiId'] ?? '').isNotEmpty;
  }

  // ========== Save Bank Details ==========

  Future<void> saveBankDetails() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields correctly',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Validate account number confirmation
    if (accountNumberController.text != confirmAccountNumberController.text) {
      Get.snackbar(
        'Validation Error',
        'Account numbers do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isSaving.value = true;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 2));

      // Simulate API response
      final success = true; // Replace with actual API response

      if (success) {
        hasExistingBankDetails.value = true;
        bankDetails.value = {
          'accountHolderName': accountHolderNameController.text,
          'accountNumber': accountNumberController.text,
          'ifscCode': ifscCodeController.text,
          'bankName': bankNameController.text,
          'branchName': branchNameController.text,
          'accountType': selectedAccountType.value,
          'upiId': isUpiEnabled.value ? upiIdController.text : '',
          'isVerified': false, // Will be verified by admin
        };

        Get.snackbar(
          'Success',
          hasExistingBankDetails.value
              ? 'Bank details updated successfully'
              : 'Bank details saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        // Navigate back after successful save
        Get.back();
      } else {
        Get.snackbar(
          'Error',
          'Failed to save bank details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('❌ Error saving bank details: $e');
      Get.snackbar(
        'Error',
        'Failed to save bank details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ========== Validation Methods ==========

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account number is required';
    }
    if (value.length < 9 || value.length > 18) {
      return 'Account number must be 9-18 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Account number must contain only digits';
    }
    return null;
  }

  String? validateIFSC(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IFSC code is required';
    }
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value.toUpperCase())) {
      return 'Invalid IFSC code format';
    }
    return null;
  }

  String? validateUPI(String? value) {
    if (!isUpiEnabled.value) return null;
    if (value == null || value.trim().isEmpty) {
      return 'UPI ID is required when UPI is enabled';
    }
    if (!RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$').hasMatch(value)) {
      return 'Invalid UPI ID format';
    }
    return null;
  }

  // ========== Helper Methods ==========

  void toggleUPI(bool value) {
    isUpiEnabled.value = value;
    if (!value) {
      upiIdController.clear();
    }
  }

  void setAccountType(String type) {
    selectedAccountType.value = type;
  }

  void clearForm() {
    accountHolderNameController.clear();
    accountNumberController.clear();
    confirmAccountNumberController.clear();
    ifscCodeController.clear();
    bankNameController.clear();
    branchNameController.clear();
    upiIdController.clear();
    selectedAccountType.value = 'Savings';
    isUpiEnabled.value = false;
  }

  // ========== IFSC Code Lookup ==========

  Future<void> lookupIFSC(String ifscCode) async {
    if (ifscCode.length != 11) return;

    try {
      // TODO: Implement IFSC lookup API
      // This is a placeholder for IFSC lookup functionality
      await Future.delayed(Duration(milliseconds: 500));

      // Simulate bank details lookup
      final bankInfo = {
        'HDFC0001234': {'bank': 'HDFC Bank', 'branch': 'Main Branch, Mumbai'},
        'ICIC0001234': {
          'bank': 'ICICI Bank',
          'branch': 'Central Branch, Delhi',
        },
        'SBIN0001234': {
          'bank': 'State Bank of India',
          'branch': 'City Branch, Bangalore',
        },
      };

      if (bankInfo.containsKey(ifscCode.toUpperCase())) {
        final info = bankInfo[ifscCode.toUpperCase()]!;
        bankNameController.text = info['bank']!;
        branchNameController.text = info['branch']!;

        Get.snackbar(
          'Success',
          'Bank details found and filled automatically',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      log('❌ Error looking up IFSC: $e');
    }
  }

  // ========== Delete Bank Details ==========

  Future<void> deleteBankDetails() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Bank Details'),
        content: Text(
          'Are you sure you want to delete your bank details? This action cannot be undone.',
        ),
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

        hasExistingBankDetails.value = false;
        bankDetails.clear();
        clearForm();

        Get.snackbar(
          'Success',
          'Bank details deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete bank details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}

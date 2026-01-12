import 'dart:developer';

import '../libs.dart';

class ProfileController extends GetxController {
  // Store Information
  var storeName = 'Pawfect Pet Store'.obs;
  var storeLogoUrl = ''.obs;
  var isStoreActive = true.obs;

  // Account Information
  var ownerName = 'John Doe'.obs;
  var email = 'john.doe@pawfect.com'.obs;
  var mobileNumber = '+91 9876543210'.obs;
  var isEmailVerified = true.obs;
  var isMobileVerified = true.obs;

  // Store Ratings
  var storeRating = 4.5.obs;
  var totalReviews = 128.obs;

  // Loading State
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  // ========== Load Profile Data ==========

  Future<void> loadProfileData() async {
    isLoading.value = true;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 500));

      // Dummy data
      storeName.value = 'Pawfect Pet Store';
      storeLogoUrl.value = ''; // Leave empty for default icon
      isStoreActive.value = true;
      ownerName.value = 'John Doe';
      email.value = 'john.doe@pawfect.com';
      mobileNumber.value = '+91 9876543210';
      isEmailVerified.value = true;
      isMobileVerified.value = true;
      storeRating.value = 4.5;
      totalReviews.value = 128;

      log('✅ Profile data loaded');
    } catch (e) {
      log('❌ Error loading profile data: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== Store Status Toggle ==========

  Future<void> toggleStoreStatus() async {
    try {
      // Show loading state
      isLoading.value = true;

      // TODO: Replace with actual API call to update store status
      await Future.delayed(Duration(milliseconds: 800));

      // Toggle the status
      isStoreActive.value = !isStoreActive.value;

      // Show success message
      Get.snackbar(
        'Store Status Updated',
        'Your store is now ${isStoreActive.value ? 'Active' : 'Inactive'}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isStoreActive.value ? Colors.green : Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        icon: Icon(
          isStoreActive.value ? Icons.check_circle : Icons.pause_circle,
          color: Colors.white,
        ),
      );

      log(
        '✅ Store status toggled to: ${isStoreActive.value ? 'Active' : 'Inactive'}',
      );
    } catch (e) {
      log('❌ Error toggling store status: $e');
      Get.snackbar(
        'Error',
        'Failed to update store status. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== Edit Profile ==========

  void editProfile() {
    Get.snackbar(
      'Edit Profile',
      'Edit profile feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void editOwnerName() {
    Get.dialog(
      AlertDialog(
        title: Text('Edit Owner Name'),
        content: TextField(
          controller: TextEditingController(text: ownerName.value),
          decoration: InputDecoration(
            hintText: 'Enter owner name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ownerName.value = value.trim();
              Get.back();
              Get.snackbar(
                'Success',
                'Owner name updated successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final controller = TextEditingController(text: ownerName.value);
              if (controller.text.trim().isNotEmpty) {
                ownerName.value = controller.text.trim();
                Get.back();
                Get.snackbar(
                  'Success',
                  'Owner name updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // ========== Earnings & Payments Navigation ==========

  void navigateToEarnings() {
    // Get.to(() => EarningsScreen());
  }

  void navigateToBankAccount() {
    // Get.toNamed(AppRoutes.bankDetails);
  }

  void navigateToPaymentMethods() {
    // Get.toNamed(AppRoutes.paymentMethods);
  }

  void navigateToTransactionHistory() {
    // Get.toNamed(AppRoutes.transactionHistory);
  }

  void navigateToTaxInfo() {
    Get.snackbar(
      'Tax Information',
      'Manage your GST and tax details',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  // ========== Legal & Documents Navigation ==========

  void navigateToKYC() {
    Get.snackbar(
      'KYC Documents',
      'View and upload KYC documents',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void navigateToBusinessDocuments() {
    Get.snackbar(
      'Business Documents',
      'Manage your business documents',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  // ========== Support & Help Navigation ==========

  void contactSupport() {
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
              'Contact Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.green),
              title: Text('Call Support'),
              subtitle: Text('+91 1800-XXX-XXXX'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Calling Support',
                  'Redirecting to phone...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: Text('Email Support'),
              subtitle: Text('support@pawfect.com'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Email Support',
                  'Opening email client...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.orange),
              title: Text('Live Chat'),
              subtitle: Text('Chat with our support team'),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Live Chat',
                  'Opening chat...',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
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

  void navigateToFAQ() {
    Get.snackbar(
      'Help & FAQ',
      'View frequently asked questions',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void navigateToTerms() {
    Get.snackbar(
      'Terms & Conditions',
      'View terms and conditions',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void navigateToPrivacy() {
    Get.snackbar(
      'Privacy Policy',
      'View privacy policy',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  // ========== Logout ==========

  void logout() {
    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              // Show loading
              Get.dialog(
                Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              // Simulate logout process
              await Future.delayed(Duration(seconds: 1));

              // Close loading
              Get.back();

              // TODO: Clear user data, tokens, etc.
              // TODO: Navigate to login screen

              Get.snackbar(
                'Logged Out',
                'You have been logged out successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: Duration(seconds: 2),
              );

              // Navigate to login (uncomment when you have login route)
              // Get.offAllNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ========== Refresh Profile Data ==========

  Future<void> refreshProfile() async {
    await loadProfileData();
  }
}

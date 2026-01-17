import 'dart:developer';

import '../libs.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();

  // Store Information
  var storeName = 'Pawfect Pet Store'.obs;
  var storeLogoUrl = ''.obs;
  var isStoreActive = true.obs;

  // Account Information
  var ownerName = 'John Doe'.obs;
  var email = 'john.doe@pawfect.com'.obs;
  var mobileNumber = ''.obs; // ✅ Will be loaded from storage
  var isEmailVerified = true.obs;
  var isMobileVerified = false.obs; // ✅ Will be loaded from storage

  // Store Ratings
  var storeRating = 0.0.obs; // ✅ Default to 0.0
  var totalReviews = 0.obs; // ✅ Default to 0

  // Loading State
  var isLoading = false.obs;
  var isLoadingReviews = false.obs; // ✅ Separate loading for reviews

  @override
  void onInit() {
    super.onInit();
    loadStoreInfo(); // ✅ Load store info from KYC API
    loadUserInfo(); // ✅ Load user info from storage
    loadReviewStats(); // ✅ Load review stats
  }

  // ========== Load Store Info from KYC API ==========

  Future<void> loadStoreInfo() async {
    try {
      log('📊 Loading store info from KYC API...');

      final response = await ApiClient().get(ApiUrls.kycStatus);

      if (response.success && response.data != null) {
        final vendor = response.data['vendor'];

        if (vendor != null) {
          // ✅ Update store name from API response
          storeName.value = vendor['storeName'] ?? 'Pawfect Pet Store';

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

  // ========== Load User Info from Storage ==========

  void loadUserInfo() {
    try {
      log('📱 Loading user info from storage...');

      final StorageService storage = StorageService.instance;

      // ✅ Get mobile number from storage (saved during authentication)
      final storedMobile = storage.getMobileNumber();
      if (storedMobile != null && storedMobile.isNotEmpty) {
        // Format mobile number with country code if not present
        String formattedMobile = storedMobile;

        // Remove any existing formatting
        String cleanMobile = formattedMobile.replaceAll(RegExp(r'[^0-9]'), '');

        // Add country code and formatting if needed
        if (cleanMobile.length == 10) {
          // Indian mobile number without country code
          mobileNumber.value = '+91 $cleanMobile';
        } else if (cleanMobile.length == 12 && cleanMobile.startsWith('91')) {
          // Indian mobile number with country code but no +
          mobileNumber.value = '+$cleanMobile';
        } else if (storedMobile.startsWith('+91')) {
          // Already properly formatted
          mobileNumber.value = storedMobile;
        } else {
          // Use as is
          mobileNumber.value = storedMobile;
        }

        log('✅ Mobile number loaded from storage: ${mobileNumber.value}');
      } else {
        log('⚠️ No mobile number found in storage, using default');
      }

      // ✅ Get verification status
      final isVerified = storage.isUserVerified();
      isMobileVerified.value = isVerified;

      log(
        '✅ User info loaded - Mobile: ${mobileNumber.value}, Verified: $isVerified',
      );
    } catch (e) {
      log('❌ Error loading user info: $e');
      // Keep default values on error
    }
  }

  // ========== Load Profile Data ==========

  // Future<void> loadProfileData() async {
  //   isLoading.value = true;

  //   try {
  //     log('📊 Loading profile data...');

  //     final response = await _profileService.getProfileData();

  //     if (response.success && response.data != null) {
  //       final data = response.data;

  //       // Update profile data from API response
  //       storeName.value = data['storeName'] ?? 'Pawfect Pet Store';
  //       storeLogoUrl.value = data['storeLogoUrl'] ?? '';
  //       isStoreActive.value = data['isStoreActive'] ?? true;
  //       ownerName.value = data['ownerName'] ?? 'John Doe';
  //       email.value = data['email'] ?? 'john.doe@pawfect.com';
  //       mobileNumber.value = data['mobileNumber'] ?? '+91 9876543210';
  //       isEmailVerified.value = data['isEmailVerified'] ?? true;
  //       isMobileVerified.value = data['isMobileVerified'] ?? true;
  //       storeRating.value = (data['storeRating'] ?? 4.5).toDouble();
  //       totalReviews.value = data['totalReviews'] ?? 128;

  //       log('✅ Profile data loaded successfully');
  //     } else {
  //       // Use dummy data if API fails
  //       log('⚠️ API failed, using dummy data: ${response.message}');
  //       _loadDummyData();
  //     }
  //   } catch (e) {
  //     log('❌ Error loading profile data: $e');
  //     _loadDummyData();

  //     Get.snackbar(
  //       'Error',
  //       'Failed to load profile data',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // ========== Load Review Stats ==========

  Future<void> loadReviewStats() async {
    isLoadingReviews.value = true;

    try {
      log('📊 Loading review stats...');

      final response = await _profileService.getReviewStats();

      if (response.success && response.data != null) {
        final data = response.data;

        // ✅ Update review stats from API
        totalReviews.value = data['totalReviews'] ?? 0;

        // ✅ Handle averageRating - can be int or double
        final rating = data['averageRating'];

        log("reviews and rating $totalReviews $rating");
        if (rating != null) {
          storeRating.value =
              (rating is int) ? rating.toDouble() : rating.toDouble();
        } else {
          storeRating.value = 0.0;
        }

        log(
          '✅ Review stats loaded: ${totalReviews.value} reviews, ${storeRating.value} rating',
        );
      } else {
        // ✅ If API fails, use 0 values
        log('⚠️ Review stats API failed, using 0 values: ${response.message}');
        storeRating.value = 0.0;
        totalReviews.value = 0;
      }
    } catch (e) {
      log('❌ Error loading review stats: $e');

      // ✅ On error, use 0 values (don't show error to user)
      storeRating.value = 0.0;
      totalReviews.value = 0;
    } finally {
      isLoadingReviews.value = false;
    }
  }

  // ========== Store Status Toggle ==========

  Future<void> toggleStoreStatus() async {
    try {
      // Show loading state
      isLoading.value = true;

      log('🔄 Toggling store status to: ${!isStoreActive.value}');

      final response = await _profileService.updateStoreStatus(
        !isStoreActive.value,
      );

      if (response.success) {
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

        log('✅ Store status toggled successfully');
      } else {
        throw Exception(response.message ?? 'Failed to update store status');
      }
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
    // Navigate to onboarding screen in edit mode (no rejection reason)
    Get.toNamed(AppRoutes.onboardingScreen);
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
    Get.toNamed(AppRoutes.faq);
  }

  void navigateToTerms() {
    Get.toNamed(AppRoutes.termsConditions);
  }

  void navigateToPrivacy() {
    Get.toNamed(AppRoutes.privacyPolicy);
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
    await loadStoreInfo();
    loadUserInfo(); // ✅ Load user info from storage
    await loadReviewStats();
  }
}

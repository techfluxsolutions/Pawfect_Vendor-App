// import 'package:flutter/material.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Profile')),
//       body: Center(
//         child: Text('Profile Screen', style: TextStyle(fontSize: 24)),
//       ),
//     );
//   }
// }

import 'package:pawfect_vendor_app/controllers/profile_controller.dart';

import '../../libs.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Store Info
            _buildHeaderSection(primaryColor),

            SizedBox(height: 16),

            // Account Information Card
            _buildAccountInfoSection(primaryColor),

            SizedBox(height: 16),

            // Earnings & Payments Section
            _buildEarningsSection(primaryColor),

            SizedBox(height: 16),

            // Legal & Documents Section
            _buildLegalSection(primaryColor),

            SizedBox(height: 16),

            // Support & Help Section
            _buildSupportSection(primaryColor),

            SizedBox(height: 16),

            // Logout Button
            _buildLogoutButton(primaryColor),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              // IconButton(
              //   onPressed: controller.editProfile,
              //   icon: Icon(Icons.edit, color: Colors.black),
              // ),
            ],
          ),
          SizedBox(height: 20),
          // Store Logo
          Obx(
            () => CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child:
                  controller.storeLogoUrl.value.isNotEmpty
                      ? ClipOval(
                        child: Image.network(
                          controller.storeLogoUrl.value,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.store,
                              size: 50,
                              color: primaryColor,
                            );
                          },
                        ),
                      )
                      : Icon(Icons.store, size: 50, color: primaryColor),
            ),
          ),
          SizedBox(height: 12),
          // Store Name
          Obx(
            () => Text(
              controller.storeName.value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 8),
          // Store Status Toggle
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          controller.isStoreActive.value
                              ? Colors.green
                              : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    controller.isStoreActive.value ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 12),
                  // Toggle Switch
                  GestureDetector(
                    onTap:
                        controller.isLoading.value
                            ? null
                            : controller.toggleStoreStatus,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: 50,
                      height: 26,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color:
                            controller.isStoreActive.value
                                ? Colors.green
                                : Colors.grey[400],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            left: controller.isStoreActive.value ? 26 : 2,
                            top: 2,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child:
                                  controller.isLoading.value
                                      ? Padding(
                                        padding: EdgeInsets.all(4),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                controller.isStoreActive.value
                                                    ? Colors.green
                                                    : Colors.grey[600]!,
                                              ),
                                        ),
                                      )
                                      : Icon(
                                        controller.isStoreActive.value
                                            ? Icons.check
                                            : Icons.close,
                                        size: 14,
                                        color:
                                            controller.isStoreActive.value
                                                ? Colors.green
                                                : Colors.grey[600],
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection(Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          // Owner Name
          // Obx(
          //   () => _buildInfoRow(
          //     Icons.person_outline,
          //     'Owner Name',
          //     controller.ownerName.value,
          //     primaryColor,
          //     onTap: controller.editOwnerName,
          //   ),
          // ),
          // Divider(height: 24),
          // Email
          // Obx(
          //   () => _buildInfoRow(
          //     Icons.email_outlined,
          //     'Email Address',
          //     controller.email.value,
          //     primaryColor,
          //     isVerified: controller.isEmailVerified.value,
          //   ),
          // ),
          // Divider(height: 24),
          // Mobile
          Obx(
            () => _buildInfoRow(
              Icons.phone_outlined,
              'Mobile Number',
              controller.mobileNumber.value,
              primaryColor,
              isVerified: controller.isMobileVerified.value,
            ),
          ),
          Divider(height: 24),
          // Rating & Reviews
          Obx(() {
            // ✅ Show loading indicator while fetching reviews
            if (controller.isLoadingReviews.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                ),
              );
            }

            // ✅ Show ratings (including 0 values)
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Store Rating',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color:
                                controller.storeRating.value > 0
                                    ? Colors.amber
                                    : Colors.grey[400],
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            controller.storeRating.value.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  controller.storeRating.value > 0
                                      ? Colors.grey[800]
                                      : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Reviews',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        controller.totalReviews.value.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              controller.totalReviews.value > 0
                                  ? Colors.grey[800]
                                  : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color primaryColor, {
    bool isVerified = false,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Row(
                children: [
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
                  if (isVerified)
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (onTap != null)
          IconButton(
            onPressed: onTap,
            icon: Icon(Icons.edit, size: 18, color: Colors.grey[600]),
          ),
      ],
    );
  }

  Widget _buildEarningsSection(Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: primaryColor),
                SizedBox(width: 12),
                Text(
                  'Earnings & Payments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          _buildMenuTile(
            Icons.account_balance_wallet_outlined,
            'My Earnings & Settlements',
            primaryColor,
            controller.navigateToEarnings,
          ),
          _buildMenuTile(
            Icons.account_balance_outlined,
            'Bank Account Details',
            primaryColor,
            controller.navigateToBankAccount,
          ),
          _buildMenuTile(
            Icons.credit_card_outlined,
            'Payment Methods',
            primaryColor,
            controller.navigateToPaymentMethods,
          ),
          _buildMenuTile(
            Icons.receipt_long_outlined,
            'Transaction History',
            primaryColor,
            controller.navigateToTransactionHistory,
          ),
          // _buildMenuTile(
          //   Icons.description_outlined,
          //   'Tax Information (GST)',
          //   primaryColor,
          //   controller.navigateToTaxInfo,
          //   isLast: true,
          // ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.folder_outlined, color: primaryColor),
                SizedBox(width: 12),
                Text(
                  'Legal & Documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          _buildMenuTile(
            Icons.badge_outlined,
            'KYC Documents',
            primaryColor,
            controller.navigateToKYC,
          ),
          _buildMenuTile(
            Icons.business_center_outlined,
            'Business Documents',
            primaryColor,
            controller.navigateToBusinessDocuments,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: primaryColor),
                SizedBox(width: 12),
                Text(
                  'Support & Help',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          _buildMenuTile(
            Icons.phone_outlined,
            'Contact Support',
            primaryColor,
            controller.contactSupport,
          ),
          _buildMenuTile(
            Icons.question_answer_outlined,
            'Help & FAQ',
            primaryColor,
            controller.navigateToFAQ,
          ),
          _buildMenuTile(
            Icons.description_outlined,
            'Terms & Conditions',
            primaryColor,
            controller.navigateToTerms,
          ),
          _buildMenuTile(
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            primaryColor,
            controller.navigateToPrivacy,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    String title,
    Color primaryColor,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border:
              isLast
                  ? null
                  : Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: controller.logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red[200]!),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

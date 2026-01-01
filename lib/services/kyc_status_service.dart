import '../libs.dart';

class KycStatusService {
  static final KycStatusService _instance = KycStatusService._internal();
  static KycStatusService get instance => _instance;
  factory KycStatusService() => _instance;

  KycStatusService._internal();

  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService.instance;

  Timer? _pollingTimer;
  String _lastKycStatus = ''; // Track previous status

  String _rejectionReason = ''; // ✅ Add this at top of class

  // ✅ Get rejection reason
  String getRejectionReason() {
    return _rejectionReason;
  }

  Future<String> getCurrentKycStatus() async {
    try {
      final response = await _apiClient.get('/kyc-status');
      if (response.success && response.data != null) {
        final kycStatus = response.data['kycStatus'] ?? 'pending';

        // ✅ Store rejection reason if present
        if (response.data['vendor'] != null) {
          _rejectionReason =
              response.data['vendor']['rejectionReason'] ??
              'Your KYC has been rejected. Please contact support.';
        }

        return kycStatus;
      }
      return 'pending';
    } catch (e) {
      print('❌ Error getting KYC status: $e');
      return 'pending';
    }
  }

  // ✅ Start polling - call this from home screen or app
  void startPolling() {
    // Check immediately
    checkKycStatus();

    // Then check every 10 seconds
    _pollingTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      checkKycStatus();
    });

    print('🔄 KYC polling started');
  }

  // ✅ Stop polling
  void stopPolling() {
    _pollingTimer?.cancel();
    print('🛑 KYC polling stopped');
  }

  // ✅ Check KYC status from API
  Future<void> checkKycStatus() async {
    try {
      final response = await _apiClient.get(
        '/kyc-status',
      ); // ✅ Use correct endpoint

      if (response.success && response.data != null) {
        final kycStatus = response.data['kycStatus'] ?? 'pending';
        final vendor = response.data['vendor'];

        print('📊 KYC Status from API: $kycStatus');

        // ✅ Check if status changed from approved to rejected
        if (_lastKycStatus == 'approved' && kycStatus == 'rejected') {
          final rejectionReason =
              vendor?['rejectionReason'] ?? // ✅ Use 'rejectionReason' not 'kycRejectionReason'
              'Your KYC has been rejected. Please contact support.';

          _rejectionReason = rejectionReason;

          print('❌ KYC REJECTED: $rejectionReason');

          // Show rejection dialog on current screen
          _showRejectionDialog(rejectionReason);
        }

        // Update last known status
        _lastKycStatus = kycStatus;
      }
    } catch (e) {
      print('❌ KYC status check error: $e');
    }
  }

  // ✅ Show rejection dialog
  Future<void> _showRejectionDialog(String reason) async {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text(
              'Application Rejected',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            Text(
              'Reason:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                reason,
                style: TextStyle(color: Colors.red.shade700, height: 1.5),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Clear form and go back to onboarding
              final onboardingController = Get.find<OnboardingController>();
              onboardingController.clearForm();

              Get.back(); // Close dialog
              Get.offNamed(AppRoutes.onboardingScreen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
            ),
            child: Text('Resubmit KYC', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ✅ Get current KYC status (one-time check)
  // Future<String> getCurrentKycStatus() async {
  //   try {
  //     final response = await _apiClient.get('/kyc-status');
  //     if (response.success && response.data != null) {
  //       return response.data['kycStatus'] ?? 'pending';
  //     }
  //     return 'pending';
  //   } catch (e) {
  //     print('❌ Error getting KYC status: $e');
  //     return 'pending';
  //   }
  // }
}

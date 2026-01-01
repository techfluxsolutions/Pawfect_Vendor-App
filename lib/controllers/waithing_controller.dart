import '../libs.dart';

class WaitingController extends GetxController {
  final OnboardingService _onboardingService = OnboardingService();

  RxBool isChecking = false.obs;
  RxString kycStatus = 'pending'.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Check status immediately
    checkStatus();
    // Then check every 10 seconds
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      checkStatus();
    });
  }

  Future<void> checkStatus() async {
    isChecking.value = true;

    try {
      // ✅ Fetch KYC status from API
      final response = await _onboardingService.checkKycStatus();

      if (response.success && response.data != null) {
        kycStatus.value = response.data['kycStatus'] ?? 'pending';

        print('📊 KYC Status: ${kycStatus.value}');

        switch (kycStatus.value) {
          case 'approved':
            _timer?.cancel();
            print('🎉 KYC Approved!');

            await StorageService.instance.saveOnboardingStatus('approved');

            Get.offAllNamed(AppRoutes.home);

            Get.snackbar(
              'Success',
              'Your account has been approved!',
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade900,
            );

            await Future.delayed(Duration(milliseconds: 500));
            KycStatusService.instance.startPolling();
            break;

          case 'rejected':
            _timer?.cancel();
            print('❌ KYC Rejected');

            // ✅ Extract rejection reason from response
            final vendor = response.data?['vendor'];
            final rejectionReason =
                vendor?['rejectionReason'] ?? // ✅ CORRECT
                'Your KYC has been rejected. Please contact support.';

            print('❌ Rejection Reason: $rejectionReason');

            Get.back(); // Close waiting screen

            // ✅ Show rejection dialog
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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
                        rejectionReason,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Please re-upload with corrected documents.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      // ✅ Clear form data
                      final onboardingController =
                          Get.find<OnboardingController>();
                      onboardingController.clearForm();

                      Get.back(); // Close dialog
                      Get.offNamed(AppRoutes.onboardingScreen);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                    ),
                    child: Text(
                      'Resubmit KYC',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              barrierDismissible: false,
            );
            break;

          case 'pending':
            print('⏳ Still pending...');
            break;

          default:
            print('❓ Unknown status');
        }
      }
    } catch (e) {
      print('❌ Status check error: $e');
    } finally {
      isChecking.value = false;
    }
  }

  // Future<void> checkStatus() async {
  //   isChecking.value = true;

  //   try {
  //     final response = await _onboardingService.checkKycStatus();

  //     if (response.success && response.data != null) {
  //       kycStatus.value = response.data['kycStatus'] ?? 'pending';

  //       print('📊 KYC Status: ${kycStatus.value}');
  //       await StorageService.instance.saveOnboardingStatus('approved');
  //       // Navigate based on status
  //       if (kycStatus.value == 'approved') {
  //         _timer?.cancel();
  //         Get.offAllNamed(AppRoutes.home);
  //         Get.snackbar(
  //           'Success',
  //           'Your account has been approved!',
  //           backgroundColor: Colors.green.shade100,
  //           colorText: Colors.green.shade900,
  //         );
  //       } else if (kycStatus.value == 'rejected') {
  //         _timer?.cancel();
  //         Get.snackbar(
  //           'Application Rejected',
  //           'Please contact support for more details.',
  //           backgroundColor: Colors.red.shade100,
  //           colorText: Colors.red.shade900,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     print('❌ Status check error: $e');
  //   } finally {
  //     isChecking.value = false;
  //   }
  // }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

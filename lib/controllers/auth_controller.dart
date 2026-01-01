import '../libs.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;
  var mobileNumber = ''.obs;
  var otp = ''.obs;
  var canResend = false.obs;
  var resendTimer = 30.obs;

  Timer? _timer;

  void setMobileNumber(String value) {
    mobileNumber.value = value;
  }

  void setOtp(String value) {
    otp.value = value;
  }

  bool _validateMobile(BuildContext context) {
    if (mobileNumber.value.length != 10) {
      UToast.error(context, 'Enter valid 10 digit number');
      return false;
    }
    return true;
  }

  Future<void> sendOtp(BuildContext context) async {
    if (!_validateMobile(context)) return;

    isLoading.value = true;

    final result = await _authService.sendOtp(mobileNumber.value);

    if (result.success) {
      UToast.success(context, result.message ?? 'OTP sent successfully');
      Get.toNamed(AppRoutes.otp);
      _startResendTimer();
    } else {
      UToast.error(context, result.message ?? 'Failed to send OTP');
    }

    isLoading.value = false;
  }

  Future<void> verifyOtp(BuildContext context) async {
    if (otp.value.length != 4) {
      UToast.error(context, 'Enter 4 digit OTP');
      return;
    }

    isLoading.value = true;

    final result = await _authService.verifyOtp(
      mobile: mobileNumber.value,
      otp: otp.value,
    );

    if (result.success) {
      UToast.success(context, 'OTP Verified');

      // ✅ Check KYC status before navigation
      try {
        final String kycStatus =
            await KycStatusService.instance.getCurrentKycStatus();

        if (kycStatus == 'approved') {
          print('🎉 KYC approved, going to home');
          Get.offAllNamed(AppRoutes.home);
        } else if (kycStatus == 'submitted') {
          print('⏳ KYC submitted, going to waiting');
          Get.offNamed(AppRoutes.onboardingWaitingScreen);
        } else {
          print('📋 KYC pending, going to onboarding');
          Get.offNamed(AppRoutes.onboardingScreen);
        }
      } catch (e) {
        print('❌ Error checking KYC status: $e');
        // Fallback to onboarding if error occurs
        Get.offNamed(AppRoutes.onboardingScreen);
      }
    } else {
      UToast.error(context, result.message ?? 'Invalid OTP');
    }

    isLoading.value = false;
  }

  // Future<void> verifyOtp(BuildContext context) async {
  //   if (otp.value.length != 4) {
  //     UToast.error(context, 'Enter 4 digit OTP');
  //     return;
  //   }

  //   isLoading.value = true;

  //   final result = await _authService.verifyOtp(
  //     mobile: mobileNumber.value,
  //     otp: otp.value,
  //   );

  //   if (result.success) {
  //     UToast.success(context, 'OTP Verified');
  //     Get.offNamed(AppRoutes.onboardingScreen);
  //   } else {
  //     UToast.error(context, result.message ?? 'Invalid OTP');
  //   }

  //   isLoading.value = false;
  // }

  void _startResendTimer() {
    resendTimer.value = 30;
    canResend.value = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      resendTimer.value--;
      if (resendTimer.value == 0) {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

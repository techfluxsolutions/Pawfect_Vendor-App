// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';

import '../../libs.dart';

class OtpScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 350),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: primaryColor),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Lock Icon
                  Icon(Icons.lock_outline, size: 60, color: primaryColor),

                  SizedBox(height: 24),

                  // Title
                  Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 26,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Subtitle
                  Obx(
                    () => Text(
                      'Code sent to ${authController.mobileNumber.value}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),

                  SizedBox(height: 40),

                  // OTP Input
                  Pinput(
                    length: 4,
                    onChanged: (value) => authController.setOtp(value),
                    onCompleted:
                        (value) =>
                            authController.verifyOtp(context), // Pass context
                    defaultPinTheme: PinTheme(
                      width: 55,
                      height: 55,
                      textStyle: TextStyle(
                        fontSize: 22,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 55,
                      height: 55,
                      textStyle: TextStyle(
                        fontSize: 22,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryColor, width: 1.5),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 55,
                      height: 55,
                      textStyle: TextStyle(
                        fontSize: 22,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Verify Button - PASSING CONTEXT
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            authController.isLoading.value
                                ? null
                                : () => authController.verifyOtp(
                                  context,
                                ), // Pass context
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child:
                            authController.isLoading.value
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  'Verify',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Resend OTP - PASSING CONTEXT
                  Obx(
                    () => TextButton(
                      onPressed:
                          authController.canResend.value
                              ? () => authController.sendOtp(
                                context,
                              ) // Pass context
                              : null,
                      child: Text(
                        authController.canResend.value
                            ? 'Resend OTP'
                            : 'Resend in ${authController.resendTimer.value}s',
                        style: TextStyle(
                          color:
                              authController.canResend.value
                                  ? primaryColor
                                  : Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

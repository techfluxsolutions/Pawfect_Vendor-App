import 'package:pawfect_vendor_app/services/kyc_status_service.dart';

import '../../libs.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    Future.delayed(Duration(seconds: 3), () async {
      await _handleNavigation();
    });
  }

  Future<void> _handleNavigation() async {
    try {
      final StorageService storage = StorageService.instance;
      print('🔍 Checking user login status...');

      if (!storage.isLoggedIn()) {
        print('❌ User not logged in, going to login');
        Get.offNamed('/login');
        return;
      }

      print('✅ User logged in');

      // ✅ Check KYC status from API (this is the source of truth)
      final String actualKycStatus =
          await KycStatusService.instance.getCurrentKycStatus();

      print('📊 Actual KYC Status from API: $actualKycStatus');

      // ✅ Use API response instead of storage
      if (actualKycStatus == 'approved') {
        print('🎉 KYC approved, going to home');
        Get.offAllNamed(AppRoutes.home);
      } else if (actualKycStatus == 'submitted') {
        print('⏳ KYC submitted, going to waiting');
        Get.offNamed(AppRoutes.onboardingWaitingScreen);
      } else {
        // pending or any other status
        print('📋 KYC pending, going to onboarding');
        Get.offNamed(AppRoutes.onboardingScreen);
      }

      // ❌ REMOVE the switch statement completely
    } catch (e) {
      print('❌ Navigation error: $e');
      Get.offNamed('/login');
    }
  }

  // Future<void> _handleNavigation() async {
  //   try {
  //     final StorageService storage = StorageService.instance;

  //     print('🔍 Checking user login status...');

  //     // Check if user is logged in
  //     if (!storage.isLoggedIn()) {
  //       print('❌ User not logged in, going to login');
  //       Get.offNamed('/login');
  //       return;
  //     }

  //     print('✅ User logged in');

  //     // User is logged in - check onboarding status
  //     final onboardingStatus = storage.getOnboardingStatus() ?? 'pending';

  //     print('📊 Onboarding Status: $onboardingStatus');

  //     // In _handleNavigation(), before the switch statement
  //     final String actualKycStatus =
  //         await KycStatusService.instance.getCurrentKycStatus();

  //     // Then use actualKycStatus instead of onboardingStatus from storage
  //     if (actualKycStatus == 'approved') {
  //       Get.offAllNamed(AppRoutes.home);
  //     } else if (actualKycStatus == 'pending' ||
  //         actualKycStatus == 'submitted') {
  //       Get.offNamed(AppRoutes.onboardingWaitingScreen);
  //     }

  //     switch (onboardingStatus) {
  //       case 'pending':
  //         print('📋 Status pending, going to onboarding');
  //         Get.offNamed(AppRoutes.onboardingScreen); // ✅ Use the constant
  //         break;
  //       case 'submitted':
  //         print('⏳ Status submitted, going to waiting');
  //         Get.offNamed(AppRoutes.onboardingWaitingScreen); // ✅ Use the constant
  //         break;
  //       case 'approved':
  //         print('🎉 Status approved, going to home');
  //         Get.offAllNamed(AppRoutes.home); // ✅ Use the constant
  //         break;
  //       default:
  //         print('❓ Unknown status, going to login');
  //         Get.offNamed(AppRoutes.login); // ✅ Use the constant
  //     }
  //   } catch (e) {
  //     print('❌ Navigation error: $e');
  //     Get.offNamed('/login');
  //   }
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.pets, size: 80, color: Colors.white),
                ),
                SizedBox(height: 24),
                Text(
                  'Pawfect',
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Vendor App',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

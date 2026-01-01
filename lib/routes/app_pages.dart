// import 'package:pawfect_vendor_app/views/earnings_screen/earnings_screen.dart';
// import 'package:pawfect_vendor_app/views/earnings_screen/bank_details_screen.dart';
// import 'package:pawfect_vendor_app/views/earnings_screen/payment_methods_screen.dart';
// import 'package:pawfect_vendor_app/views/earnings_screen/transaction_history_screen.dart';
// import 'package:pawfect_vendor_app/views/orders_screen/orders_screen.dart';
// import 'package:pawfect_vendor_app/views/product_details_screen/product_details_screen.dart';
// import 'package:pawfect_vendor_app/views/notifications_screen/notifications_screen.dart';
// import 'package:pawfect_vendor_app/views/alerts_screen/alerts_screen.dart';
// import 'package:pawfect_vendor_app/views/analytics_screen/analytics_screen.dart';
// import 'package:pawfect_vendor_app/views/reports_screen/reports_screen.dart';
import 'package:pawfect_vendor_app/views/inventory_screen/inventory_screen.dart';

import '../libs.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.otp, page: () => OtpScreen()),
    GetPage(name: AppRoutes.homeScreen, page: () => HomeScreen()),
    GetPage(name: AppRoutes.onboardingScreen, page: () => OnboardingScreen()),
    GetPage(
      name: AppRoutes.onboardingWaitingScreen,
      page: () => OnboardingWaitingScreen(),
    ),

    GetPage(name: AppRoutes.home, page: () => Home()),
    GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
    GetPage(name: AppRoutes.product, page: () => ProductScreen()),
    GetPage(name: AppRoutes.order, page: () => OrderScreen()),
    GetPage(name: AppRoutes.addProduct, page: () => AddProductScreen()),
    GetPage(name: AppRoutes.productDetails, page: () => ProductDetailsScreen()),
    GetPage(name: AppRoutes.earningsScreen, page: () => EarningsScreen()),
    GetPage(name: AppRoutes.bankDetails, page: () => BankDetailsScreen()),
    GetPage(name: AppRoutes.paymentMethods, page: () => PaymentMethodsScreen()),
    GetPage(
      name: AppRoutes.transactionHistory,
      page: () => TransactionHistoryScreen(),
    ),
    GetPage(name: AppRoutes.orders, page: () => OrdersScreen()),
    GetPage(name: AppRoutes.notifications, page: () => NotificationsScreen()),
    GetPage(name: AppRoutes.alertsManagement, page: () => AlertsScreen()),
    GetPage(name: AppRoutes.analytics, page: () => AnalyticsScreen()),
    GetPage(name: AppRoutes.reports, page: () => ReportsScreen()),
    GetPage(name: AppRoutes.inventory, page: () => InventoryScreen()),
  ];
}

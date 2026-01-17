import '../libs.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(name: AppRoutes.otp, page: () => OtpScreen()),
    GetPage(
      name: AppRoutes.homeScreen,
      page: () => HomeScreen(),
      binding: HomeScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.onboardingScreen,
      page: () => OnboardingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OnboardingController>(() => OnboardingController());
      }),
    ),
    GetPage(
      name: AppRoutes.onboardingWaitingScreen,
      page: () => OnboardingWaitingScreen(),
      binding: WaitingBinding(),
    ),

    GetPage(name: AppRoutes.home, page: () => Home(), binding: HomeBinding()),
    GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
    GetPage(name: AppRoutes.product, page: () => ProductScreen()),
    GetPage(name: AppRoutes.order, page: () => OrderScreen()),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => AddProductScreen(),
      binding: ProductBinding(),
    ),
    GetPage(name: AppRoutes.productDetails, page: () => ProductDetailsScreen()),
    GetPage(
      name: AppRoutes.earningsScreen,
      page: () => EarningsScreen(),
      binding: EarningsBinding(),
    ),
    GetPage(
      name: AppRoutes.bankDetails,
      page: () => BankDetailsScreen(),
      binding: BankDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentMethods,
      page: () => PaymentMethodsScreen(),
      binding: PaymentMethodsBinding(),
    ),
    GetPage(
      name: AppRoutes.transactionHistory,
      page: () => TransactionHistoryScreen(),
      binding: TransactionHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => OrdersScreen(),
      binding: OrdersBinding(),
    ),
    GetPage(name: AppRoutes.orderDetails, page: () => OrderDetailsScreen()),
    GetPage(
      name: AppRoutes.notifications,
      page: () => NotificationsScreen(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.alertsManagement,
      page: () => AlertsScreen(),
      binding: AlertsBinding(),
    ),
    GetPage(
      name: AppRoutes.analytics,
      page: () => AnalyticsScreen(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => ReportsScreen(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: AppRoutes.inventory,
      page: () => InventoryScreen(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: AppRoutes.termsConditions,
      page: () => TermsConditionsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LegalController>(() => LegalController());
      }),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => PrivacyPolicyScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LegalController>(() => LegalController());
      }),
    ),
    GetPage(
      name: AppRoutes.faq,
      page: () => FAQScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FAQController>(() => FAQController());
      }),
    ),
  ];
}
